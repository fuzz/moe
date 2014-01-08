require "spec_helper"

$count = 0

describe Moe::Table do
  let(:count) { $count += 1 }
  let(:dynamodb) { Aws.dynamodb }

  describe "#create" do
    it "creates a new table" do
      table = Moe::Table.create name: "Testy"

      expect(
        dynamodb.list_tables.table_names.include? "Testy"
      ).to be_true
    end
  end
end
