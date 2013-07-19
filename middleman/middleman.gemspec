# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path("../../middleman-core/lib/middleman-core/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman"
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Thomas Reynolds", "Ben Hollis"]
  s.email       = ["me@tdreyno.com", "ben@benhollis.net"]
  s.homepage    = "http://middlemanapp.com"
  s.summary     = "Hand-crafted frontend development"
  s.description = "A static site generator. Provides dozens of templating languages (Haml, Sass, Compass, Slim, CoffeeScript, and more). Makes minification, compression, cache busting, Yaml data (and more) an easy part of your development cycle."

  s.files         = `git ls-files -z`.split("\0")
  s.test_files    = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_paths = ["lib"]

  s.add_dependency("middleman-core", Middleman::VERSION)
  s.add_dependency("middleman-more", Middleman::VERSION)
  s.add_dependency("middleman-sprockets", ">= 3.1.2")
  s.add_dependency("haml", [">= 3.1.6"])
  s.add_dependency("sass", [">= 3.1.20"])
  s.add_dependency("compass", [">= 0.12.2"])
  s.add_dependency("uglifier", ["~> 2.1.0"])
  s.add_dependency("coffee-script", ["~> 2.2.0"])
  s.add_dependency("execjs", ["~> 1.4.0"])
  s.add_dependency("kramdown", ["~> 1.1.0"])
end
