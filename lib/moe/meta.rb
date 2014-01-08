module Moe
  class Meta
    attr_accessor :table

    def initialize
      @table = Table.find(table_name) || Table.create(name: table_name)
    end

    def table_name
      "#{ENV['RAILS_ENV']}meta"
    end

  end
end
