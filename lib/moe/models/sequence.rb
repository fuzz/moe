module Moe
  module Models
    class Sequence
      attr_accessor :dyna, :flushed_count, :items
      attr_reader   :owner_id, :read_tables, :write_tables, :uuid

      BATCH_LIMIT = 15

      module ClassMethods
        def setup(name, copies, hash_key="hash", range_key="range", read_capacity, write_capacity)
          return "#{name} already exists in config" if Moe.config.tables[name]

          table_manager = TableManager.new

          tables = table_manager.build name,
                                       copies,
                                       hash_key,
                                       range_key,
                                       read_capacity,
                                       write_capacity

          Moe.config.tables[name] = tables
        end
      end
      extend ClassMethods

      def initialize(name, owner_id)
        @dyna          = Dyna.new
        @flushed_count = 0
        @items         = []
        @owner_id      = owner_id
        @read_tables, @write_tables = Moe.config.tables[name]
      end

      def add(item={})
        @uuid ||= SecureRandom.uuid

        items << item

        if items.size >= BATCH_LIMIT
          keyify
          flush
        end
      end

      def get_metadata_items(owner_id)
        results = query owner_id, read_tables, true
      end

      def query(owner_id, read_tables, join=false)
        results = []

        read_tables.each do |table_name|

          items = {
            table_name: table_name,
            key_conditions: {
              "hash" => {
                attribute_value_list: [
                  { s: owner_id }
                ],
                comparison_operator: "EQ"
              },
            }
          }

          items[:key_conditions]["range"] = {
            attribute_value_list: [
              { s: "0" }
            ],
            comparison_operator: "BEGINS_WITH"
          } if join

          results << { table_name => dyna.dynamodb.query(items).items }
        end

        parse_query_results(results)
      end

      def save(item={})
        @uuid ||= SecureRandom.uuid

        metadata_item = {
          "count"    => (items.size + flushed_count).to_s,
          "saved_at" => Time.now.to_s
        }.merge(item).merge key 0

        keyify

        items << metadata_item

        flush
      end

      private

      def flush
        dyna.batch_write_item write_tables, items

        self.flushed_count += items.size
      end

      def key(sequence_id)
        {
          "hash"     => owner_id,
          "range"    => "#{sequence_id}.#{uuid}"
        }
      end

      def keyify
        count = flushed_count
        items.each do |item|
          count += 1
          item.update key count
        end
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
