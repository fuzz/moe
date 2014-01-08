require "spec_helper"

$count = 0

describe Moe::Table do
  let(:count) { $count += 1 }
  let(:dynamodb) { Aws.dynamodb }
  let(:table) { Moe::Table.create name: "Testy#{count}" }

  describe ".create" do
    it "creates a new table" do
      new_table = Moe::Table.create name: "Testy#{count}"

      expect(
        dynamodb.list_tables.table_names.include? "Testy#{count}"
      ).to be_true
    end
  end

  describe ".find" do
    it "finds a table" do
      Moe::Table.create name: "Testy#{count}"

      expect(
        Moe::Table.find("Testy#{count}").table.table_name
      ).to eq "Testy#{count}"
    end
  end
end
