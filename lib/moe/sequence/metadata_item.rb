module Moe
  module Sequence
    MetadataItem = Struct.new(:table_name, :owner_id, :uid, :count, :payload) do

      def items
        dyna = Dyna.new

        request = {
          request_items: {
            table_name => { keys: [] }
          }
        }
        keys = request[:request_items][table_name][:keys]

        1.upto(count.to_i) do |sequence_id|
          keys << dyna.explode( Locksmith.key(owner_id, sequence_id, uid) )
        end

        results = dyna.dynamodb.batch_get_item(request)

        [].tap do |items|
          results.responses.each_value do |item|
            item.each do |i|
              items << dyna.implode(i)
            end
          end
        end
      end
      
    end
  end
end