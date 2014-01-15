require "spec_helper"

$count = 0

describe Moe::Table do
  let(:count) { $count += 1 }
  let(:dynamodb) { Aws.dynamodb }
  let(:item) { { "id" => { s: "test#{count}" } } }
  let(:created_tables) { Moe::Table.create("Testy#{count}") }
  let(:table) { Moe::Table.find(created_tables.first).table }

  describe ".create" do
    it "creates a new table" do
      new_table = Moe::Table.create "Testy#{count}"

      expect(
        dynamodb.list_tables.table_names.include? "Testy#{count}_1"
      ).to be_true
    end

    it "creates as many copies of a table as requested" do
      new_tables = Moe::Table.create "Testie#{count}", 5

      expect(
        dynamodb.list_tables.table_names.include? "Testie#{count}_1"
      ).to be_true

      expect(
        dynamodb.list_tables.table_names.include? "Testie#{count}_5"
      ).to be_true
    end
  end

  describe ".get_item" do
    it "gets an item" do
      dynamodb.put_item table_name: table.table_name, item: item
      result = Moe::Table.get_item [table.table_name], item

      expect(
        result["id"]["s"]
      ).to eq("test#{count}")
    end

    it "gets an item across multiple tables" do
      dynamodb.put_item table_name: table.table_name, item: item
      empty_table = Moe::Table.create "Testy#{count}_empty"
      result      = Moe::Table.get_item [table.table_name, "Testy#{count}_empty_1"], item

      expect(
        result["id"]["s"]
      ).to eq("test#{count}")
    end
  end

  describe ".find" do
    it "finds a table" do
      Moe::Table.create "Testy#{count}"

      expect(
        Moe::Table.find("Testy#{count}_1").table.table_name
      ).to match("Testy#{count}")
    end
  end

  describe ".put_item" do
    it "puts an item" do
      Moe::Table.put_item [table.table_name], item

      expect(
        dynamodb.get_item(table_name: table.table_name, key: item).item["id"]["s"]
      ).to eq("test#{count}")
    end

    it "puts an item to multiple tables" do
      mirror_tables = Moe::Table.create "Testie#{count}", 2
      Moe::Table.put_item ["Testie#{count}_1", "Testie#{count}_2"], item

      expect(
        dynamodb.get_item(table_name: "Testie#{count}_1", key: item).item["id"]["s"]
      ).to eq(dynamodb.get_item(table_name: "Testie#{count}_2", key: item).item["id"]["s"])
    end
  end
end
