require 'rails_helper'

describe Doi, vcr: true do
  subject { create(:doi) }

  context "validate_prefix" do
    it 'should validate' do
      str = "10.5072"
      expect(subject.validate_prefix(str)).to eq("10.5072")
    end

    it 'should validate with slash' do
      str = "10.5072/"
      expect(subject.validate_prefix(str)).to eq("10.5072")
    end

    it 'should validate with shoulder' do
      str = "10.5072/FK2"
      expect(subject.validate_prefix(str)).to eq("10.5072")
    end

    it 'should not validate if not DOI prefix' do
      str = "20.5072"
      expect(subject.validate_prefix(str)).to be_nil
    end
  end

  context "generate_random_doi" do
    it 'should generate' do
      str = "10.5072"
      expect(subject.generate_random_doi(str).length).to eq(17)
    end

    it 'should generate with seed' do
      str = "10.5072"
      number = 123456
      expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/003r-j076")
    end

    it 'should generate with seed checksum' do
      str = "10.5072"
      number = 1234578
      expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/015n-mj18")
    end

    it 'should generate with another seed checksum' do
      str = "10.5072"
      number = 1234579
      expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/015n-mk15")
    end

    it 'should generate with shoulder' do
      str = "10.5072/fk2"
      number = 123456
      expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/fk2-003r-j076")
    end

    it 'should not generate if not DOI prefix' do
      str = "20.5438"
      expect { subject.generate_random_doi(str) }.to raise_error(IdentifierError, "No valid prefix found")
    end
  end

  context "register_doi", order: :defined do
    let(:provider) { create(:provider, symbol: "DATACITE") }
    let(:client) { create(:client, provider: provider, symbol: ENV['MDS_USERNAME'], password: ENV['MDS_PASSWORD']) }
    
    subject { build(:doi, doi: "10.5438/mcnv-ga6n", client: client, aasm_state: "findable") }

    it 'should register' do
      url = "https://blog.datacite.org/"
      options = { url: url, username: client.symbol, password: client.password, role_id: "client_admin" }
      expect(subject.register_url(options).body).to eq("data"=>{"responseCode"=>1, "handle"=>"10.5438/MCNV-GA6N"})
      expect(subject.minted.iso8601).to be_present

      response = subject.get_url(options)

      expect(response.body.dig("data", "responseCode")).to eq(1)
      expect(response.body.dig("data", "values")).to eq([{"index"=>1, "type"=>"URL", "data"=>{"format"=>"string", "value"=>"https://blog.datacite.org/"}, "ttl"=>86400, "timestamp"=>"2018-07-24T10:43:28Z"}])
    end

    it 'should change url' do
      url = "https://blog.datacite.org/re3data-science-europe/"
      options = { url: url, username: client.symbol, password: client.password, role_id: "client_admin" }
      expect(subject.register_url(options).body).to eq("data"=>{"responseCode"=>1, "handle"=>"10.5438/MCNV-GA6N"})
      expect(subject.minted.iso8601).to be_present

      response = subject.get_url(options)

      expect(response.body.dig("data", "responseCode")).to eq(1)
      expect(response.body.dig("data", "values")).to eq([{"index"=>1, "type"=>"URL", "data"=>{"format"=>"string", "value"=>"https://blog.datacite.org/re3data-science-europe/"}, "ttl"=>86400, "timestamp"=>"2018-07-24T10:43:29Z"}])
    end

    it 'draft doi' do
      subject = build(:doi, doi: "10.5438/mcnv-ga6n", client: client, aasm_state: "draft")
      url = "https://blog.datacite.org/"
      options = { url: url, username: client.symbol, password: client.password, role_id: "client_admin" }
      expect(subject.register_url(options).body).to eq("errors"=>[{"title"=>"DOI is not registered or findable."}])
    end

    it 'missing username' do
      subject = build(:doi, doi: "10.5438/mcnv-ga6n", client: nil, aasm_state: "findable")
      options = { url: "https://blog.datacite.org/re3data-science-europe/" }
      expect(subject.register_url(options).body).to eq("errors"=>[{"title"=>"Client ID missing."}])
    end

    it 'server not responsible' do
      subject = build(:doi, doi: "10.1371/journal.pbio.2001414", client: client, aasm_state: "findable")
      options = { username: client.symbol, password: client.password }
      expect(subject.get_url(options).body).to eq("errors"=>[{"status"=>400, "title"=>{"responseCode"=>301, "message"=>"That prefix doesn't live here", "handle"=>"10.1371/JOURNAL.PBIO.2001414"}}])
    end
  end

  context "get_dois" do
    let(:provider) { create(:provider, symbol: "DATACITE") }
    let(:client) { create(:client, provider: provider, symbol: ENV['MDS_USERNAME'], password: ENV['MDS_PASSWORD']) }
    
    it 'should get dois' do
      options = { username: client.symbol, password: client.password, role_id: "client_admin" }
      dois = Doi.get_dois(options).body["data"].split("\n")
      expect(dois.length).to eq(24)
      expect(dois.first).to eq("10.14454/05MB-Q396")
    end
  end
end
