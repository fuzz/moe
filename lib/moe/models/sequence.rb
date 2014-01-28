module Moe
  module Models
    class Sequence
      attr_accessor :dyna, :flushed_count, :payloads
      attr_reader   :owner_id, :read_tables, :write_tables, :uuid

      BATCH_LIMIT = 15

      module ClassMethods
        def setup(name, copies, read_capacity, write_capacity)
          return "#{name} already exists in config" if Moe.config.tables[name]

          table_manager = TableManager.new

          tables = table_manager.build name,
                                       copies,
                                       "hash",
                                       "range",
                                       read_capacity,
                                       write_capacity

          Moe.config.tables[name] = tables
        end
      end
      extend ClassMethods

      def initialize(name, owner_id)
        @dyna          = Dyna.new
        @flushed_count = 0
        @payloads      = []
        @owner_id      = owner_id
        @read_tables, @write_tables = Moe.config.tables[name]
      end

      def add(payload={})
        @uuid ||= SecureRandom.uuid

        payloads << payload

        if payloads.size >= BATCH_LIMIT
          items = keyify payloads
          flush items
        end
      end

      def get_items(table_name, uid, count)
        request = {
          request_items: {
            table_name => { keys: [] }
          }
        }
        keys = request[:request_items][table_name][:keys]

        1.upto(count.to_i) do |sequence_id|
          keys << dyna.explode( key(sequence_id, uid) )
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

      def save(payload={})
        @uuid ||= SecureRandom.uuid

        metadata_item = {
          "count"    => (payloads.size + flushed_count).to_s,
          "saved_at" => Time.now.to_s,
          "payload"  => MultiJson.dump(payload)
        }.merge itemize payload, 0

        items = keyify payloads

        items << metadata_item

        flush items
      end

      private

      def flush(items)
        result = dyna.batch_write_item write_tables, items

        self.flushed_count += items.size
      end

      def implode_batch(batch)
        results = []
        batch.each_value do |item|
          item.each do |i|
            results << dyna.implode(i)
          end
        end
        results
      end

      def itemize(payload, sequence_id, uid=uuid)
        {
          "hash"    => owner_id,
          "range"   => "#{sequence_id}.#{uid}",
          "payload" => MultiJson.dump(payload)
        }
      end

      def key(sequence_id, uid=uuid)
        {
          "hash"    => owner_id,
          "range"   => "#{sequence_id}.#{uid}"
        }
      end

      # TODO need to tap and return value so stuff no break
      def keyify(items, uid=uuid)
        count = flushed_count
        items.each do |item|
          count += 1
          item.update key count, uid
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
