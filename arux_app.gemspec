# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name           = "arux_app"
  spec.version        = "1.0.0"
  spec.authors        = ["Arux Software"]
  spec.email          = ["sheuer@aruxsoftware.com"]
  spec.summary        = "Ruby gem for interacting with the Arux.app Switchboard APIs."
  spec.homepage       = "https://arux.software"
  spec.license        = "MIT"

  spec.files          = `git ls-files -z`.split("\x0")
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ["lib"]
  
  spec.add_runtime_dependency "httpi", "~> 2.4"
  spec.add_runtime_dependency "json", ">= 0"

  spec.add_development_dependency "bundler", ">= 1.14"
  spec.add_development_dependency "rake", ">= 12.0"
end
