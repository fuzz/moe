module Moe
  module Sequence
    class Collector
      attr_accessor :dyna, :flushed_count, :payloads
      attr_reader   :owner_id, :write_tables, :uuid

      BATCH_LIMIT = 15

      def initialize(name, owner_id)
        @dyna          = Dyna.new
        @flushed_count = 0
        @payloads      = []
        @owner_id      = owner_id
        @uuid          = SecureRandom.uuid
        @write_tables  = Moe.config.tables[name].last
      end

      def add(payload={})
        payloads << payload

        if payloads.size >= BATCH_LIMIT
          items = keyify payloads
          flush items

          self.payloads = []
        end
      end

      def save(payload={})
        metadata_item = {
          "count"    => (payloads.size + flushed_count).to_s,
          "saved_at" => Time.now.to_s,
          "payload"  => MultiJson.dump(payload)
        }.merge Locksmith.itemize owner_id, payload, 0, uuid

        items = keyify payloads

        items << metadata_item

        flush items
      end

      private

      def flush(items)
        result = dyna.batch_write_item write_tables, items

        self.flushed_count += items.size
      end

      def keyify(items, uid=uuid)
        count = flushed_count
        items.each do |item|
          count += 1
          item.update Locksmith.key owner_id, count, uid
        end
      end
    end
  end
end
