# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3/migrator/version'

Gem::Specification.new do |spec|
  spec.name          = "s3-migrator"
  spec.version       = S3::Migrator::VERSION
  spec.authors       = ["yoppi"]
  spec.email         = ["y.hirokazu@gmail.com"]
  spec.summary       = %q{"Migrate S3 object"}
  spec.description   = %q{"Migrate S3 object"}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
