require "spec_helper"

$count = 0

describe Moe::Dyna do
  let(:count)           { $count += 1 }
  let(:dyna)            { Moe::Dyna.new }
  let(:dynamodb)        { Aws.dynamodb }
  let(:item)            { { "hash" => "test#{count}" } }
  let(:dynamo_item)     { dyna.explode(item) }
  let(:created_tables)  { dyna.create_table("Testy#{count}") }
  let(:table)           { dyna.find(created_tables.first).table }

  describe "#batch_write_item" do
    it "writes a batch of items" do

      items = dyna.batch_write_item [table.table_name], [item, { "hash" => "zoo" }]
      result = dyna.get_item [table.table_name], { "hash" => { s: "zoo" } }

      expect( result["hash"]["s"] ).to eq("zoo")
    end
  end

  describe "#create_table" do
    it "creates a new table" do
      new_table = dyna.create_table "Testy#{count}"

      expect(
        dynamodb.list_tables.table_names.include? "Testy#{count}_1"
      ).to be_true
    end

    it "creates as many copies of a table as requested" do
      new_tables = dyna.create_table "Testie#{count}", 5

      expect(
        dynamodb.list_tables.table_names.include? "Testie#{count}_1"
      ).to be_true

      expect(
        dynamodb.list_tables.table_names.include? "Testie#{count}_5"
      ).to be_true
    end
  end

  describe "#explode" do
    it "returns a DynamoDB-flavored hash given a plain hash" do
      expect(
        dyna.explode({ "foo" => "bar" })
      ).to eq({"foo" => { s: "bar" } })
    end
  end

  describe "#get_item" do
    it "gets an item" do
      dynamodb.put_item table_name: table.table_name, item: dynamo_item
      result = dyna.get_item [table.table_name], dynamo_item

      expect( result["hash"]["s"] ).to eq("test#{count}")
    end

    it "gets an item across multiple tables" do
      dynamodb.put_item table_name: table.table_name, item: dynamo_item
      empty_table = dyna.create_table "Testy#{count}_empty"
      result      = dyna.get_item [table.table_name, "Testy#{count}_empty_1"], dynamo_item

      expect( result["hash"]["s"] ).to eq("test#{count}")
    end
  end

  describe "#implode" do
    it "returns a plain hash given a DynamoDB-flavored hash" do
      expect(
        dyna.implode({"foo" => { s: "bar" } })
      ).to eq({ "foo" => "bar" })
    end
  end

  describe "#find" do
    it "finds a table" do
      dyna.create_table "Testy#{count}"

      expect(
        dyna.find("Testy#{count}_1").table.table_name
      ).to match("Testy#{count}")
    end

    it "returns false if it does not find a table" do
      expect(
        dyna.find "nope"
      ).to be_false
    end
  end

  describe "#put_item" do
    it "puts an item" do
      dyna.put_item [table.table_name], item

      expect(
        dynamodb.get_item(table_name: table.table_name, key: dynamo_item).item["hash"]["s"]
      ).to eq("test#{count}")
    end

    it "puts an item to multiple tables" do
      mirror_tables = dyna.create_table "Testie#{count}", 2
      dyna.put_item ["Testie#{count}_1", "Testie#{count}_2"], item

      expect(
        dynamodb.get_item(table_name: "Testie#{count}_1", key: dynamo_item).item["hash"]["s"]
      ).to eq(dynamodb.get_item(table_name: "Testie#{count}_2", key: dynamo_item).item["hash"]["s"])
    end
  end
end
