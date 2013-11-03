# -*- encoding: utf-8 -*-
require File.expand_path("../lib/middleman-core/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-core"
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Thomas Reynolds", "Ben Hollis"]
  s.email       = ["me@tdreyno.com", "ben@benhollis.net"]
  s.homepage    = "http://middlemanapp.com"
  s.summary     = "Hand-crafted frontend development"
  s.description = "A static site generator. Provides dozens of templating languages (Haml, Sass, Compass, Slim, CoffeeScript, and more). Makes minification, compression, cache busting, Yaml data (and more) an easy part of your development cycle."

  s.files        = `git ls-files -z`.split("\0")
  s.test_files   = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.executable   = "middleman"
  s.require_path = "lib"
  
  # Core
  s.add_dependency("bundler", ["~> 1.1"])
  s.add_dependency("rack", [">= 1.4.5"])
  s.add_dependency("tilt", ["~> 1.3.6"])
  
  # Builder
  s.add_dependency("rack-test", ["~> 0.6.1"])
  
  # CLI
  s.add_dependency("thor", [">= 0.15.2", "< 2.0"])
  
  # Helpers
  s.add_dependency("activesupport", ["~> 3.2.6"])
  
  # Watcher
  s.add_dependency("listen", ["~> 1.1"])

  # i18n
  s.add_dependency("i18n", ["~> 0.6.1"])

  s.post_install_message = "NOTICE: Middleman v3.2.x and greater no longer support Ruby 1.8"
end
