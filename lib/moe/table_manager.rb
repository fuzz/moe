module Moe
  class TableManager
    attr_reader   :date
    attr_accessor :dyna, :meta

    def initialize
      @date = Time.now.strftime("%F")
      @dyna = Dyna.new
      @meta = dyna.find(meta_table_names.first) || dyna.create_table(meta_table_name, 2)
    end

    def build(model, copies=1, hash_key="hash", range_key=nil, read_capacity=5, write_capacity=10, read_tables=[])
      write_tables =  dyna.create_table table_name(model),
                      copies,
                      hash_key,
                      range_key,
                      read_capacity,
                      write_capacity

      metadata = {
        read_tables:  read_tables << write_tables.first,
        write_tables: write_tables
      }

      update_metadata model, metadata

      [ read_tables, write_tables ]
    end

    def increment(model)
      metadata = load_metadata model
      table    = load_table metadata[:write_tables].first

      if table[:table_name].include? date
        raise "Moe sez: Cannot increment twice on the same day!"
      end

      build model,
            metadata[:write_tables].size,
            table[:key][:hash],
            table[:key][:range],
            table[:read_capacity],
            table[:write_capacity],
            metadata[:read_tables]
    end

    def load_metadata(model)
      metadata = dyna.get_item meta_table_names,
                                { "hash" => { s: munged_model(model) } }

      MultiJson.load metadata["payload"]["s"], symbolize_keys: true
    end

    def load_table(table_name)
      table = dyna.find table_name

      {
        table_name:     table.table.table_name,
        key:            get_key(table.table.key_schema),
        read_capacity:  table.table.provisioned_throughput.read_capacity_units,
        write_capacity: table.table.provisioned_throughput.write_capacity_units
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

    def update_metadata(model, payload)
      item = { 
        "hash"    => munged_model(model),
        "payload" => MultiJson.dump(payload)
      }

      dyna.put_item meta_table_names, item
    end

    private

    def get_key(key_schema)
      {}.tap do |key|
        key_schema.each do |k|
          if k.key_type == "HASH"
            key[:hash]  = k.attribute_name
          else
            key[:range] = k.attribute_name
          end
        end
      end
    end

    def munged_model(model)
      model.gsub(/::/, "_")
    end
  end
end
