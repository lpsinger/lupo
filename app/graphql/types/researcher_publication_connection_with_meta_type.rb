# frozen_string_literal: true

class ResearcherPublicationConnectionWithMetaType < BaseConnection
  edge_type(EventDataEdgeType, edge_class: EventDataEdge)
  field_class GraphQL::Cache::Field
  
  field :total_count, Integer, null: false, cache: true

  def total_count
    Event.query(nil, obj_id: https_to_http(object.parent[:id]), citation_type: "Person-ScholarlyArticle").dig(:meta, "total").to_i
  end

  def https_to_http(url)
    uri = Addressable::URI.parse(url)
    uri.scheme = "http"
    uri.to_s
  end
end
