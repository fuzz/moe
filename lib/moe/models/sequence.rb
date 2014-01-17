module Moe
  module Models
    class Sequence
      attr_accessor :dyna, :items
      attr_reader   :read_tables, :write_tables

      BATCH_LIMIT = 15

      module ClassMethods
        def setup(name, copies, read_capacity, write_capacity)
          return "#{name} already exists in config" if Moe.config.tables[name]

          table_manager = TableManager.new

          tables = table_manager.build name, copies, read_capacity, write_capacity

          Moe.config.tables[name] = tables
        end
      end
      extend ClassMethods

      def initialize(name)
        @dyna = Dyna.new
        @items = []
        @read_tables, @write_tables = Moe.config.tables[name]
      end

      def add(item)
        items << item

        flush if items.size >= BATCH_LIMIT
      end

      def flush
        dyna.batch_write_item write_tables, items
      end
    end
  end
end
