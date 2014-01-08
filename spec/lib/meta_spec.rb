require "spec_helper"

describe Moe::Meta do
  describe "#initialize" do
    it "creates itself a table if one does not exist" do
      meta = Moe::Meta.new

      expect(
        Moe::Table.find(meta.table_name).table.table_name
      ).to eq(meta.table_name)
    end
  end

  describe "#table_name" do
    it "prepends the RAILS_ENV if one exists" do
      ENV["RAILS_ENV"] = "test"
      meta = Moe::Meta.new

      expect( meta.table_name ).to eq("testmeta")
    end

    it "does not mind if there is no RAILS_ENV" do
      ENV["RAILS_ENV"] = ""
      meta = Moe::Meta.new

      expect( meta.table_name ).to eq("meta")
    end
  end
end
