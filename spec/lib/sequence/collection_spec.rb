require "spec_helper"

$count = 0

describe Moe::Sequence do
  let(:count)      { $count += 1 }
  let(:name)       { "collection_test#{count}" }
  let!(:setup)     { Moe::Sequence.setup name, 2, 5, 10 }
  let(:collection) { Moe::Sequence::Collection.new name, "owner" }
  let(:collector)  { Moe::Sequence::Collector.new  name, "owner" }

  describe Moe::Sequence::Collection do
    describe "#get_items" do
      it "gets all items for a given uuid" do
        collector.add
        collector.add
        collector.save

        metadata = collection.get_metadata_items

        items = collection.get_items metadata.first.first,
                  metadata.first.last.first["range"].gsub(/0\./, ""),
                  metadata.first.last.first["count"]

        expect( items.size ).to eq(2)
      end
    end

    describe "#get_metadata_items" do
      it "gets all metadata items for a given owner" do
        collector.save({ "foo" => "bar" })

        expect(
          MultiJson.load collection.get_metadata_items.first.last.first["payload"]
        ).to eq({ "foo" => "bar"})
      end
    end
  end
end