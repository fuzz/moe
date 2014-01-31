module Moe
  module Sequence
    class Collection
      attr_accessor :dyna, :sequences
      attr_reader   :owner_id, :read_tables, :uuid

      def initialize(name, owner_id)
        @dyna          = Dyna.new
        @sequences     = []
        @owner_id      = owner_id
        @read_tables   = Moe.config.tables[name].first
      end

      def get_items(table_name, uid, count)
        request = {
          request_items: {
            table_name => { keys: [] }
          }
        }
        keys = request[:request_items][table_name][:keys]

        1.upto(count.to_i) do |sequence_id|
          keys << dyna.explode( Locksmith.key(owner_id, sequence_id, uid) )
        end

        results = dyna.dynamodb.batch_get_item(request)

        implode_batch results.responses
      end

      def get_metadata_items
        results = []

        read_tables.each do |table_name|

          request = {
            table_name: table_name,
            key_conditions: {
              hash: {
                attribute_value_list: [
                  { s: owner_id }
                ],
                comparison_operator: "EQ"
              },
              range: {
                attribute_value_list: [
                  { s: "0" }
                ],
                comparison_operator: "BEGINS_WITH"
              }
            }
          }

          dyna.dynamodb.query(request).items.each do |item|
            results << MetadataItem.new(  table_name,
                                          owner_id,
                                          item["range"].s.gsub(/0\./, ""),
                                          item["count"].s,
                           MultiJson.load(item["payload"].s) )
          end
        end

        results
      end

      private

      def implode_batch(batch)
        results = []
        batch.each_value do |item|
          item.each do |i|
            results << dyna.implode(i)
          end
        end
        results
      end
    end
  end
end
