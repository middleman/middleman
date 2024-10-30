require_relative '../middleman-core/lib/middleman-core/version'

Gem::Specification.new do |s|
  s.name        = 'middleman'
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['Thomas Reynolds', 'Ben Hollis', 'Karl Freeman']
  s.email       = ['me@tdreyno.com', 'ben@benhollis.net', 'karlfreeman@gmail.com']
  s.homepage    = 'http://middlemanapp.com'
  s.summary     = 'Hand-crafted frontend development'
  s.description = 'A static site generator. Provides dozens of templating languages (Haml, Sass, Slim, CoffeeScript, and more). Makes minification, compression, cache busting, Yaml data (and more) an easy part of your development cycle.'

  s.files        = `git ls-files -z`.split("\0")

  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency('middleman-core', Middleman::VERSION)
  s.add_dependency('middleman-cli', Middleman::VERSION)
end
