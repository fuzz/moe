require "aws-sdk-core"
require "multi_json"
require "securerandom"

require "moe/config"
require "moe/dyna"
require "moe/sequence"
require "moe/sequence/collection"
require "moe/sequence/collector"
require "moe/sequence/locksmith"
require "moe/table_manager"
require "moe/version"

module Moe

  module ModuleFunctions
    def collection(name, owner_id)
      Sequence::Collection.new name, owner_id
    end

    def collector(name, owner_id)
      Sequence::Collector.new name, owner_id
    end
  end
  extend ModuleFunctions

end
