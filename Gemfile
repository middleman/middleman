source 'https://rubygems.org'

# Build and doc tools
gem 'rake', '~> 10.3', require: false
gem 'yard', '~> 0.8', require: false

# Test tools
gem 'pry', '~> 0.10', group: :development
gem 'aruba', '~> 0.6'
gem 'rspec', '~> 3.0'
gem 'fivemat', '~> 1.3'
gem 'cucumber', '~> 1.3'

# Optional middleman dependencies, included for tests
gem 'less', '2.3', require: false
gem 'slim', '>= 2.0', require: false
gem 'liquid', '>= 2.6', require: false
gem 'stylus', '>= 1.0', require: false
gem 'sinatra', '>= 1.4', require: false
gem 'redcarpet', '>= 3.1', require: false unless RUBY_ENGINE == 'jruby'
gem 'asciidoctor', '~> 0.1', require: false

# To test javascript
gem 'poltergeist', '~> 1.6.0', require: false

# For less, note there is no compatible JS runtime for windows
gem 'therubyracer', '>= 0.12', platforms: :ruby
gem 'therubyrhino', '>= 2.0', platforms: :jruby

# Code Quality
gem 'rubocop', '~> 0.24', require: false
gem 'simplecov', '0.9', require: false
gem 'coveralls', '~> 0.7', require: false

# Middleman itself
gem 'middleman', path: 'middleman'
gem 'middleman-core', path: 'middleman-core'
gem 'middleman-sprockets', github: 'middleman/middleman-sprockets', branch: 'v3-stable'
