# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman/version"

Gem::Specification.new do |s|
  s.name        = "middleman"
  s.version     = Middleman::VERSION
  s.platform    = "x86-mingw32"
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

  s.add_dependency("rack", ["~> 1.3.5"])
  s.add_dependency("thin", ["~> 1.3.1"])
  s.add_dependency("thor", ["~> 0.14.0"])
  s.add_dependency("tilt", ["~> 1.3.1"])
  s.add_dependency("i18n", ["~> 0.6.0"])
  s.add_dependency("rack-test", ["~> 0.6.1"])
  s.add_dependency("uglifier", ["~> 1.2.0"])
  s.add_dependency("haml", ["~> 3.1.0"])
  s.add_dependency("sass", ["~> 3.1.7"])
  s.add_dependency("activesupport", ["~> 3.1.0"])
  s.add_dependency("compass", ["~> 0.11.3"])
  s.add_dependency("coffee-script", ["~> 2.2.0"])
  s.add_dependency("execjs", ["~> 1.2.7"])
  s.add_dependency("sprockets", ["~> 2.1.2"])
  s.add_dependency("sprockets-sass", ["~> 0.6.0"])
  s.add_dependency("guard", ["~> 0.9.4"])
  s.add_dependency("redcarpet", ["~> 2.0.0"])
  
  s.add_dependency("eventmachine", ["1.0.0.beta.4.1"])
  s.add_dependency("win32-process", ["~> 0.6.5"])
  
  # Development and test
  s.add_development_dependency("slim")
  s.add_development_dependency("sinatra")
  s.add_development_dependency("coffee-filter", ["~> 0.1.1"])
  s.add_development_dependency("liquid", ["~> 2.2"])
  s.add_development_dependency("cucumber", ["~> 1.1.0"])
  s.add_development_dependency("aruba", ["~> 0.4.11"])
  s.add_development_dependency("rake", ["~> 0.9.2"])
  s.add_development_dependency("rspec", ["~> 2.7"])
  s.add_development_dependency("rdoc", ["~> 3.9"])
  s.add_development_dependency("yard")
  s.add_development_dependency("jquery-rails")
  s.add_development_dependency("bootstrap-rails", ["0.0.5"])
end

