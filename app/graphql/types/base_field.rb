# frozen_string_literal: true

require 'apollo-federation'

class Types::BaseField < GraphQL::Schema::Field
  include ApolloFederation::Field

  #field_class GraphQL::Cache::Field
end
