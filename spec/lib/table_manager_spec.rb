require "spec_helper"

describe Moe::TableManager do
  let(:manager) { Moe::TableManager.new }

  describe "#initialize" do
    it "creates itself a table if one does not exist" do
      new_manager = Moe::TableManager.new

      expect(
        Moe::Table.find(new_manager.meta_table_name).table.table_name
      ).to eq(new_manager.meta_table_name)
    end
  end

  describe "#create" do
    it "creates a table for a given model" do
      manager.create(model: "testmodel")

      expect(
        Moe::Table.find(manager.table_name "testmodel").table.table_name
      ).to match("testmodel")
    end

    it "munges model names into a DynamoDB-approved format" do
      manager.create(model: "Testy::Model")

      expect(
        Moe::Table.find(manager.table_name "testy_model").table.table_name
      ).to match("testy_model")
    end
  end

  describe "#meta_table_name" do
    it "includes the RAILS_ENV if one exists" do
      ENV["RAILS_ENV"] = "test"

      expect( manager.meta_table_name ).to match("test_manager")
    end

    it "does not mind if there is no RAILS_ENV" do
      ENV["RAILS_ENV"] = ""

      expect( manager.meta_table_name ).to match("manager")
    end
  end

  describe "#table_name" do
    it "includes the RAILS_ENV if one exists" do
      ENV["RAILS_ENV"] = "test"

      expect( manager.table_name("tetsuo") ).to match("_test_")
    end

    it "does not mind if there is no RAILS_ENV" do
      ENV["RAILS_ENV"] = ""

      expect( manager.table_name("tetsuo") ).to match("tetsuo")
    end

    it "includes the date" do
      expect( manager.table_name("tetsuo") ).to match(manager.date)
    end
  end

  describe "#update_metadata" do
    it "updates the metadata" do
      manager.update_metadata(model: "testie")
      result = Moe::Table.get_item(table_name: manager.meta_table_name, key: { "id" => { s: "testie" } })

      expect(
        result.item["write_table"]["s"]
      ).to match("testie")
    end
  end

end
