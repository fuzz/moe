require "spec_helper"

describe Moe::TableManager do
  describe "#initialize" do
    it "creates itself a table if one does not exist" do
      manager = Moe::TableManager.new

      expect(
        Moe::Table.find(manager.table_name).table.table_name
      ).to eq(manager.table_name)
    end
  end

  describe "#name" do
    it "prepends the RAILS_ENV if one exists" do
      ENV["RAILS_ENV"] = "test"
      manager = Moe::TableManager.new

      expect( manager.table_name ).to eq("testmanager")
    end

    it "does not mind if there is no RAILS_ENV" do
      ENV["RAILS_ENV"] = ""
      manager = Moe::TableManager.new

      expect( manager.table_name ).to eq("manager")
    end
  end
end
