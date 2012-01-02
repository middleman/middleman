# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rb-fsevent/version"

Gem::Specification.new do |s|
  s.name        = "rb-fsevent"
  s.version     = FSEvent::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Thibaud Guillaume-Gentil', 'Travis Tilley']
  s.email       = ['thibaud@thibaud.me', 'ttilley@gmail.com']
  s.homepage    = "http://rubygems.org/gems/rb-fsevent"
  s.summary     = "Very simple & usable FSEvents API"
  s.description = "FSEvents API with Signals catching (without RubyCocoa)"

  s.rubyforge_project = "rb-fsevent"

  s.add_development_dependency  'bundler',     '~> 1.0.10'
  s.add_development_dependency  'rspec',       '~> 2.5.0'
  s.add_development_dependency  'guard-rspec', '~> 0.1.9'

  s.files        = Dir.glob('{lib,ext}/**/*') + %w[LICENSE README.rdoc]
  s.extensions   = ['ext/extconf.rb']
  s.require_path = 'lib'
end
