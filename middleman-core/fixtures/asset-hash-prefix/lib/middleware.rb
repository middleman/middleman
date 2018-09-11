class Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    body = ''
    response.each { |part| body += part }
    if /css$/.match?(env['PATH_INFO'])
      body += "\n/* Added by Rack filter */"
      status, headers, response = Rack::Response.new(body, status, headers).finish
    end
    [status, headers, response]
  end
end
