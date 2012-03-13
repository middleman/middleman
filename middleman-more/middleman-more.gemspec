# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path("../../middleman-core/lib/middleman-core/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-more"
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

  s.add_dependency("middleman-core", Middleman::VERSION)
  s.add_dependency("uglifier", ["~> 1.2.0"])
  s.add_dependency("haml", ["~> 3.1.0"])
  s.add_dependency("sass", [">= 3.1.7"])
  s.add_dependency("compass", ["~> 0.12.0"])
  s.add_dependency("coffee-script", ["~> 2.2.0"])
  s.add_dependency("execjs", ["~> 1.2"])
  s.add_dependency("sprockets", ["~> 2.1"])
  s.add_dependency("sprockets-sass", ["~> 0.7.0"])
  s.add_dependency("redcarpet", ["~> 2.1.0"])
end

