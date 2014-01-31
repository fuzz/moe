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

      def get_metadata_items
        [].tap do |results|
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
        end
      end

    end
  end
end
