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
gem 'less', '2.3.0', require: false
gem 'slim', '~> 2.0', require: false
gem 'liquid', '~> 2.6', require: false
gem 'stylus', '~> 1.0', require: false
gem 'sinatra','~> 1.4', require: false
gem 'asciidoctor', '~> 0.1', require: false

# For less, since it doesn't use ExecJS (which also means less wont work on windows)
gem 'therubyracer', platforms: :ruby
gem 'therubyrhino', platforms: :jruby

# Redcarpet doesn't work on JRuby
gem 'redcarpet', '~> 3.1', require: false unless RUBY_ENGINE == 'jruby'

# Code Quality
gem 'rubocop', '~> 0.24', require: false
gem 'simplecov', '0.7.1', require: false
gem 'coveralls', '~> 0.7', require: false

# Middleman itself
gem 'middleman', path: 'middleman'
gem 'middleman-core', path: 'middleman-core'
gem 'middleman-sprockets', github: 'middleman/middleman-sprockets'
