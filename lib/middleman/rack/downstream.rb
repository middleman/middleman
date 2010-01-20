class Middleman::Rack::Downstream
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    env["DOWNSTREAM"] || @app.call(env)
  end
end