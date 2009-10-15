module Middleman
  module Rack
    class Static
      def initialize(app, options={})
        @app = app
        root = Middleman::Base.public
        @file_server = ::Rack::File.new(root)
      end

      def call(env)
        path = env["PATH_INFO"]
        if path.include?("favicon.ico") || File.exists?(File.join(Middleman::Base.public, path))
          @file_server.call(env)
        else
          @app.call(env)
        end
      end
    end
  end
end