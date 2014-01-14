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

  describe "#build" do
    it "creates a table for a given model" do
      manager.build "build_test"

      expect(
        Moe::Table.find(manager.table_name "build_test_1").table.table_name
      ).to match("build_test")
    end

    it "creates a mirror table if requested" do
      manager.build "mirror_test", 2

      expect(
        Moe::Table.find("#{manager.table_name('mirror_test')}_2").table.table_name
      ).to match("mirror_test_2")
    end

    it "does not create a mirror table if not requested" do
      manager.build "false_mirror_test"

      expect(
        Moe::Table.find("#{manager.table_name('false_mirror_test')}_mirror")
      ).to be_nil
    end

    it "munges model names into a DynamoDB-approved format" do
      manager.build "Testy::Model"

      expect(
        Moe::Table.find(manager.table_name "testy_model_1").table.table_name
      ).to match("testy_model")
    end
  end

  describe "#increment" do
    it "increments the table" do
      manager.build "increment_test"

      Timecop.freeze(Date.today + 30) do
        frozen_manager = Moe::TableManager.new

        frozen_manager.increment "increment_test"
      end
    end

    it "pitches a fit if run twice on the same day" do
      manager.build "fit_test"

      expect { manager.increment "fit_test" }.to raise_error
    end
  end

  describe "#load_metadata" do
    it "loads metadata for a model" do
      manager.update_metadata "load_metadata_test",
                              ["load_metadata_test"],
                              ["load_metadata_test"],
                              "5",
                              "10"

      expect(
        manager.load_metadata("load_metadata_test").item["write_tables"]["ss"].first
      ).to match("load_metadata_test")
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
      manager.update_metadata "testie",
                              ["testie"],
                              ["testie"],
                              "5",
                              "10"

      result = Moe::Table.get_item manager.meta_table_name,
                                   { "id" => { s: "testie" } }

      expect(
        result.item["write_tables"]["ss"].first
      ).to match("testie")
    end
  end

end
