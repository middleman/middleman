source 'https://rubygems.org'

# Build and doc tools
gem 'rake', '~> 10.3.2', require: false
gem 'yard', '~> 0.8.0', require: false

# Test tools
gem 'cucumber', '~> 1.3.15'
gem 'fivemat', '~> 1.3.1'
gem 'aruba', '~> 0.6.0'
gem 'rspec', '~> 3.0'
gem 'simplecov'

# Optional middleman dependencies, included for tests
gem 'sinatra', require: false
gem 'slim', require: false
gem 'liquid', require: false
gem 'less', '~> 2.3.0', require: false
gem 'stylus', require: false

platforms :ruby do
  gem 'therubyracer'
  gem 'redcarpet', '~> 3.1'
  gem 'pry', require: false, group: :development
  # gem 'pry-debugger', require: false, group: :development
  # gem 'pry-stack_explorer', require: false, group: :development
end

platforms :jruby do
  gem 'therubyrhino'
end

# Code Quality
gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'coveralls', require: false
gem 'rubocop', require: false

# Middleman itself
gem 'middleman-core', path: 'middleman-core'
gem 'middleman-cli', path: 'middleman-cli'
gem 'middleman-compass',  github: 'middleman/middleman-compass', require: false
gem 'middleman-sprockets', github: 'middleman/middleman-sprockets', require: false
gem 'middleman', path: 'middleman'
