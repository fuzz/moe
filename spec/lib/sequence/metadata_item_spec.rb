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
      1.upto(1000) do
        collector.add
      end
      collector.save

      sequences = collection.metadata_items

      expect( sequences.first.items.size ).to eq(1000)
    end
  end
end
