module Moe
  module Sequence
    MetadataItem = Struct.new(:table_name, :owner_id, :uid, :count, :payload) do

      def items
        fetcher   = ItemFetcher.new table_name, owner_id, uid
        remaining = count

        while remaining > Moe.config.batch_limit
          fetcher.fetch Moe.config.batch_limit

          remaining -= Moe.config.batch_limit
        end

        fetcher.fetch remaining

        fetcher.items
      end
    end
  end
end
