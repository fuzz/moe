module Moe
  class TableManager
    attr_reader   :date
    attr_accessor :dyna, :meta

    def initialize
      @date = Time.now.strftime("%F")
      @dyna = Dyna.new
      @meta = dyna.find(meta_table_names.first) || dyna.create(meta_table_name, 2)
    end

    def build(model, copies=1, read_tables=[], read_capacity="5", write_capacity="10")
      write_tables = dyna.create table_name(model), copies, "id", read_capacity, write_capacity

      update_metadata model,
                      read_tables << write_tables.first,
                      write_tables,
                      read_capacity,
                      write_capacity

    end

    def increment(model)
      table_metadata  = load_metadata model
      read_tables     = table_metadata[:read_tables]
      write_tables    = table_metadata[:write_tables]
      write_table     = dyna.find write_tables.first
      read_capacity   = write_table.table.provisioned_throughput.read_capacity_units.to_s
      write_capacity  = write_table.table.provisioned_throughput.write_capacity_units.to_s

      if write_table.table.table_name.include? date
        raise "Moe sez: Cannot increment twice on the same day!"
      end

      build model, write_tables.size, read_tables, read_capacity, write_capacity
    end

    def load_metadata(model)
      metadata = dyna.get_item meta_table_names,
                                { "id" => { s: munged_model(model) } }

      {
        read_tables:  Serializers::Commafy.load(metadata["read_tables"]["s"]),
        write_tables: Serializers::Commafy.load(metadata["write_tables"]["s"])
      }
    end

    def meta_table_name
      "moe_#{ENV['RAILS_ENV']}_manager"
    end

    def meta_table_names
      ["#{meta_table_name}_1", "#{meta_table_name}_2"]
    end

    def table_name(model)
      "moe_#{ENV['RAILS_ENV']}_#{date}_#{munged_model(model)}".downcase
    end

    def update_metadata(model, read_tables=[], write_tables=[], read_capacity, write_capacity)
      item = { 
        "id"             => { s:  munged_model(model) },
        "read_tables"    => { s:  Serializers::Commafy.dump(read_tables) },
        "write_tables"   => { s:  Serializers::Commafy.dump(write_tables) },
        "read_capactity" => { s:  read_capacity },
        "write_capacity" => { s:  write_capacity },
      }

      dyna.put_item meta_table_names, item
    end

    private

    def munged_model(model)
      model.gsub(/::/, "_")
    end

  end
end
