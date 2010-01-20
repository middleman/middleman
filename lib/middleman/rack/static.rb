class Middleman::Rack::Static
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    public_file_path = File.join(Middleman::Base.public, env["PATH_INFO"])
    view_file_path   = File.join(Middleman::Base.views, env["PATH_INFO"])

    if File.exists?(public_file_path) && !File.directory?(public_file_path)
      env["DOWNSTREAM"] = ::Rack::File.new(Middleman::Base.public).call(env)
    elsif File.exists?(view_file_path) && !File.directory?(view_file_path)
      env["DOWNSTREAM"] = ::Rack::File.new(Middleman::Base.views).call(env)
    end
    
    @app.call(env)
  end
end