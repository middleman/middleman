source 'https://rubygems.org'

# Build and doc tools
gem "rake",     "~> 10.0.3", :require => false
gem "yard",     "~> 0.8.0", :require => false

# Test tools
gem "cucumber", "~> 1.3.1"
gem "fivemat"
gem "aruba",    "~> 0.5.1"
gem "rspec",    "~> 2.12"
gem "simplecov"

# Optional middleman dependencies, included for tests
gem "haml", "~> 4.0.0", :require => false # Make sure to use Haml 4 for tests
gem "sinatra", :require => false
gem "slim", :require => false
gem "liquid", :require => false
gem "less", "~> 2.3.0", :require => false
gem "stylus", :require => false
gem "asciidoctor", :require => false

platforms :ruby do
  gem "therubyracer"
  gem "redcarpet", "~> 3.0"
  gem "pry", :require => false
  gem "pry-debugger", :require => false
end

platforms :jruby do
  gem "therubyrhino"
end

# Code Quality
gem "cane", :platforms => [:mri_19, :mri_20], :require => false
gem 'coveralls', :require => false

# Middleman itself
gem "middleman-core", :path => "middleman-core"
gem "middleman-sprockets", :github => "middleman/middleman-sprockets"
gem "middleman", :path => "middleman"
