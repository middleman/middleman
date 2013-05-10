class Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    body = ''
    response.each {|part| body += part }
    if (env["PATH_INFO"] =~ /css$/)
      body += "\n/* Added by Rack filter */"
      status, headers, response = Rack::Response.new(body, status, headers).finish
    end
    [status, headers, response]
  end
end
