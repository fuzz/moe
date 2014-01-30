require "spec_helper"

describe Moe::Sequence::Locksmith::ModuleFunctions do
  describe ".itemize" do
    it "returns a hash" do
      item = Moe::Sequence::Locksmith.itemize 1,2,3,4

      expect( item ).to be_a(Hash)
    end
  end

  describe ".key" do
    it "also returns a hash" do
      key = Moe::Sequence::Locksmith.key 1,2,3

      expect( key ).to be_a(Hash)
    end
  end
end