# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reviewed/cache/version'

Gem::Specification.new do |spec|
  spec.name          = "reviewed-cache"
  spec.version       = Reviewed::Cache::VERSION
  spec.authors       = ["Luke Bergen"]
  spec.email         = ["lbergen@reviewed.com"]
  spec.summary       = "A gem to generate cache keys in one place"
  spec.homepage      = "http://www.reviewed.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
