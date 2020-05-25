require "rails_helper"

describe Event, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }
  
  context "event" do
    subject { create(:event) }

    it { is_expected.to validate_presence_of(:subj_id) }
    it { is_expected.to validate_presence_of(:source_token) }
    it { is_expected.to validate_presence_of(:source_id) }

    it "has subj" do
      expect(subject.subj["datePublished"]).to eq("2006-06-13T16:14:19Z")
    end
  end

  context "citation" do
    subject { create(:event_for_datacite_related, subj_id: "https://doi.org/10.5061/dryad.47sd5e/2") }

    it "has citation_id" do
      expect(subject.citation_id).to eq("https://doi.org/10.5061/dryad.47sd5/1-https://doi.org/10.5061/dryad.47sd5e/2")
    end

    it "has citation_year" do
      expect(subject.citation_year).to eq(2015)
    end

    let(:doi) { create(:doi) }

    it "date_published from the database" do
      published = subject.date_published("https://doi.org/" + doi.doi)
      expect(published).to eq("2011")
      expect(published).not_to eq(2011)
    end

    it "label_state_event with not existent prefix" do
      expect(Event.find_by(uuid: subject.uuid ).state_event).to be_nil
      Event.label_state_event({uuid:subject.uuid , subj_id:subject.subj_id})
      expect(Event.find_by(uuid: subject.uuid ).state_event).to eq("crossref_citations_error")
    end

    context "prefix exists, then dont to change" do
      let!(:prefix) { create(:prefix, uid: "10.5061") }
      it "label_state_event with  existent prefix" do
        expect(Event.find_by(uuid: subject.uuid ).state_event).to be_nil
        Event.label_state_event({uuid:subject.uuid , subj_id:subject.subj_id})
        expect(Event.find_by(uuid: subject.uuid ).state_event).to be_nil
      end
    end

    # context "double_crossref_check", elasticsearch: true do
    #   let(:provider) { create(:provider, symbol: "DATACITE") }
    #   let(:client) { create(:client, provider: provider, symbol: ENV['MDS_USERNAME'], password: ENV['MDS_PASSWORD']) }
    #   let!(:prefix) { create(:prefix, prefix: "10.14454") }
    #   let!(:client_prefix) { create(:client_prefix, client: client, prefix: prefix) }
    #   let!(:doi) { create(:doi, client: client) }
    #   let!(:dois)  { create_list(:doi, 10) }
    #   let!(:events) { create_list(:event_for_datacite_related, 30, source_id: "datacite-crossref", obj_id: doi.doi) }
 
    #   before do
    #     Provider.import
    #     Client.import
    #     Doi.import
    #     Event.import
    #     sleep 3
    #   end
      
    #   it "check run" do
    #     expect(Event.subj_id_check(cursor: [Event.minimum(:id),Event.maximum(:id)])).to eq(true)
    #   end
    # end
  end

  describe "camelcase_nested_objects" do
    subject { create(:event_for_datacite_related) }

    it "should transform keys" do
      Event.camelcase_nested_objects(subject.uuid)
      expect(subject.subj.keys).to include("datePublished", "registrantId", "id")
    end
  end
end
