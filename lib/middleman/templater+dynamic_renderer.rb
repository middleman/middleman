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
    # The default render just requests the page over Rack and writes the response
    request_path = destination.gsub(File.join(Dir.pwd, Middleman::Base.build_dir), "")
    browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base))
    browser.get(request_path)
    browser.last_response.body
  end

  def identical?
    if File.exists?(destination)
      extension = File.extname(source)
      return true if !%w(.sass .js .haml).include?(extension) && File.exists?(source) && File.mtime(source) < File.mtime(destination)
      File.read(destination) == render 
    else
      false
    end
  end
end