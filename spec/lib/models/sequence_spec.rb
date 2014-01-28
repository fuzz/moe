require "spec_helper"

$count = 0

describe Moe::Models::Sequence do
  let(:count)  { $count += 1 }
  let(:dyna)   { Moe::Dyna.new }
  let(:name)   { "seq_test#{count}" }
  let!(:setup) { Moe::Models::Sequence.setup name, 2, 5, 10 }
  let(:seq)    { Moe::Models::Sequence.new name, "owner" }

  describe Moe::Models::Sequence::ClassMethods do
    describe ".setup" do
      it "creates a table using the name provided" do
        Moe.configure do |c|
          c.tables = {}
        end

        Moe::Models::Sequence.setup "seq_setup_test", 1, 5, 10

        expect(
          Aws.dynamodb.list_tables.table_names.join
        ).to match("seq_setup_test")
      end

      it "skips creating a table if one is already configured" do
        Moe.configure do |c|
          c.tables = { "seq_skip_test" => [] }
        end

        expect(
          Moe::Models::Sequence.setup "seq_skip_test", 1, 5, 10
        ).to match("already exists")
      end
    end
  end

  describe "#initialize" do
    it "initializes an item array" do
      expect( seq.payloads ).to be_an(Array)
    end
  end

  describe "#add" do
    it "adds an item to the payloads array" do
      seq.add({ "bar" => "baz" })

      expect( seq.payloads.first["bar"] ).to eq("baz")
    end

    it "does not flush before it hits the batch limit" do
      1.upto(10) do |i|
        seq.add
      end

      result = dyna.get_item seq.read_tables, { "hash"  => { s: "owner" },
                                                "range" => { s: "10.#{seq.uuid}" } }

      expect( result ).to be_nil
    end

    it "flushes when it hits the batch limit" do
      1.upto(15) do |i|
        seq.add
      end

      result = dyna.get_item seq.read_tables, { "hash"  => { s: "owner" },
                                                "range" => { s: "15.#{seq.uuid}" } }

      expect( result["hash"]["s"] ).to eq("owner")
    end

    it "increments the flushed counter when it flushes" do
      1.upto(15) do |i|
        seq.add
      end

      expect( seq.flushed_count ).to eq(15)
    end

    it "initializes a v4 uuid" do
      seq.add

      expect(
        seq.uuid
      ).to match(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/)
    end
  end

  describe "#get_items" do
    it "gets all items for a given uuid" do
      seq.add
      seq.add
      seq.save

      metadata = seq.get_metadata_items

      items = seq.get_items metadata.first.first,
                            metadata.first.last.first["range"].gsub(/0\./, ""),
                            metadata.first.last.first["count"]

      expect( items.size ).to eq(2)
    end
  end

  describe "#get_metadata_items" do
    it "gets all metadata items for a given owner" do
      seq.save({ "foo" => "bar" })

      expect(
        MultiJson.load seq.get_metadata_items.first.last.first["payload"]
      ).to eq({ "foo" => "bar"})
    end
  end

  describe "#save" do
    it "persists a metadata item" do
      seq.add
      seq.save

      result = dyna.get_item seq.read_tables, { "hash"  => { s: "owner" },
                                                "range" => { s: "0.#{seq.uuid}" } }

      expect( result["hash"]["s"] ).to eq("owner")
    end
  end
end
