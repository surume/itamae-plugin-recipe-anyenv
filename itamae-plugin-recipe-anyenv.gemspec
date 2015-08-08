# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/plugin/recipe/anyenv/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae-plugin-recipe-anyenv"
  spec.version       = Itamae::Plugin::Recipe::Anyenv::VERSION
  spec.authors       = ["Surume"]
  spec.email         = ["mail@sururne.com"]

  spec.summary       = %q{Itamae plugin to install anyenv}
  spec.description   = %q{Itamae plugin to install anyenv}
  spec.homepage      = "https://github.com/Surume/itamae-plugin-recipe-anyenv"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # spec.add_dependency "itamae" "~> 1.4"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
