# frozen_string_literal: true

module Modelable
  extend ActiveSupport::Concern

  delegate :doi_from_url, to: :class
  delegate :orcid_as_url, to: :class
  delegate :orcid_from_url, to: :class

  module ClassMethods
    def doi_from_url(url)
      if %r{\A(?:(http|https)://(dx\.)?(doi.org|handle.test.datacite.org)/)?(doi:)?(10\.\d{4,5}/.+)\z}.
          match?(url)
        uri = Addressable::URI.parse(url)
        uri.path.gsub(%r{^/}, "").downcase
      end
    end

    def orcid_as_url(orcid)
      return nil if orcid.blank?

      "https://orcid.org/#{orcid}"
    end

    def orcid_from_url(url)
      if %r{\A(?:(http|https)://(orcid.org|sandbox.orcid.org)/)(.+)\z}.match?(url)
        uri = Addressable::URI.parse(url)
        uri.path.gsub(%r{^/}, "").upcase
      end
    end
  end
end
