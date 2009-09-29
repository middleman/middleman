require 'rack/test'

module Middleman
  class Builder
    def self.render_file(source, destination)      
      request_path = destination.gsub(File.join(Dir.pwd, Middleman::Base.build_dir), "")
      browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base))
      browser.get(request_path)
      browser.last_response.body
    end
  end
end
