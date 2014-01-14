module Moe
  class TableManager
    attr_reader   :date
    attr_accessor :meta

    def initialize
      @date = Time.now.strftime("%F") 
      @meta = Table.find(meta_table_name) || Table.create(meta_table_name)
    end

    def build(model, copies=1, read_tables=[], read_capacity="5", write_capacity="10")
      write_tables = []

      1.upto(copies).each do |copy|
        Table.create "#{table_name(model)}_#{copy}", read_capacity, write_capacity
        write_tables << "#{table_name(model)}_#{copy}"
      end

      update_metadata model,
                      read_tables << write_tables.first,
                      write_tables,
                      read_capacity,
                      write_capacity

    end

    def increment(model)
      table_metadata  = load_metadata model
      read_tables     = table_metadata.item["read_tables"]["ss"]
      write_table     = Table.find table_metadata.item["write_tables"]["ss"].first
      read_capacity   = write_table.table.provisioned_throughput.read_capacity_units.to_s
      write_capacity  = write_table.table.provisioned_throughput.write_capacity_units.to_s

      if write_table.table.table_name.include? date
        raise "Moe sez: Cannot increment twice on the same day!"
      end

      build model, table_metadata.item["write_tables"]["ss"].size, read_tables, read_capacity, write_capacity
    end

    def load_metadata(model)
      Table.get_item meta_table_name,
                     { "id" => { s: munged_model(model) } }
    end

    def meta_table_name
      "moe_#{ENV['RAILS_ENV']}_manager"
    end

    def table_name(model)
      "moe_#{ENV['RAILS_ENV']}_#{date}_#{munged_model(model)}".downcase
    end

    def update_metadata(model, read_tables=[], write_tables=[], read_capacity, write_capacity)
      item = { 
        "id"             => { s:  munged_model(model) },
        "read_tables"    => { ss: read_tables },
        "write_tables"   => { ss: write_tables },
        "read_capactity" => { s:  read_capacity },
        "write_capacity" => { s:  write_capacity },
      }

      Table.put_item meta_table_name, item
    end

    private

    def munged_model(model)
      model.gsub(/::/, "_")
    end

  end
end
