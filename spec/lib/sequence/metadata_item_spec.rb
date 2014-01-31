require "spec_helper"

$count = 0

describe Moe::Sequence::MetadataItem do
  let(:count)      { $count += 1 }
  let(:name)       { "metadata_item_test#{count}" }
  let!(:setup)     { Moe::Sequence.setup name, 2, 5, 10 }
  let(:collection) { Moe::Sequence::Collection.new name, "owner" }
  let(:collector)  { Moe::Sequence::Collector.new  name, "owner" }

  describe "#items" do
    it "returns the associated items" do
      collector.add
      collector.add
      collector.add
      collector.save

      sequences = collection.get_metadata_items

      expect( sequences.first.items.size ).to eq(3)
    end
  end
end
