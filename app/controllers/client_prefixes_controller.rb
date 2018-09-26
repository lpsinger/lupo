require 'base32/url'
require 'uri'

class ClientPrefixesController < ApplicationController
  before_action :set_client_prefix, only: [:show, :update, :destroy]
  before_action :authenticate_user!
  before_action :set_include
  load_and_authorize_resource :except => [:index, :show, :set_created, :set_provider]

  def index
    # support nested routes
    if params[:id].present?
      collection = ClientPrefix.where(id: params[:id])
    elsif params[:client_id].present? && params[:prefix_id].present?
      collection = ClientPrefix.joins(:client, :prefix).where('datacentre.symbol = ?', params[:client_id]).where('prefix.prefix = ?', params[:prefix_id])
    elsif params[:client_id].present?
      client = Client.where('datacentre.symbol = ?', params[:client_id]).first
      collection = client.present? ? client.client_prefixes.joins(:prefix) : ClientPrefix.none
    elsif params[:prefix_id].present?
      prefix = Prefix.where('prefix.prefix = ?', params[:prefix_id]).first
      collection = prefix.present? ? prefix.client_prefixes.joins(:client) : ClientPrefix.none
    else
      collection = ClientPrefix.joins(:client, :prefix)
    end

    collection = collection.query(params[:query]) if params[:query].present?
    collection = collection.where('YEAR(datacentre_prefixes.created_at) = ?', params[:year]) if params[:year].present?

    if params[:year].present?
      years = [{ id: params[:year],
                 title: params[:year],
                 count: collection.where('YEAR(datacentre_prefixes.created_at) = ?', params[:year]).count }]
    else
      years = collection.where.not(prefixes: nil).order("YEAR(datacentre_prefixes.created_at) DESC").group("YEAR(datacentre_prefixes.created_at)").count
      years = years.map { |k,v| { id: k.to_s, title: k.to_s, count: v } }
    end

    # pagination
    page = params[:page] || {}
    page[:number] = page[:number] && page[:number].to_i > 0 ? page[:number].to_i : 1
    page[:size] = page[:size] && (1..1000).include?(page[:size].to_i) ? page[:size].to_i : 25
    total = collection.count

    order = case params[:sort]
            when "name" then "prefix.prefix"
            when "-name" then "prefix.prefix DESC"
            when "created" then "datacentre_prefixes.created_at"
            else "datacentre_prefixes.created_at DESC"
            end

    @client_prefixes = collection.order(order).page(page[:number]).per(page[:size])

    options = {}
    options[:meta] = {
      total: total,
      "total-pages" => @client_prefixes.total_pages,
      page: page[:number].to_i,
      years: years
    }.compact

    options[:links] = {
      self: request.original_url,
      next: @client_prefixes.blank? ? nil : request.base_url + "/client-prefixes?" + {
        query: params[:query],
        year: params[:year],
        "page[number]" => params.dig(:page, :number).to_i + 1,
        "page[size]" => params.dig(:page, :size),
        sort: params[:sort] }.compact.to_query
      }.compact
    options[:include] = @include
    options[:is_collection] = true

    render json: ClientPrefixSerializer.new(@client_prefixes, options).serialized_json, status: :ok
  end

  def show
    options = {}
    options[:include] = @include
    options[:is_collection] = false

    render json: ClientPrefixSerializer.new(@client_prefix, options).serialized_json, status: :ok
  end

  def create
    logger = Logger.new(STDOUT)
    @client_prefix = ClientPrefix.new(safe_params)
    authorize! :create, @client_prefix

    if @client_prefix.save
      options = {}
      options[:include] = @include
      options[:is_collection] = false
  
      render json: ClientPrefixSerializer.new(@client_prefix, options).serialized_json, status: :created
    else
      logger.warn @client_prefix.errors.inspect
      render json: serialize(@client_prefix.errors), status: :unprocessable_entity
    end
  end

  def update
    response.headers["Allow"] = "HEAD, GET, POST, DELETE, OPTIONS"
    render json: { errors: [{ status: "405", title: "Method not allowed" }] }.to_json, status: :method_not_allowed
  end

  def destroy
    @client_prefix.destroy
    head :no_content
  end

  def set_created
    authorize! :update, ClientPrefix
    ClientPrefix.where(created_at: nil).find_each do |cp|
      cp.update_column(:created_at, cp.prefix.created)
    end
    render json: { message: "Client prefix created timestamp added." }.to_json, status: :ok
  end

  def set_provider
    authorize! :update, ClientPrefix
    ClientPrefix.where(allocator_prefixes: nil).find_each do |cp|
      cp.send(:set_allocator_prefixes)
      cp.save
    end
    render json: { message: "Client prefix associated provider prefix added." }.to_json, status: :ok
  end

  protected

  def set_include
    if params[:include].present?
      @include = params[:include].split(",").map { |i| i.downcase.underscore.to_sym }
      @include = @include & [:client, :prefix, :provider_prefix, :provider]
    else
      # always include because Ember pagination doesn't (yet) understand include parameter
      @include = [:client, :prefix, :provider_prefix, :provider]
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client_prefix
    id = Base32::URL.decode(URI.decode(params[:id]))
    fail ActiveRecord::RecordNotFound unless id.present?

    @client_prefix = ClientPrefix.where(id: id.to_i).first

    fail ActiveRecord::RecordNotFound unless @client_prefix.present?
  end

  def safe_params
    puts params
    ActiveModelSerializers::Deserialization.jsonapi_parse!(
      params, only: [:id, :client, :prefix, :provider_prefix]
    )
  end
end
