require "rails_helper"

describe ProviderType do
  describe "fields" do
    subject { described_class }

    it { is_expected.to have_field(:id).of_type(!types.ID) }
    it { is_expected.to have_field(:type).of_type("String!") }
    it { is_expected.to have_field(:name).of_type("String!") }
    it { is_expected.to have_field(:displayName).of_type("String") }
    it { is_expected.to have_field(:description).of_type("String") }
    it { is_expected.to have_field(:clients).of_type("ClientConnectionWithMeta") }
    it { is_expected.to have_field(:prefixes).of_type("ProviderPrefixConnectionWithMeta") }
    it { is_expected.to have_field(:datasets).of_type("DatasetConnectionWithMeta") }
    it { is_expected.to have_field(:publications).of_type("PublicationConnectionWithMeta") }
    it { is_expected.to have_field(:softwares).of_type("SoftwareConnectionWithMeta") }
    it { is_expected.to have_field(:works).of_type("WorkConnectionWithMeta") }
  end
end
