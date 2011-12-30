# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-core/version"

Gem::Specification.new do |s|
  s.name        = "middleman-core"
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Thomas Reynolds"]
  s.email       = ["me@tdreyno.com"]
  s.homepage    = "http://middlemanapp.com"
  s.summary     = "Hand-crafted frontend development"
  s.description = "A static site generator based on Sinatra. Providing dozens of templating languages (Haml, Sass, Compass, Slim, CoffeeScript, and more). Makes minification, compression, cache busting, Yaml data (and more) an easy part of your development cycle."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {fixtures,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Thin
  # s.add_dependency("thin", ["~> 1.3.1"])
  
  # Core
  s.add_dependency("rack", ["~> 1.3.5"])
  s.add_dependency("tilt", ["~> 1.3.1"])
  
  # Builder
  s.add_dependency("rack-test", ["~> 0.6.1"])
  
  # CLI
  s.add_dependency("thor", ["~> 0.14.0"])
  
  # Helpers
  # s.add_dependency("i18n", ["~> 0.6.0"])
  s.add_dependency("activesupport", ["~> 3.1.0"])
  
  # Watcher
  s.add_dependency("guard", ["~> 0.9.4"])
end

