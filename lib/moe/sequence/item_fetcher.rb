module Moe
  module Sequence
    class ItemFetcher
      attr_accessor :dyna, :items, :sequence_id
      attr_reader   :owner_id, :table_name, :uid

      def initialize(table_name, owner_id, uid)
        @dyna = Dyna.new
        @items = []
        @owner_id = owner_id
        @sequence_id = 1
        @table_name = table_name
        @uid = uid
      end

      def fetch(limit)
        request = {
          request_items: {
            table_name => { keys: [] }
          }
        }
        keys = request[:request_items][table_name][:keys]

        limit.times do
          keys << dyna.explode( Locksmith.key(owner_id, sequence_id, uid) )

          self.sequence_id += 1
        end

        munge dyna.dynamodb.batch_get_item(request)
      end

      private

      def munge(results)
        results.responses.each_value do |item|
          item.each do |i|
            items << dyna.implode(i)
          end
        end
      end
    end
  end
end