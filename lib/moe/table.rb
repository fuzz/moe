module Moe
  module Table

    module ModuleFunctions
      def get_item(read_tables, key)
        dynamo = Aws.dynamodb

        item = nil
        while !item
          item = dynamo.get_item(table_name: read_tables.pop, key: key).item
        end
        item
      end

      def put_item(write_tables, item)
        dynamo = Aws.dynamodb

        write_tables.each do |table_name|
          dynamo.put_item table_name: table_name, item: item
        end
      end

      def create(name, hash_key="id", read_capacity="5", write_capacity="10")
        dynamo = Aws.dynamodb
        schema = template(name, hash_key, read_capacity, write_capacity)

        table = dynamo.create_table schema
        table.table_description
      end

      def find(name)
        Aws.dynamodb.describe_table table_name: name rescue nil
      end

      private

      def template(name, hash_key, read_capacity, write_capacity)
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
        }
      end
    end
    extend ModuleFunctions

  end
end
