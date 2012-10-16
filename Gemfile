source :rubygems

group :development do
  gem "rake",     "~> 0.9.2"
  gem "rdoc",     "~> 3.9"
  gem "yard",     "~> 0.8.0"
end

group :test do
  gem "cucumber", "~> 1.2.0"
  gem "fivemat"
  gem "aruba",    "~> 0.4.11"
  gem "rspec",    "~> 2.7"

  # For actual tests
  gem "sinatra"
  gem "temple", "~> 0.5.2"
  gem "slim", "~> 1.2"
  gem "coffee-filter", "~> 0.1.1"
  gem "liquid", "~> 2.2"
  gem "cane"

  platforms :ruby do
    gem "therubyracer"
    
    gem "redcarpet", "~> 2.1.1"
  end
  
  platforms :jruby do 
    gem "therubyrhino", "1.73.5"
  end
  
  gem "less", "~> 2.2"
end

gem "middleman-sprockets", :github => "middleman/middleman-sprockets"
gem "middleman-core", :path => "middleman-core"
gem "middleman-more", :path => "middleman-more"
gem "middleman", :path => "middleman"