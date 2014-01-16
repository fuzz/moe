require "spec_helper"

describe Moe::Config do

  describe "config block" do
    it "accepts a configuration block" do
      Moe.configure do |c|
        c.tables = { "foo" => "bar" }
      end

      expect( Moe.config.tables["foo"] ).to eq("bar")
    end

    it "allows configuration changes" do
      Moe.configure do |c|
        c.tables = { "foo" => "bar" }
      end

      Moe.configure do |c|
        c.tables = { "foo" => "star" }
      end

      expect( Moe.config.tables["foo"] ).to eq("star")
    end
  end
end
