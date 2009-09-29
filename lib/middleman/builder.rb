require 'middleman'

module Middleman
  class Builder
    def self.render_file(source, destination)
      # Middleman.set :environment, :build
      
      request_path = destination.gsub(File.join(Dir.pwd, 'build'), "")
      browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman))
      browser.get(request_path)
      browser.last_response.body
    end
  end
end
