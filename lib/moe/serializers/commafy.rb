module Moe
  module Serializers
    module Commafy

      module ModuleFunctions
        def dump(array)
          array.join ","
        end

        def load(list)
          list.split ","
        end
      end
      extend ModuleFunctions

    end
  end
end
