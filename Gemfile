source 'https://rubygems.org'

# Build and doc tools
gem 'rake',     '~> 10.0.3', require: false
gem 'yard',     '~> 0.8.0', require: false

# Test tools
gem 'cucumber', '~> 1.3.1'
gem 'fivemat',  '~> 1.2.1'
gem 'aruba',    '~> 0.5.1'
gem 'rspec',    '~> 2.12'
gem 'simplecov'

# Optional middleman dependencies, included for tests
gem 'sinatra', require: false
gem 'slim', require: false
gem 'liquid', require: false
gem 'less', '~> 2.3.0', require: false
gem 'stylus', require: false
gem 'asciidoctor', require: false

platforms :ruby do
  gem 'therubyracer'
  gem 'redcarpet', '~> 3.1'
  gem 'pry', require: false, group: :development
end

platforms :jruby do
  gem 'therubyrhino'
end

# Code Quality
gem 'coveralls', require: false
gem 'rubocop', require: false

# Middleman itself
gem 'middleman-core', path: 'middleman-core'
gem 'middleman-sprockets', github: 'middleman/middleman-sprockets'
gem 'middleman', path: 'middleman'
