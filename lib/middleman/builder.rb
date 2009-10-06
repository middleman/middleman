# Use Rack::Test to access Sinatra without starting up a full server
require 'rack/test'

# Placeholder for any methods the builder needs to abstract to allow feature integration
module Middleman
  class Builder
    # The default render just requests the page over Rack and writes the response
    def self.render_file(source, destination)
      request_path = destination.gsub(File.join(Dir.pwd, Middleman::Base.build_dir), "")
      browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base))
      browser.get(request_path)
      browser.last_response.body
    end
  end
end
