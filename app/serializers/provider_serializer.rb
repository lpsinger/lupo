class ProviderSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  set_type :providers
  set_id :uid
  # cache_options enabled: true, cache_length: 24.hours ### we cannot filter if we cache

  attributes :name, :symbol, :website, :contact_name, :contact_email, :phone, :description, :region, :country, :logo_url, :organization_type, :focus_area, :is_active, :has_password, :joined, :twitter_handle, :billing_information, :ror_id, :general_contact, :technical_contact, :service_contact, :voting_contact, :created, :updated

  has_many :prefixes, record_type: :prefixes

  attribute :country do |object|
    object.country_code
  end

  attribute :is_active do |object|
    object.is_active.getbyte(0) == 1 ? true : false
  end

  attribute :has_password do |object|
    object.password.present?
  end

  attribute :billing_information, if: Proc.new { |object, params| params[:current_ability] && params[:current_ability].can?(:read_billing_information, object) == true } do |object|
    object.billing_information.present? ? object.billing_information.transform_keys!{ |key| key.to_s.camelcase(:lower) } : {}
  end

  attribute :twitter_handle, if: Proc.new { |object, params| params[:current_ability] && params[:current_ability].can?(:read_billing_information, object) == true } do |object|
    object.twitter_handle
  end

  # Convert all contacts json models back to json style camelCase
  attribute :general_contact do |object|
    object.general_contact.present? ? object.general_contact.transform_keys!{ |key| key.to_s.camelcase(:lower) } : {}
  end

  attribute :technical_contact do |object|
    object.technical_contact.present? ? object.technical_contact.transform_keys!{ |key| key.to_s.camelcase(:lower) } : {}
  end

  attribute :service_contact do |object|
    object.service_contact.present? ? object.service_contact.transform_keys!{ |key| key.to_s.camelcase(:lower) } : {}
  end

  attribute :voting_contact do |object|
    object.voting_contact.present? ? object.voting_contact.transform_keys!{ |key| key.to_s.camelcase(:lower) } : {}
  end
end
