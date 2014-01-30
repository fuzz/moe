describe Moe::ModuleFunctions do
  let!(:setup) { Moe::Sequence.setup "name", 2, 5, 10 }

  describe ".collection" do
    it "is a convenience method returning a Moe::Sequence::Collection" do
      collection = Moe.collection "name", "owner"

      expect( collection ).to be_a(Moe::Sequence::Collection)
    end
  end

  describe ".collector" do
    it "is a convenience method returning a Moe::Sequence::Collector" do
      collector = Moe.collector "name", "owner"

      expect( collector ).to be_a(Moe::Sequence::Collector)
    end
  end
end
