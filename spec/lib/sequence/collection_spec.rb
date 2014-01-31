require "spec_helper"

$count = 0

describe Moe::Sequence::Collection do
  let(:count)      { $count += 1 }
  let(:name)       { "collection_test#{count}" }
  let!(:setup)     { Moe::Sequence.setup name, 2, 5, 10 }
  let(:collection) { Moe::Sequence::Collection.new name, "owner" }
  let(:collector)  { Moe::Sequence::Collector.new  name, "owner" }

  describe "#metadata_items" do
    it "gets all metadata items for a given owner" do
      collector.save({ "foo" => "bar" })

      expect(
        collection.metadata_items.first.payload
      ).to eq({ "foo" => "bar"})
    end
  end
end
