source 'https://rubygems.org'

# Build and doc tools
gem 'rake', '~> 13.3', require: false
gem 'yard', '~> 0.9.45', require: false

# Test tools
# Aruba 3 runs each scenario in a uniquely named directory, which leaks into
# Sass source maps and changes the asset hashes the features assert on
gem 'aruba', '~> 2.2', require: false
gem 'capybara', require: false
gem 'cucumber', require: false
gem 'rspec', require: false

# Debug tools
gem 'byebug'
gem 'pry'
gem 'pry-rescue'

# Optional middleman dependencies, included for tests
gem 'liquid', RUBY_VERSION <= '2.7' ? '< 5.6' : '> 0', require: false
gem 'redcarpet', '>= 3.1', require: false
gem 'sinatra', '~> 4.2', require: false
gem 'slim', '~> 5.0', require: false
gem 'actionview', RUBY_VERSION < '3.2' ? '~> 7.0' : '~> 8.0', require: false
# ActiveSupport 7.1 passes quirks_mode to JSON.generate, which json 3 rejects
gem 'json', RUBY_VERSION < '3.1' ? '< 3' : '> 0', require: false

# Dns server to test preview server
gem 'rubydns', '~> 1.0.1', require: false

# Code Quality
gem 'simplecov', require: false

# Middleman itself
gem 'middleman-cli', path: 'middleman-cli'
gem 'middleman-core', path: 'middleman-core'
