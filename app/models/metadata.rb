class Metadata < ActiveRecord::Base
  include Bolognese::Utils
  include Bolognese::DoiUtils

  include Cacheable

  alias_attribute :created_at, :created
  validates_associated :doi
  validates_presence_of :xml, :namespace
  validate :metadata_must_be_valid

  belongs_to :doi, foreign_key: :dataset

  before_validation :set_metadata_version, :set_namespace
  before_create { self.created = Time.zone.now.utc.iso8601 }

  def uid
    Base32::URL.encode(id, split: 4, length: 16)
  end

  def xml=(value)
    xml = value.present? ? Base64.decode64(value) : nil
    write_attribute(:xml, xml)
  end

  def doi_id
    doi.doi
  end

  def doi_id=(value)
    r = Doi.where(doi: value).first
    fail ActiveRecord::RecordNotFound unless r.present?

    write_attribute(:dataset, r.id)
  end

  def metadata_must_be_valid
    return nil if doi && doi.draft?
    return nil unless xml.present?

    doc = Nokogiri::XML(xml, nil, 'UTF-8', &:noblanks)
    return nil unless doc.present?

    # load XSD from bolognese gem
    namespace = doc.namespaces["xmlns"]
    errors.add(:xml, "XML has no namespace.") && return unless namespace.present?

    kernel = namespace.to_s.split("/").last
    filepath = Bundler.rubygems.find_name('bolognese').first.full_gem_path + "/resources/#{kernel}/metadata.xsd"
    schema = Nokogiri::XML::Schema(open(filepath))
    err = schema.validate(doc).map { |error| error.to_s }.unwrap
    errors.add(:xml, err) if err.present?
  end

  def set_metadata_version
    current_metadata = Metadata.where(dataset: dataset).order('metadata.created DESC').first
    self.metadata_version = current_metadata.present? ? current_metadata.metadata_version + 1 : 0
  end

  def set_namespace
    doc = Nokogiri::XML(xml, nil, 'UTF-8', &:noblanks)
    self.namespace = doc && doc.namespaces["xmlns"]
  end
end
