require "spec_helper"

describe Moe::Serializers::Commafy do
  describe ".dump" do
    it "returns a comma-delimited list given an array" do
      list = Moe::Serializers::Commafy.dump ["a", "b", "c"]

      expect( list ).to eq("a,b,c")
    end
  end

  describe ".load" do
    it "returns an array given a comma-delimited list" do
      array = Moe::Serializers::Commafy.load "a,b,c"

      expect( array ).to eq(["a", "b", "c"])
    end
  end
end
