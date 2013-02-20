source :rubygems

# Make sure to use Haml 4 for tests
gem "haml", "~> 4.0.0"

# Build and doc tools
gem "rake",     "~> 10.0.3"
gem "yard",     "~> 0.8.0"

# Test tools
gem "cucumber", "~> 1.2.1"
gem "fivemat",  "~> 1.1.0"
gem "aruba",    "~> 0.5.1"
gem "rspec",    "~> 2.12"

# Optional middleman dependencies, included for tests
gem "sinatra"
gem "slim", "~> 1.2.0", :require => false
gem "liquid", "~> 2.2", :require => false
gem "less", "~> 2.2", :require => false
gem "stylus", "~> 0.6.2", :require => false

platforms :ruby do
  gem "therubyracer", "0.10.2"
  gem "redcarpet", "~> 2.1.1"
end

platforms :jruby do
  gem "therubyrhino", "1.73.5"
end

# Middleman itself
gem "middleman-core", :path => "middleman-core"
gem "middleman-more", :path => "middleman-more"
gem "middleman-sprockets", :github => "middleman/middleman-sprockets"
gem "middleman", :path => "middleman"
