require "spec_helper"

$count = 0

describe Moe::Table do
  let(:count) { $count += 1 }
  let(:dynamodb) { Aws.dynamodb }
  let(:item) { { "id" => { s: "test#{count}" } } }
  let(:table) { Moe::Table.create "Testy#{count}" }

  describe ".create" do
    it "creates a new table" do
      new_table = Moe::Table.create "Testy#{count}"

      expect(
        dynamodb.list_tables.table_names.include? "Testy#{count}"
      ).to be_true
    end
  end

  describe ".get_item" do
    it "gets an item" do
      dynamodb.put_item table_name: table.table_name, item: item
      result = Moe::Table.get_item table.table_name, item

      expect(
        result.item["id"]["s"]
      ).to eq("test#{count}")
    end
  end

  describe ".find" do
    it "finds a table" do
      Moe::Table.create "Testy#{count}"

      expect(
        Moe::Table.find("Testy#{count}").table.table_name
      ).to eq "Testy#{count}"
    end
  end

  describe ".put_item" do
    it "puts an item" do
      Moe::Table.put_item table.table_name, item

      expect(
        dynamodb.get_item(table_name: table.table_name, key: item).item["id"]["s"]
      ).to eq("test#{count}")
    end
  end

end
