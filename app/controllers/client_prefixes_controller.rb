# frozen_string_literal: true

require "base32/url"
require "uri"

class ClientPrefixesController < ApplicationController
  before_action :set_client_prefix, only: %i[show update destroy]
  before_action :authenticate_user!
  before_action :set_include
  load_and_authorize_resource except: %i[index show set_created set_provider]
  around_action :skip_bullet, only: %i[index], if: -> { defined?(Bullet) }

  def index
    sort =
      case params[:sort]
      when "name"
        { "prefix.uid" => { order: "asc" } }
      when "-name"
        { "prefix.uid" => { order: "desc" } }
      when "created"
        { created_at: { order: "asc" } }
      when "-created"
        { created_at: { order: "desc" } }
      else
        { created_at: { order: "desc" } }
      end

    page = page_from_params(params)

    response =
      if params[:id].present?
        ClientPrefix.find_by_id(params[:id])
      else
        ClientPrefix.query(
          params[:query],
          client_id: params[:client_id],
          prefix_id: params[:prefix_id],
          year: params[:year],
          page: page,
          sort: sort,
        )
      end

    begin
      total = response.results.total
      total_pages = page[:size].positive? ? (total.to_f / page[:size]).ceil : 0
      years =
        if total.positive?
          facet_by_year(response.response.aggregations.years.buckets)
        end
      providers =
        if total.positive?
          facet_by_combined_key(
            response.response.aggregations.providers.buckets,
          )
        end
      clients =
        if total.positive?
          facet_by_combined_key(response.response.aggregations.clients.buckets)
        end

      client_prefixes = response.results

      options = {}
      options[:meta] = {
        total: total,
        "totalPages" => total_pages,
        page: page[:number],
        years: years,
        providers: providers,
        clients: clients,
      }.compact

      options[:links] = {
        self: request.original_url,
        next:
          if client_prefixes.blank? || page[:number] == total_pages
            nil
          else
            request.base_url + "/client-prefixes?" +
              {
                query: params[:query],
                prefix: params[:prefix],
                year: params[:year],
                "page[number]" => page[:number] + 1,
                "page[size]" => page[:size],
                sort: params[:sort],
              }.compact.
              to_query
          end,
      }.compact
      options[:include] = @include
      options[:is_collection] = true

      render json:
               ClientPrefixSerializer.new(client_prefixes, options).
                 serialized_json,
             status: :ok
    rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
      Raven.capture_exception(e)

      message =
        JSON.parse(e.message[6..-1]).to_h.dig(
          "error",
          "root_cause",
          0,
          "reason",
        )

      render json: { "errors" => { "title" => message } }.to_json,
             status: :bad_request
    end
  end

  def show
    options = {}
    options[:include] = @include
    options[:is_collection] = false

    render json:
             ClientPrefixSerializer.new(@client_prefix, options).
               serialized_json,
           status: :ok
  end

  def create
    @client_prefix = ClientPrefix.new(safe_params)
    authorize! :create, @client_prefix

    if @client_prefix.save
      options = {}
      options[:include] = @include
      options[:is_collection] = false

      render json:
               ClientPrefixSerializer.new(@client_prefix, options).
                 serialized_json,
             status: :created
    else
      # Rails.logger.error @client_prefix.errors.inspect
      render json: serialize_errors(@client_prefix.errors, uid: @client_prefix.uid),
             status: :unprocessable_entity
    end
  end

  def update
    response.headers["Allow"] = "HEAD, GET, POST, DELETE, OPTIONS"
    render json: {
      errors: [{ status: "405", title: "Method not allowed" }],
    }.to_json,
           status: :method_not_allowed
  end

  def destroy
    message = "Client prefix #{@client_prefix.uid} deleted."
    if @client_prefix.destroy
      Rails.logger.warn message
      head :no_content
    else
      # Rails.logger.error @client_prefix.errors.inspect
      render json: serialize_errors(@client_prefix.errors, uid: @client_prefix.uid),
             status: :unprocessable_entity
    end
  end

  protected
    def set_include
      if params[:include].present?
        @include =
          params[:include].split(",").map { |i| i.downcase.underscore.to_sym }
        @include = @include & %i[client prefix provider_prefix provider]
      else
        @include = []
      end
    end

  private
    def set_client_prefix
      @client_prefix = ClientPrefix.where(uid: params[:id]).first
      fail ActiveRecord::RecordNotFound if @client_prefix.blank?
    end

    def safe_params
      ActiveModelSerializers::Deserialization.jsonapi_parse!(
        params,
        only: %i[id client prefix providerPrefix],
        keys: { "providerPrefix" => :provider_prefix },
      )
    end
end
