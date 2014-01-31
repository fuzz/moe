module Moe
  module Sequence
    MetadataItem = Struct.new(:table_name, :owner_id, :uid, :count, :payload) do

      def items
        dyna        = Dyna.new
        remaining   = count
        sequence_id = 1
        items       = []

        while remaining > Moe.config.batch_limit
          request = {
            request_items: {
              table_name => { keys: [] }
            }
          }
          keys = request[:request_items][table_name][:keys]

          Moe.config.batch_limit.times do
            keys << dyna.explode( Locksmith.key(owner_id, sequence_id, uid) )

            sequence_id += 1
          end

          results = dyna.dynamodb.batch_get_item(request)

          results.responses.each_value do |item|
            item.each do |i|
              items << dyna.implode(i)
            end
          end

          remaining -= Moe.config.batch_limit
        end

        request = {
          request_items: {
            table_name => { keys: [] }
          }
        }
        keys = request[:request_items][table_name][:keys]

        remaining.times do
          keys << dyna.explode( Locksmith.key(owner_id, sequence_id, uid) )

          sequence_id += 1
        end

        results = dyna.dynamodb.batch_get_item(request)

        results.responses.each_value do |item|
          item.each do |i|
            items << dyna.implode(i)
          end
        end

        items
      end
    end
  end
end
