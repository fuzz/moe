# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moe/version'

Gem::Specification.new do |spec|
  spec.name          = "moe"
  spec.version       = Moe::VERSION
  spec.authors       = ["Fuzz Leonard"]
  spec.email         = ["fuzz@fuzzleonard.com"]
  spec.description   = %q{A toolkit for working with DynamoDB at scale}
  spec.summary       = %q{A toolkit for working with DynamoDB}
  spec.homepage      = "https://github.com/Geezeo/moe"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-core"
  spec.add_dependency "hashie"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "fake_dynamo", "0.2.5"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
end
