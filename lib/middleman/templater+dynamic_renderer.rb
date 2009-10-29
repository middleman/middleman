require 'rack/test' # Use Rack::Test to access Sinatra without starting up a full server

# Monkey-patch to use a dynamic renderer
class Templater::Actions::File
  def identical?
    if exists?
      return true if File.mtime(source) < File.mtime(destination)
      FileUtils.identical?(source, destination)
    else
      false
    end
  end
end

class Templater::Actions::Template
  def render
    @@rack_test ||= Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base))
    
    @render_cache ||= begin
      # The default render just requests the page over Rack and writes the response
      request_path = destination.gsub(File.join(Dir.pwd, Middleman::Base.build_dir), "")
      @@rack_test.get(request_path)
      @@rack_test.last_response.body
    end
  end
end