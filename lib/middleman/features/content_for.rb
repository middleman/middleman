begin
  require 'sinatra/content_for'

  class Middleman::Base
    helpers Sinatra::ContentFor
  end
rescue LoadError
  puts "Sinatra::ContentFor not available. Install it with: gem install sinatra-content-for"
end