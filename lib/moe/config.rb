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
    attr_accessor :read_tables, :write_tables

    def initialize
      @read_tables  = {}
      @write_tables = {}
    end
  end
end
