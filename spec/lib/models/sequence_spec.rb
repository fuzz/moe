require "spec_helper"

describe Moe::Models::Sequence do
  describe Moe::Models::Sequence::ClassMethods do
    describe ".setup" do
      it "creates a table using the name provided" do
        Moe.configure do |c|
          c.tables = {}
        end

        Moe::Models::Sequence.setup("seq_setup_test", 1, 5, 10)

        expect(
          Aws.dynamodb.list_tables.table_names.join
        ).to match("seq_setup_test")
      end

      it "skips creating a table if one is already configured" do
        Moe.configure do |c|
          c.tables = { "seq_skip_test" => [] }
        end

        expect(
          Moe::Models::Sequence.setup("seq_skip_test", 1, 5, 10)
        ).to match("already exists")
      end
    end
  end
end
