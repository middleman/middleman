# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman/version"

Gem::Specification.new do |s|
  s.name        = "middleman"
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Reynolds"]
  s.email       = ["tdreyno@gmail.com"]
  s.homepage    = "http://middlemanapp.com"
  s.summary     = "A static site generator based on Sinatra. Providing Haml, Sass, Compass, CoffeeScript and including minification, compression and cache busting."

  s.rubyforge_project = "middleman"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {fixtures,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency("rack", ["~> 1.1"])
  s.add_runtime_dependency("thor", ["~> 0.14.0"])
  s.add_runtime_dependency("tilt", ["~> 1.3.1"])
  s.add_runtime_dependency("rdiscount", ["~> 1.6.8"])
  s.add_runtime_dependency("sinatra", ["~> 1.2.0"])
  s.add_runtime_dependency("padrino-core", ["~> 0.9.23"])
  s.add_runtime_dependency("padrino-helpers", ["~> 0.9.23"])
  s.add_runtime_dependency("rack-test", ["~> 0.5.0"])
  s.add_runtime_dependency("uglifier", ["~> 0.5.0"])
  s.add_runtime_dependency("slim", ["~> 0.9.4"])
  s.add_runtime_dependency("haml", ["~> 3.1.0"])
  s.add_runtime_dependency("sass", ["~> 3.1.0"])
  s.add_runtime_dependency("compass", ["~> 0.11.3"])
  s.add_runtime_dependency("httparty", ["~> 0.7.0"])
  s.add_development_dependency("spork", ["~> 0.9.0.rc8"])
  s.add_development_dependency("cucumber", ["~> 0.10.0"])
  s.add_development_dependency("rake", ["0.8.7"])
  s.add_development_dependency("rspec", [">= 0"])
  s.add_development_dependency("rocco", [">= 0"]) unless defined?(JRUBY_VERSION)
end

