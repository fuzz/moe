require "spec_helper"

$count = 0

describe Moe::Sequence do
  let(:count)      { $count += 1 }
  let(:dyna)       { Moe::Dyna.new }
  let(:name)       { "collector_test#{count}" }
  let!(:setup)     { Moe::Sequence.setup name, 2, 5, 10 }
  let(:collection) { Moe::Sequence::Collection.new name, "owner" }
  let(:collector)  { Moe::Sequence::Collector.new  name, "owner" }

  describe Moe::Sequence::Collection do
    describe "#initialize" do
      it "initializes an item array" do
        expect( collector.payloads ).to be_an(Array)
      end
    end

    describe "#add" do
      it "adds an item to the payloads array" do
        collector.add({ "bar" => "baz" })

        expect( collector.payloads.first["bar"] ).to eq("baz")
      end

      it "does not flush before it hits the batch limit" do
        1.upto(10) do |i|
          collector.add
        end

        result = dyna.get_item collection.read_tables, { "hash"  => { s: "owner" },
                                                         "range" => { s: "10.#{collector.uuid}" } }

        expect( result ).to be_nil
      end

      it "flushes when it hits the batch limit" do
        1.upto(15) do |i|
          collector.add
        end

        result = dyna.get_item collection.read_tables, { "hash"  => { s: "owner" },
                                                         "range" => { s: "15.#{collector.uuid}" } }

        expect( result["hash"]["s"] ).to eq("owner")
      end

      it "increments the flushed counter when it flushes" do
        1.upto(15) do |i|
          collector.add
        end

        expect( collector.flushed_count ).to eq(15)
      end

      it "resets the payloads array when it flushes" do
        1.upto(15) do |i|
          collector.add
        end

        expect( collector.payloads.size ).to eq(0)
      end

      it "initializes a v4 uuid" do
        collector.add

        expect(
          collector.uuid
        ).to match(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/)
      end
    end
  end
end