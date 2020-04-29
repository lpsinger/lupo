# frozen_string_literal: true

module Types
  class LabelType < Types::BaseObject
    description "Information about labels"

    field :code, ID, null: false, description: "Label language ISO 639-1 code"
    field :name, String, null: true, method: :label, description: "Label name"
  end
end
