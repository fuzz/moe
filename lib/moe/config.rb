module Moe

  module ModuleFunctions
    attr_accessor :config

    def configure
      self.config ||= Config.new
      yield(config)
    end
  end
  extend ModuleFunctions

  class Config
    attr_accessor :batch_limit, :tables

    def initialize
      @batch_limit = 15
      @tables  = {}
    end
  end
end
