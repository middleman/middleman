# -*- encoding: utf-8 -*-
require "rbconfig"

$:.push File.expand_path("../lib", __FILE__)
require "middleman/version"

Gem::Specification.new do |s|
  s.name        = "middleman"
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

  # TODO remove for 2.1.x
  s.post_install_message =<<eos
********************************************************************************

  Welcome to Middleman 2.0
  
  In addition to many new features, some backwards-incompatible
  changes have been made to the structure of Middleman sites.
  
  Before running you old, v1.x project on Middleman 2.0,
  review the Migration guide:
  
  http://middlemanapp.com/guides/migrating

********************************************************************************
eos

  s.add_runtime_dependency("rack", ["~> 1.3.0"])
  s.add_runtime_dependency("thin", ["~> 1.2.11"])
  s.add_runtime_dependency("thor", ["~> 0.14.0"])
  s.add_runtime_dependency("tilt", ["~> 1.3.1"])
  s.add_runtime_dependency("maruku", ["~> 0.6.0"])
  s.add_runtime_dependency("sinatra", ["~> 1.2.6"])
  s.add_runtime_dependency("rack-test", ["~> 0.6.1"])
  s.add_runtime_dependency("uglifier", ["~> 1.0.0"])
  s.add_runtime_dependency("slim", ["~> 1.0.1"])
  s.add_runtime_dependency("haml", ["~> 3.1.0"])
  s.add_runtime_dependency("sass", ["~> 3.1.7"])
  s.add_runtime_dependency("compass", ["~> 0.11.3"])
  s.add_runtime_dependency("coffee-script", ["~> 2.2.0"])
  s.add_runtime_dependency("sprockets", ["2.0.0.beta.14"])
  
  # Padrino deps
  s.add_runtime_dependency("activesupport", "~> 3.0.0")
  
  # Only in Padrino-helpers
  s.add_runtime_dependency("i18n", "~> 0.5.0")
  
  case Config::CONFIG['host_os'].downcase
  when %r{mswin|mingw}
    # s.add_runtime_dependency "windows-api", "= 0.4.0"
    # s.add_runtime_dependency "windows-pr", "= 1.1.2"
    s.add_runtime_dependency("win32-process", ["~> 0.6.5"])
    s.add_runtime_dependency("win32console", ["~> 1.3.0"])
    s.add_runtime_dependency("rb-fchange")
  when %r{darwin}  
    s.add_runtime_dependency("rb-fsevent", ["~> 0.4.2"])
  end
  
  s.add_runtime_dependency("guard", ["~> 0.6.2"])
  s.add_runtime_dependency("middleman-livereload", ["~> 0.2.0"])
  s.add_development_dependency("coffee-filter", ["~> 0.1.1"])
  s.add_development_dependency("cucumber", ["~> 1.0.2"])
  s.add_development_dependency("rake", ["0.8.7"])
  s.add_development_dependency("rspec", ["~> 2.6.0"])
end

