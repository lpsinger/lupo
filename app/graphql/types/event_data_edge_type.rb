# frozen_string_literal: true

class EventDataEdgeType < GraphQL::Types::Relay::BaseEdge
  node_type(EventType)

  field :source, String, null: false, description: "Source for this event"
  field :relation_type, String, null: false, description: "Relation type for this event"
  field :total, Integer, null: false, description: "Total count for this event"
end
