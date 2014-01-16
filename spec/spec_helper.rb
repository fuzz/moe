require "coveralls"
Coveralls.wear!

require "moe"
require "pry"
require "timecop"

Aws.config = {
    access_key_id: "xxx",
    secret_access_key: "xxx",
    dynamodb:  {
                  api_version: "2012-08-10",
                  endpoint: "http://localhost:4567"
                },
    region: "us-east-1"
  }

Moe.configure do |conf|
  conf.tables = {}
end

RSpec.configure do |conf|
  conf.order = "random"

  conf.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
