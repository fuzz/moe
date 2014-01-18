module Moe
  module Models
    class Sequence
      attr_accessor :dyna, :flushed_count, :items
      attr_reader   :read_tables, :write_tables, :uuid

      BATCH_LIMIT = 15

      module ClassMethods
        def setup(name, copies, hash_key="hash", range_key="range", read_capacity, write_capacity)
          return "#{name} already exists in config" if Moe.config.tables[name]

          table_manager = TableManager.new

          tables = table_manager.build name, copies, hash_key, range_key, read_capacity, write_capacity

          Moe.config.tables[name] = tables
        end
      end
      extend ClassMethods

      def initialize(name)
        @dyna          = Dyna.new
        @flushed_count = 0
        @items         = []
        @read_tables, @write_tables = Moe.config.tables[name]
      end

      def add(item)
        @uuid ||= SecureRandom.uuid

        items << item

        flush if items.size >= BATCH_LIMIT
      end

      private

      def flush
        dyna.batch_write_item write_tables, items

        self.flushed_count += items.size
      end
    end
  end
end
