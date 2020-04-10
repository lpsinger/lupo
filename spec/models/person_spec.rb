require 'rails_helper'

describe Person, type: :model, vcr: true do
  describe "find_by_id" do
    it "found" do
      id = "https://orcid.org/0000-0003-2706-4082"
      people = Person.find_by_id(id)
      expect(people[:data].size).to eq(1)
      person = people[:data].first
      expect(person.id).to eq("https://orcid.org/0000-0003-2706-4082")
      expect(person.name).to eq("Agnes Ebenberger")
      expect(person.given_name).to eq("Agnes")
      expect(person.family_name).to eq("Ebenberger")
    end

    it "also found" do
      id = "https://orcid.org/0000-0003-3484-6875"
      people = Person.find_by_id(id)
      expect(people[:data].size).to eq(1)
      person = people[:data].first
      expect(person.id).to eq("https://orcid.org/0000-0003-3484-6875")
      expect(person.name).to eq("K. J. Garza")
      expect(person.given_name).to eq("Kristian")
      expect(person.family_name).to eq("Garza")
    end

    it "not found" do
      id = "https://orcid.org/xxxxx"
      people = Person.find_by_id(id)
      expect(people[:data]).to be_nil
      expect(people[:errors]).to be_nil
    end
  end

  describe "query" do
    it "found all" do
      query = "*"
      people = Person.query(query)
      expect(people.dig(:meta, "total")).to eq(8522184)
      expect(people.dig(:data).size).to eq(25)
      person = people[:data].first
      expect(person.id).to eq("https://orcid.org/0000-0003-3995-3004")
      expect(person.name).to eq("Letícia Rodrigues Bueno")
      expect(person.given_name).to eq("Letícia Rodrigues")
      expect(person.family_name).to eq("Bueno")
      expect(person.affiliation).to eq([{"name"=>"Universidade Estadual de Maringá"},
        {"name"=>"Universidade Federal do ABC"},
        {"name"=>"Universidade Federal do Rio de Janeiro"}])
    end

    it "found miller" do
      query = "miller"
      people = Person.query(query)
      expect(people.dig(:meta, "total")).to eq(7089)
      expect(people.dig(:data).size).to eq(25)
      person = people[:data].first
      expect(person.id).to eq("https://orcid.org/0000-0002-2131-0054")
      expect(person.name).to eq("Edmund Miller")
      expect(person.given_name).to eq("Edmund")
      expect(person.family_name).to eq("Miller")
      expect(person.affiliation).to eq([{"name"=>"Feinstein Institute for Medical Research"},
        {"name"=>"Hofstra Northwell School of Medicine at Hofstra University"},
        {"name"=>"King's College London"},
        {"name"=>"University of Texas Health Northeast"}])
    end

    it "found datacite" do
      query = "datacite"
      people = Person.query(query)
      expect(people.dig(:meta, "total")).to eq(15163)
      expect(people.dig(:data).size).to eq(25)
      person = people[:data].first
      expect(person.id).to eq("https://orcid.org/0000-0002-9300-5278")
      expect(person.name).to eq("Patricia Cruse")
      expect(person.given_name).to eq("Patricia")
      expect(person.family_name).to eq("Cruse")
      expect(person.affiliation).to eq([{"name"=>"DataCite"}, {"name"=>"University of California Berkeley"}])
    end
  end
end
