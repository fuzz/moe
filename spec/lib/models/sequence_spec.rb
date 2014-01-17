require "spec_helper"

$count = 0

describe Moe::Models::Sequence do
  let(:count)  { $count += 1 }
  let(:dyna)   { Moe::Dyna.new }
  let(:name)   { "seq_test#{count}" }
  let!(:setup) { Moe::Models::Sequence.setup(name, 2, 5, 10) }
  let(:seq)    { Moe::Models::Sequence.new name }

  describe Moe::Models::Sequence::ClassMethods do
    describe ".setup" do
      it "creates a table using the name provided" do
        Moe.configure do |c|
          c.tables = {}
        end

        Moe::Models::Sequence.setup("seq_setup_test", 1, 5, 10)

        expect(
          Aws.dynamodb.list_tables.table_names.join
        ).to match("seq_setup_test")
      end

      it "skips creating a table if one is already configured" do
        Moe.configure do |c|
          c.tables = { "seq_skip_test" => [] }
        end

        expect(
          Moe::Models::Sequence.setup("seq_skip_test", 1, 5, 10)
        ).to match("already exists")
      end
    end
  end

  describe "#initialize" do
    it "initializes an item array" do
      expect( seq.items ).to be_an(Array)
    end
  end

  describe "#add" do
    it "adds an item to the item array" do
      seq.add({ "bar" => "baz" })

      expect( seq.items.first["bar"] ).to eq("baz")
    end

    it "does not flush before it hits the batch limit" do
      1.upto(10) do |i|
        seq.add({ "id" => { s: "batz#{i}" } })
      end

      result = dyna.get_item seq.read_tables, { "id" => { s: "batz10" } }

      expect( result ).to be_nil
    end

    it "flushes when it hits the batch limit" do
      1.upto(15) do |i|
        seq.add({ "id" => { s: "baz#{i}" } })
      end

      result = dyna.get_item seq.read_tables, { "id" => { s: "baz15" } }

      expect(
        result["id"]["s"]
      ).to eq("baz15")
    end
  end
end