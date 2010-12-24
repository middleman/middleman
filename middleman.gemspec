# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman/version"

Gem::Specification.new do |s|
  s.name        = "middleman"
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Reynolds"]
  s.email       = ["tdreyno@gmail.com"]
  s.homepage    = "http://wiki.github.com/tdreyno/middleman"
  s.summary     = "A static site generator utilizing Haml, Sass and providing YUI compression and cache busting"
  
  s.rubyforge_project = "middleman"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {fixtures,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency("rack", ["~> 1.0"])
  s.add_runtime_dependency("thin", ["~> 1.2.0"])
  s.add_runtime_dependency("shotgun", ["~> 0.8.0"])
  s.add_runtime_dependency("templater", ["~> 1.0.0"])
  s.add_runtime_dependency("tilt", ["~> 1.1"])
  s.add_runtime_dependency("sinatra", ["~> 1.0"])
  s.add_runtime_dependency("padrino-core", ["~> 0.9.0"])
  s.add_runtime_dependency("padrino-helpers", ["~> 0.9.0"])
  s.add_runtime_dependency("rack-test", ["~> 0.5.0"])
  s.add_runtime_dependency("yui-compressor", ["~> 0.9.0"])
  s.add_runtime_dependency("haml", ["~> 3.0"])
  s.add_runtime_dependency("compass", ["~> 0.10.0"])
  s.add_runtime_dependency("json_pure", ["~> 1.4.0"])
  s.add_runtime_dependency("smusher", ["~> 0.4.5"])
  s.add_runtime_dependency("compass-slickmap", ["~> 0.4.0"])
  s.add_runtime_dependency("coffee-script", ["~> 2.1.0"])
  s.add_runtime_dependency("less", ["~> 1.2.0"])
  s.add_development_dependency("cucumber", [">= 0"])
  s.add_development_dependency("rspec", [">= 0"])
end

