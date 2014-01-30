module Moe
  module Sequence
    class Collection
      attr_accessor :dyna, :payloads
      attr_reader   :owner_id, :read_tables, :uuid

      def initialize(name, owner_id)
        @dyna          = Dyna.new
        @payloads      = []
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

          results << { table_name => dyna.dynamodb.query(request).items }
        end

        parse_query_results(results)
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

      def parse_query_results(results)
        parsed_results = {}

        results.each do |table|
          table.each do |table_name,item|
            parsed_results[table_name] = []
            parsed_item = {}

            item.each do |attribute|
              attribute.each do |name,value|
                parsed_item[name] = value.s
              end
              parsed_results[table_name] << parsed_item
            end
          end
        end

        parsed_results
      end
    end
  end
end
