module Moe
  class TableManager
    attr_reader   :date
    attr_accessor :meta

    def initialize
      @date = Time.now.strftime("%F") 
      @meta = Table.find(meta_table_name) || Table.create(name: meta_table_name)
    end

    def create(model: "", read_capacity: "5", write_capacity: "10")
      table = Table.create name: table_name(model)

      update_metadata(  model: model,
                        read_capacity: read_capacity,
                        write_capacity: write_capacity,
                        read_tables: [] )
    end

    def meta_table_name
      "moe_#{ENV['RAILS_ENV']}_manager"
    end

    def table_name(model)
      "moe_#{ENV['RAILS_ENV']}_#{date}_#{munged_model(model)}".downcase
    end

    def update_metadata(model: "", read_capacity: "5", write_capacity: "10", read_tables: [])
      item = { 
        "id"             => { s: munged_model(model) },
        "read_tables"    => { ss: read_tables << table_name(model) },
        "write_table"    => { s: table_name(model) },
        "read_capactity" => { s: read_capacity },
        "write_capacity" => { s: write_capacity }
      }

      Table.put_item(table_name: meta_table_name, item: item)
    end

    private

    def munged_model(model)
      model.gsub(/::/, "_")
    end

  end
end
