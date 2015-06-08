# -*- encoding: utf-8 -*-
require File.expand_path("../lib/middleman-core/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-core"
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Thomas Reynolds", "Ben Hollis", "Karl Freeman"]
  s.email       = ["me@tdreyno.com", "ben@benhollis.net", "karlfreeman@gmail.com"]
  s.homepage    = "http://middlemanapp.com"
  s.summary     = "Hand-crafted frontend development"
  s.description = "A static site generator. Provides dozens of templating languages (Haml, Sass, Compass, Slim, CoffeeScript, and more). Makes minification, compression, cache busting, Yaml data (and more) an easy part of your development cycle."

  s.files        = `git ls-files -z`.split("\0")
  s.test_files   = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.executable   = "middleman"
  s.require_path = "lib"
  s.required_ruby_version = '>= 1.9.3'

  # Core
  s.add_dependency("bundler", ["~> 1.1"])
  s.add_dependency("rack", [">= 1.4.5", "< 2.0"])
  s.add_dependency("tilt", ["~> 1.4.1", "< 2.0"])
  s.add_dependency("erubis")
  s.add_dependency("hooks", ["~> 0.3"])

  # Builder
  s.add_dependency("capybara", ["~> 2.4.4"])

  # CLI
  s.add_dependency("thor", [">= 0.15.2", "< 2.0"])

  # Helpers
  s.add_dependency("activesupport", ["~> 4.1.0"])
  s.add_dependency("padrino-helpers", ["~> 0.12.3"])

  # Watcher
  s.add_dependency("listen", [">= 2.7.9", "< 3.0"])

  # i18n
  s.add_dependency("i18n", ["~> 0.7.0"])
end
