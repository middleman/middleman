require 'zlib'
require 'stringio'

module Middleman::Extensions
  
  # This extension Gzips assets when building. 
  # Gzipped assets can be served directly by Apache or
  # Nginx with the proper configuration, and pre-zipping means that we
  # can use a more agressive compression level at no CPU cost per request.
  module GzipAssets
    class << self
      def registered(app)
        return unless app.inst.build?

        app.after_configuration do
          # Register a reroute transform that adds .gz to asset paths
          sitemap.reroute do |destination, page|
            if %w(.js .css).include? page.ext
              destination + '.gz'
            else
              destination
            end
          end

          use GzipRack
        end
      end
      alias :included :registered
    end

    # Rack middleware to GZip asset files
    class GzipRack
      
      # Init
      # @param [Class] app
      # @param [Hash] options
      def initialize(app, options={})
        @app = app
      end

      # Rack interface
      # @param [Rack::Environmemt] env
      # @return [Array]
      def call(env)
        status, headers, response = @app.call(env)

        if env["PATH_INFO"].match(/\.(js|css).gz$/)
          contents = case(response)
            when String
              response
            when Array
              response.join
            when Rack::Response
              response.body.join
            when Rack::File
              File.read(response.path)
          end

          gzipped = ""
          StringIO.open(gzipped) do |s|
            gz = Zlib::GzipWriter.new(s, Zlib::BEST_COMPRESSION)
            gz.write contents
            gz.close
          end

          headers["Content-Length"] = ::Rack::Utils.bytesize(gzipped).to_s
          response = [gzipped]
        end

        [status, headers, response]
      end
    end
  end
end
