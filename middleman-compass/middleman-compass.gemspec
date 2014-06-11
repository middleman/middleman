# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-compass/version"

Gem::Specification.new do |s|
  s.name = "middleman-compass"
  s.version = Middleman::Compass::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Thomas Reynolds', 'Ben Hollis', 'Karl Freeman']
  s.email = ['me@tdreyno.com', 'ben@benhollis.net', 'karlfreeman@gmail.com']
  s.homepage = "https://github.com/middleman/middleman-compass"
  s.summary = %q{Compass support for Middleman}
  s.description = %q{Compass support for Middleman}
  s.license = "MIT"
  s.files = `git ls-files -z`.split("\0")
  s.test_files = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_paths = ["lib"]
  s.add_dependency("middleman-core")#, [">= 4.0.0"])
  s.add_dependency('compass', ['>= 1.0.0.alpha.19'])
end
