source 'http://rubygems.org'

# Make sure to use Haml 4 for tests
gem "haml", "~> 4.0.0"

# Build and doc tools
gem "rake",     "~> 10.0.3"
gem "yard",     "~> 0.8.0"

# Test tools
gem "cucumber", "~> 1.2.1"
gem "fivemat",  "~> 1.2.0"
gem "aruba",    "~> 0.5.1"
gem "rspec",    "~> 2.12"
gem 'gherkin', '<= 2.11.6' # for annoying "eval" warnings

# Optional middleman dependencies, included for tests
gem "sinatra"
gem "slim", :require => false
gem "liquid", :require => false
gem "less", :require => false
gem "stylus", :require => false

platforms :ruby do
  gem "therubyracer"
  gem "redcarpet"
end

platforms :jruby do
  gem "therubyrhino"
end

# Middleman itself
gem "middleman-core", :path => "middleman-core"
gem "middleman-more", :path => "middleman-more"
gem "middleman-sprockets", :github => "middleman/middleman-sprockets"
gem "middleman", :path => "middleman"
