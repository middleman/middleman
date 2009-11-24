module Middleman
  module Rack
    class Static
      def initialize(app, options={})
        @app = app
        root = Middleman::Base.public
        @file_server = ::Rack::File.new(root)
      end

      def templatize_js?(path)
        path.match(/\.js$/) && Middleman::Base.respond_to?(:minify_javascript?) && Middleman::Base.minify_javascript?
      end

      def call(env)
        path = env["PATH_INFO"]
        file_path = File.join(Middleman::Base.public, path)
        
        if templatize_js?(path)
          @app.call(env)
        elsif path.include?("favicon.ico") || (File.exists?(file_path) && !File.directory?(file_path))
          @file_server.call(env)
        else
          @app.call(env)
        end
      end
    end
  end
end