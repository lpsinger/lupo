# frozen_string_literal: true

class QueryType < BaseObject
  field :providers, [ProviderType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def providers(query: nil, first: nil)
    Provider.query(query, page: { number: 1, size: first }).records
  end

  field :provider, ProviderType, null: false do
    argument :id, ID, required: true
  end

  def provider(id:)
    Provider.unscoped.where("allocator.role_name IN ('ROLE_ALLOCATOR', 'ROLE_ADMIN')").where(deleted_at: nil).where(symbol: id).first
  end

  field :clients, [ClientType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def clients(query: nil, first: nil)
    Client.query(query, page: { number: 1, size: first }).records
  end

  field :client, ClientType, null: false do
    argument :id, ID, required: true
  end

  def client(id:)
    Client.where(symbol: id).where(deleted_at: nil).first
  end

  field :prefixes, [PrefixType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def prefixes(query: nil, first: nil)
    if query.present?
      collection = Prefix.query(query)
    else
      collection = Prefix.all
    end

    collection.page(1).per(first)
  end

  field :prefix, PrefixType, null: false do
    argument :id, ID, required: true
  end

  def prefix(id:)
    Prefix.where(prefix: id).first
  end

  field :funders, [FunderType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def funders(query: nil, first: nil)
    Funder.query(query, limit: first)
  end

  field :funder, FunderType, null: false do
    argument :id, ID, required: true
  end

  def funder(id:)
    result = Funder.find_by_id(id).first
    fail ActiveRecord::RecordNotFound if result.nil?

    result
  end

  field :researcher, ResearcherType, null: false do
    argument :id, ID, required: true
  end

  def researcher(id:)
    result = Researcher.find_by_id(id).first
    fail ActiveRecord::RecordNotFound if result.nil?

    result
  end

  field :organizations, [OrganizationType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def organizations(query: nil, first: nil)
    Organization.query(query, limit: first)
  end

  field :organization, OrganizationType, null: false do
    argument :id, ID, required: true
  end

  def organization(id:)
    result = Organization.find_by_id(id).first
    fail ActiveRecord::RecordNotFound if result.nil?

    result
  end

  field :datasets, [DatasetType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def datasets(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Dataset", state: "findable", page: { number: 1, size: first })
  end

  field :dataset, DatasetType, null: false do
    argument :id, ID, required: true
  end

  def dataset(id:)
    set_doi(id)
  end

  field :publications, [PublicationType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def publications(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Text", state: "findable", page: { number: 1, size: first })
  end

  field :publication, PublicationType, null: false do
    argument :id, ID, required: true
  end

  def publication(id:)
    set_doi(id)
  end

  field :audiovisuals, [AudiovisualType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def audiovisuals(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Audiovisual", state: "findable", page: { number: 1, size: first })
  end

  field :audiovisual, AudiovisualType, null: false do
    argument :id, ID, required: true
  end

  def audiovisual(id:)
    set_doi(id)
  end

  field :collections, [CollectionType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def collections(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Collection", state: "findable", page: { number: 1, size: first })
  end

  field :collection, CollectionType, null: false do
    argument :id, ID, required: true
  end

  def collection(id:)
    set_doi(id)
  end

  field :data_papers, [DataPaperType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def data_papers(query: nil, first: nil)
    Doi.query(query, resource_type_id: "DataPaper", state: "findable", page: { number: 1, size: first })
  end

  field :data_paper, DataPaperType, null: false do
    argument :id, ID, required: true
  end

  def data_paper(id:)
    set_doi(id)
  end

  field :events, [EventType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def events(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Event", state: "findable", page: { number: 1, size: first })
  end

  field :event, EventType, null: false do
    argument :id, ID, required: true
  end

  def event(id:)
    set_doi(id)
  end

  field :images, [ImageType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def images(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Image", state: "findable", page: { number: 1, size: first })
  end

  field :image, ImageType, null: false do
    argument :id, ID, required: true
  end

  def image(id:)
    set_doi(id)
  end

  field :interactive_resources, [InteractiveResourceType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def interactive_resources(query: nil, first: nil)
    Doi.query(query, resource_type_id: "InteractiveResource", state: "findable", page: { number: 1, size: first })
  end

  field :interactive_resource, InteractiveResourceType, null: false do
    argument :id, ID, required: true
  end

  def interactive_resource(id:)
    set_doi(id)
  end

  field :models, [ModelType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def models(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Model", state: "findable", page: { number: 1, size: first })
  end

  field :model, ModelType, null: false do
    argument :id, ID, required: true
  end

  def model(id:)
    set_doi(id)
  end

  field :physical_objects, [PhysicalObjectType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def physical_objects(query: nil, first: nil)
    Doi.query(query, resource_type_id: "PhysicalObject", state: "findable", page: { number: 1, size: first })
  end

  field :physical_object, PhysicalObjectType, null: false do
    argument :id, ID, required: true
  end

  def physical_object(id:)
    set_doi(id)
  end

  field :services, [ServiceType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def services(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Service", state: "findable", page: { number: 1, size: first })
  end

  field :service, ServiceType, null: false do
    argument :id, ID, required: true
  end

  def service(id:)
    set_doi(id)
  end

  field :softwares, [SoftwareType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def softwares(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Software", state: "findable", page: { number: 1, size: first })
  end

  field :software, SoftwareType, null: false do
    argument :id, ID, required: true
  end

  def software(id:)
    set_doi(id)
  end

  field :sounds, [SoundType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def sounds(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Sound", state: "findable", page: { number: 1, size: first })
  end

  field :sound, SoundType, null: false do
    argument :id, ID, required: true
  end

  def sound(id:)
    set_doi(id)
  end

  field :workflows, [WorkflowType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def workflows(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Workflow", state: "findable", page: { number: 1, size: first })
  end

  field :workflow, WorkflowType, null: false do
    argument :id, ID, required: true
  end

  def workflow(id:)
    set_doi(id)
  end

  field :others, [OtherType], null: false do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def others(query: nil, first: nil)
    Doi.query(query, resource_type_id: "Other", state: "findable", page: { number: 1, size: first })
  end

  field :other, OtherType, null: false do
    argument :id, ID, required: true
  end

  def other(id:)
    set_doi(id)
  end

  def set_doi(id)
    doi = doi_from_url(id)
    fail ActiveRecord::RecordNotFound if doi.nil?

    result = Doi.find_by_id(doi).first
    fail ActiveRecord::RecordNotFound if result.nil?

    result
  end

  def doi_from_url(url)
    if /\A(?:(http|https):\/\/(dx\.)?(doi.org|handle.test.datacite.org)\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match?(url)
      uri = Addressable::URI.parse(url)
      uri.path.gsub(/^\//, "").downcase
    end
  end
end
