require 'rails_helper'

describe DataciteDoi, type: :model, vcr: true do
  it_behaves_like "an STI class"

  describe "import_by_ids", elasticsearch: true do
    let(:provider)  { create(:provider) }
    let(:client)  { create(:client, provider: provider) }
    let(:target) { create(:client, provider: provider, symbol: provider.symbol + ".TARGET", name: "Target Client") }
    let!(:dois) { create_list(:doi, 3, client: client, aasm_state: "findable", type: "DataciteDoi") }
    let(:doi) { dois.first }

    it "import by ids" do
      response = DataciteDoi.import_by_ids
      expect(response).to be > 0
    end

    it "import by id" do
      response = DataciteDoi.import_by_id(id: doi.id)
      expect(response).to eq(3)
    end
  end
end
