class DoiSerializer < ActiveModel::Serializer
  include Bolognese::Utils
  include Bolognese::DoiUtils

  attributes :doi, :prefix, :suffix, :identifier, :url, :author, :title, :publisher, :resource_type_subtype, :description, :version, :metadata_version, :schema_version, :state, :is_active, :reason, :source, :landing_page, :xml, :published, :created, :registered, :updated

  belongs_to :client, serializer: ClientSerializer
  belongs_to :provider, serializer: ProviderSerializer
  belongs_to :resource_type, serializer: ResourceTypeSerializer
  has_many :media, serializer: MediaSerializer

  def id
    object.doi.downcase
  end

  def doi
    object.doi.downcase
  end

  def prefix
    object.doi.split("/", 2).first if object.doi.present?
  end

  def suffix
    object.doi.downcase.split("/", 2).last if object.doi.present?
  end

  def author
    Array.wrap(object.author)
  end

  def title
    object.title_normalized
  end

  def description
    object.description_normalized
  end

  def resource_type_subtype
    object.additional_type
  end

  def is_active
    object.is_active == "\u0001" ? true : false
  end

  def state
    object.aasm_state
  end

  def updated
    object.updated_at
  end

  def registered
    object.date_registered
  end

  def published
    object.date_published
  end

  def landing_page
    { status: object.last_landing_page_status,
      content_type: object.last_landing_page_content_type,
      checked: object.last_landing_page_status_check }
  end

  # def license
  #   Array.wrap(object.license).map { |l| l["id"] }.compact.unwrap
  # end

  def version
    object.b_version
  end

  def xml
    Base64.strict_encode64(object.xml) if object.xml.present?
  rescue ArgumentError => exception
    Bugsnag.notify(exception)
    
    nil
  end
end
