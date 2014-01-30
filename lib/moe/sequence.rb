module Moe
  module Sequence

    module ModuleFunctions
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
    extend ModuleFunctions
    
  end
end
