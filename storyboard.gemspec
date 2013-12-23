# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'storyboard/version'

Gem::Specification.new do |spec|
  spec.name          = "storyboard"
  spec.version       = Storyboard::VERSION
  spec.authors       = ["Mark Olson"]
  spec.email         = ["theothermarkolson@gmail.com"]
  spec.description   = %q{ }
  spec.summary       = %q{ }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "micro-optparse"
  spec.add_dependency "highline"
  spec.add_dependency "prawn"
  spec.add_dependency "titlekit"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
