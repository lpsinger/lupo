# frozen_string_literal: true

class SoftwareConnectionWithMetaType < BaseConnection
  edge_type(SoftwareEdgeType)
  field_class GraphQL::Cache::Field

  field :total_count, Integer, null: false, cache: true
  field :years, [FacetType], null: true, cache: true
  field :software_connection_count, Integer, null: false, cache: true
  field :publication_connection_count, Integer, null: false, cache: true
  field :dataset_connection_count, Integer, null: false, cache: true
  field :person_connection_count, Integer, null: false, cache: true
  field :funder_connection_count, Integer, null: false, cache: true
  field :organization_connection_count, Integer, null: false, cache: true

  def total_count
    args = object.arguments
    args[:user_id] ||= object.parent.try(:orcid).present? ? orcid_from_url(object.parent.orcid) : nil
    args[:client_id] ||= object.parent.try(:client_type).present? ? object.parent.symbol.downcase : nil
    args[:provider_id] ||= object.parent.try(:role_name).present? ? object.parent.symbol.downcase : nil

    response(**args).results.total  
  end

  def years
    args = object.arguments
    args[:provider_id] ||= object.parent.try(:role_name).present? ? object.parent.symbol.downcase : nil

    res = response(**args)
    res.results.total.positive? ? facet_by_year(res.response.aggregations.years.buckets) : nil
  end

  def response(**args)
    @response ||= Doi.query(args[:query], 
                            user_id: args[:user_id], 
                            client_id: args[:client_id], 
                            provider_id: args[:provider_id],
                            funder_id: args[:funder_id], 
                            affiliation_id: args[:affiliation_id],
                            re3data_id: args[:re3data_id], 
                            year: args[:year], 
                            resource_type_id: "Software", 
                            has_citations: args[:has_citations], 
                            has_views: args[:has_views], 
                            has_downloads: args[:has_downloads], 
                            page: { number: 1, size: 0 })
  end

  def software_connection_count
    Event.query(nil, citation_type: "SoftwareSourceCode-SoftwareSourceCode", page: { number: 1, size: 0 }).results.total
  end

  def publication_connection_count
    Event.query(nil, citation_type: "ScholarlyArticle-SoftwareSourceCode", page: { number: 1, size: 0 }).results.total
  end

  def dataset_connection_count
    Event.query(nil, citation_type: "Dataset-SoftwareSourceCode", page: { number: 1, size: 0 }).results.total
  end

  def person_connection_count
    Event.query(nil, citation_type: "Person-SoftwareSourceCode", page: { number: 1, size: 0 }).results.total
  end

  def funder_connection_count
    Event.query(nil, citation_type: "Funder-SoftwareSourceCode", page: { number: 1, size: 0 }).results.total
  end

  def organization_connection_count
    Event.query(nil, citation_type: "Organization-SoftwareSourceCode", page: { number: 1, size: 0 }).results.total
  end
end
