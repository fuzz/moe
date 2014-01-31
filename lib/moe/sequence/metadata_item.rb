module Moe
  module Sequence
    MetadataItem = Struct.new(:table_name, :owner_id, :uid, :count, :payload) do

      def items
        collection = Collection.new owner_id

        collection.get_items table_name, uid, count
      end
      
    end
  end
end