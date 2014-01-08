module Moe
  class Table

    module ClassMethods
      def create(name: nil, hash_key: "id", range_key: nil, read_capacity: 5, write_capacity: 10)
        dynamo = Aws.dynamodb
        schema = template(name, hash_key, range_key, read_capacity, write_capacity)

        table = dynamo.create_table schema
        table.table_description
      end

      def find(name)
        Aws.dynamodb.describe_table table_name: name rescue nil
      end

      def template(name, hash_key, range_key, read_capacity, write_capacity)
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
    extend ClassMethods

  end
end
