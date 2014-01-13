module Moe
  class TableManager
    attr_reader   :date
    attr_accessor :meta

    def initialize
      @date = Time.now.strftime("%F") 
      @meta = Table.find(meta_table_name) || Table.create(meta_table_name)
    end

    def build(model, mirror="false", read_capacity="5", write_capacity="10", read_tables=[])
      Table.create table_name(model), read_capacity, write_capacity

      if mirror == "true"
        Table.create "#{table_name(model)}_mirror", read_capacity, write_capacity
      end

      update_metadata model,
                      mirror,
                      read_capacity,
                      read_tables << table_name(model),
                      write_capacity
    end

    def increment(model)
      table_metadata  = load_metadata model
      write_table     = Table.find table_metadata.item["write_table"]["s"]
      read_capacity   = write_table.table.provisioned_throughput.read_capacity_units.to_s
      write_capacity  = write_table.table.provisioned_throughput.write_capacity_units.to_s

      if write_table.table.table_name.include? date
        raise "Moe sez: Cannot increment twice on the same day!"
      end

      build model, read_capacity, write_capacity
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

    def update_metadata(model, mirror, read_capacity, read_tables, write_capacity)
      item = { 
        "id"             => { s:  munged_model(model) },
        "mirror"         => { s:  mirror },
        "read_capactity" => { s:  read_capacity },
        "read_tables"    => { ss: read_tables },
        "write_capacity" => { s:  write_capacity },
        "write_table"    => { s:  table_name(model) }
      }

      Table.put_item meta_table_name, item
    end

    private

    def munged_model(model)
      model.gsub(/::/, "_")
    end

  end
end
