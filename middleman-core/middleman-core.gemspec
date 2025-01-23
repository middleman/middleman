require_relative './lib/middleman-core/version'

Gem::Specification.new do |s|
  s.name        = 'middleman-core'
  s.version     = Middleman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['Thomas Reynolds', 'Ben Hollis', 'Karl Freeman']
  s.email       = ['me@tdreyno.com', 'ben@benhollis.net', 'karlfreeman@gmail.com']
  s.homepage    = 'https://middlemanapp.com'
  s.summary     = 'Hand-crafted frontend development'
  s.description = 'A static site generator. Provides dozens of templating languages (Haml, Sass, Slim, CoffeeScript, and more). Makes minification, compression, cache busting, Yaml data (and more) an easy part of your development cycle.'

  s.files        = `git ls-files -z`.split("\0")
  s.test_files   = `git ls-files -z -- {fixtures,features}/*`.split("\0")

  s.required_ruby_version = '>= 2.7.0'

  # Core
  s.add_dependency('bundler', '~> 2.0')
  s.add_dependency('rack', '>= 3')
  s.add_dependency('rackup')
  s.add_dependency('tilt', ['~> 2.2'])
  s.add_dependency('erubi')
  s.add_dependency('haml', ['>= 4.0.5'])
  s.add_dependency('coffee-script', ['~> 2.2'])
  s.add_dependency('kramdown', ['~> 2.4'])
  s.add_dependency('fast_blank')
  s.add_dependency('parallel')
  s.add_dependency('servolux')
  s.add_dependency('dotenv')
  s.add_dependency('toml')
  s.add_dependency('webrick')

  # Helpers
  s.add_dependency('activesupport', ['>= 6.1'])
  s.add_dependency('padrino-helpers', ['~> 0.15.0'])
  s.add_dependency("addressable", ["~> 2.4"])
  s.add_dependency('memoist', ['~> 0.14'])

  # Watcher
  s.add_dependency('listen', ['~> 3.0'])

  # i18n
  s.add_dependency('i18n', '>= 1.6', '< 1.15')

  # Automatic Image Sizes
  s.add_dependency('fastimage', ['~> 2.0'])

  # Sass and Minify CSS
  s.add_dependency('sassc', ['~> 2.0'])

  # Minify JS
  s.add_dependency('uglifier', ['>= 3', '< 5'])
  s.add_dependency('execjs', ['~> 2.0'])

  # Testing
  s.add_dependency('contracts')

  # Hash stuff
  s.add_dependency('hashie', '>= 3.4', '< 6.0')
  s.add_dependency('hamster', ['~> 3.0'])
end
