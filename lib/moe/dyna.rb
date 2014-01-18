module Moe
  class Dyna

    attr_accessor :dynamodb

    def initialize
      @dynamodb = Aws.dynamodb
    end

    def batch_write_item(write_tables, items)
      write_tables.each do |table_name|
        dynamodb.batch_write_item request_items: {
          table_name => batchify(items)
        }
      end
    end

    def create(name, copies=1, hash_key="hash", range_key=nil, read_capacity=5, write_capacity=10)
      [].tap do |tables|
        1.upto(copies).each do |copy|
          schema = table_schema("#{name}_#{copy}", hash_key, range_key, read_capacity, write_capacity)
          table  = dynamodb.create_table schema

          tables << "#{name}_#{copy}"
        end
      end
    end

    def get_item(read_tables, key)
      item = nil
      read_tables.each do |table_name|
        item = dynamodb.get_item(table_name: table_name, key: key).item
        break if item
      end
      item
    end

    def put_item(write_tables, item)
      write_tables.each do |table_name|
        dynamodb.put_item table_name: table_name, item: item
      end
    end

    def find(name)
      if dynamodb.list_tables.table_names.include? name
        dynamodb.describe_table table_name: name
      else
        false
      end
    end

    private

    def batchify(items)
      items.map do |item|
        { put_request:
          { item: item }
        }
      end
    end

    def table_schema(name, hash_key, range_key, read_capacity, write_capacity)
      { table_name: name,
        key_schema: [
          attribute_name: hash_key,
          key_type: "HASH"
        ],
        attribute_definitions: [
          {
            attribute_name: hash_key,
            attribute_type: "S"
          }
        ],
        provisioned_throughput: {
          read_capacity_units: read_capacity,
          write_capacity_units: write_capacity
        }
      }.tap do |table|
        if range_key
          table[:key_schema] << { attribute_name: range_key, key_type: "RANGE" }
          table[:attribute_definitions] << { attribute_name: range_key, attribute_type: "S" }
        end
      end
    end
  end
end
