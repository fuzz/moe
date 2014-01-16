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
    attr_accessor :tables

    def initialize
      @tables  = {}
    end
  end
end
