# frozen_string_literal: true

class OrganizationType < BaseObject
  description "Information about organizations"

  field :id, ID, null: true, description: "ROR ID"
  field :type, String, null: false, description: "The type of the item."
  field :name, String, null: false, description: "The name of the organization."
  field :alternate_name, [String], null: true, description: "An alias for the organization."
  field :identifiers, [IdentifierType], null: true, description: "The identifier(s) for the organization."
  field :url, [String], null: true, hash_key: "links", description: "URL of the organization."
  field :address, AddressType, null: true, description: "Physical address of the organization."

  field :datasets, OrganizationDatasetConnectionWithMetaType, null: false, description: "Datasets from this organization", connection: true do
    argument :first, Int, required: false, default_value: 25
  end

  field :publications, OrganizationPublicationConnectionWithMetaType, null: false, description: "Publications from this organization", connection: true do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  field :software_source_codes, OrganizationSoftwareConnectionWithMetaType, null: false, description: "Software from this organization", connection: true do
    argument :first, Int, required: false, default_value: 25
  end

  # field :researchers, OrganizationResearcherConnectionWithMetaType, null: false, description: "Researchers associated with this organization", connection: true do
  #   argument :first, Int, required: false, default_value: 25
  # end

  def type
    "Organization"
  end

  def alternate_name
    object.aliases + object.acronyms
  end

  def identifiers
    Array.wrap(object.id).map { |o| { "identifier_type" => "ROR", "identifier" => o } } + 
    Array.wrap(object.fund_ref).map { |o| { "identifier_type" => "fundRef", "identifier" => o } } + 
    Array.wrap(object.wikidata).map { |o| { "identifier_type" => "wikidata", "identifier" => o } } + 
    Array.wrap(object.grid).map { |o| { "identifier_type" => "grid", "identifier" => o } } + 
    Array.wrap(object.wikipedia_url).map { |o| { "identifier_type" => "wikipedia", "identifier" => o } }
  end

  def address
    { "type" => "postalAddress",
      "country" => object.country.to_h.fetch("name", nil) }
  end

  def datasets(**args)
    ids = Event.query(nil, obj_id: object.id, citation_type: "Dataset-Organization").results.to_a.map do |e|
      doi_from_url(e.subj_id)
    end
    
    ElasticsearchLoader.for(Doi).load_many(ids)
  end

  def publications(**args)
    ids = Event.query(nil, obj_id: object.id, citation_type: "Organization-ScholarlyArticle").results.to_a.map do |e|
      doi_from_url(e.subj_id)
    end
    ElasticsearchLoader.for(Doi).load_many(ids)
  end

  def software_source_codes(**args)
    ids = Event.query(nil, obj_id: object.id, citation_type: "Organization-SoftwareSourceCode").results.to_a.map do |e|
      doi_from_url(e.subj_id)
    end
    ElasticsearchLoader.for(Doi).load_many(ids)
  end

  # def researchers(**args)
  #   ids = Event.query(nil, obj_id: object.id, citation_type: "Organization-Person").results.to_a.map do |e|
  #     orcid_from_url(e.subj_id)
  #   end
  #   ElasticsearchLoader.for(Researcher).load_many(ids)
  # end
end
