module Moe
  module Sequence
    class Collection
      attr_accessor :dyna
      attr_reader   :owner_id, :read_tables

      def initialize(name, owner_id)
        @dyna         = Dyna.new
        @owner_id     = owner_id
        @read_tables  = Moe.config.tables[name].first
      end

      def metadata_items
        [].tap do |results|
          read_tables.each do |table_name|

            dyna.dynamodb.query(request table_name).items.each do |item|
              results << process(table_name, item)
            end

          end
        end
      end

      private

      def process(table_name, item)
        MetadataItem.new( table_name,
                          owner_id,
                          item["range"].s.gsub(/0\./, ""),
                          item["count"].s.to_i,
           MultiJson.load(item["payload"].s) )
      end

      def request(table_name)
        {
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
      end
    end
  end
end
