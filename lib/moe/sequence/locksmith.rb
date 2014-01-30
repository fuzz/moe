module Moe
  module Sequence
    module Locksmith

      module ModuleFunctions
        def itemize(owner_id, payload, sequence_id, uid)
          {
            "hash"    => owner_id,
            "range"   => "#{sequence_id}.#{uid}",
            "payload" => MultiJson.dump(payload)
          }
        end

        def key(owner_id, sequence_id, uid)
          {
            "hash"    => owner_id,
            "range"   => "#{sequence_id}.#{uid}"
          }
        end
      end
      extend ModuleFunctions

    end
  end
end