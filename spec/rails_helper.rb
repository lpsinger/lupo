ENV['RAILS_ENV'] = 'test'
ENV["TEST_CLUSTER_NODES"] = "1"

# set up Code Climate
require 'simplecov'
SimpleCov.start

require File.expand_path('../../config/environment', __FILE__)

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

require "rspec/rails"
require "shoulda-matchers"
require "webmock/rspec"
require "rack/test"
require "colorize"
require "database_cleaner"
require 'aasm/rspec'
require "strip_attributes/matchers"
require 'rspec-benchmark'

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

WebMock.disable_net_connect!(
  allow: ['codeclimate.com:443', ENV['PRIVATE_IP'], ENV['ES_HOST']],
  allow_localhost: true
)

# configure shoulda matchers to use rspec as the test framework and full matcher libraries for rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include StripAttributes::Matchers
  config.include RSpec::Benchmark::Matchers
  # don't use transactions, use database_clear gem via support file
  config.use_transactional_fixtures = false

  # add custom json method
  config.include RequestHelper, type: :request

  config.include JobHelper, type: :job

  ActiveJob::Base.queue_adapter = :test
end

VCR.configure do |c|
  mds_token = Base64.strict_encode64("#{ENV['MDS_USERNAME']}:#{ENV['MDS_PASSWORD']}")
  admin_token = Base64.strict_encode64("#{ENV['ADMIN_USERNAME']}:#{ENV['ADMIN_PASSWORD']}")
  handle_token = Base64.strict_encode64("300%3A#{ENV['HANDLE_USERNAME']}:#{ENV['HANDLE_PASSWORD']}")
  mailgun_token = Base64.strict_encode64("api:#{ENV['MAILGUN_API_KEY']}")
  sqs_host = "sqs.#{ENV['AWS_REGION'].to_s}.amazonaws.com"

  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com", "api.mailgun.net", "elasticsearch", sqs_host
  c.filter_sensitive_data("<MDS_TOKEN>") { mds_token }
  c.filter_sensitive_data("<ADMIN_TOKEN>") { admin_token }
  c.filter_sensitive_data("<HANDLE_TOKEN>") { handle_token }
  c.filter_sensitive_data("<MAILGUN_TOKEN>") { mailgun_token }
  c.filter_sensitive_data("<VOLPINO_TOKEN>") { ENV["VOLPINO_TOKEN"] }
  c.filter_sensitive_data("<SLACK_WEBHOOK_URL>") { ENV["SLACK_WEBHOOK_URL"] }
  c.configure_rspec_metadata!
  c.default_cassette_options = { :match_requests_on => [:method, :path] }
end

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end
