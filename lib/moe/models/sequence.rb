module Moe
  module Models
    class Sequence
      attr_accessor :dyna
      attr_reader   :read_tables, :write_tables

      module ClassMethods
        def setup(name, copies, read_capacity, write_capacity)
          return "#{name} already exists in config" if Moe.config.tables[name]

          table_manager = TableManager.new

          table_manager.build name, copies, read_capacity, write_capacity
        end
      end
      extend ClassMethods

      def initialize(name)
        @dyna = Dyna.new
        @read_tables, @write_tables = Moe.config.tables[name]
      end
    end
  end
end
