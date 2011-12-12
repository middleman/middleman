module Middleman::Extensions
  module MinifyJavascript
    class << self
      def registered(app)
        app.after_configuration do
          if !js_compressor
            require 'uglifier'
            set :js_compressor, ::Uglifier.new
          end
          
          use InlineJavascriptRack, :compressor => js_compressor
        end
      end
      alias :included :registered
    end

    class InlineJavascriptRack
      def initialize(app, options={})
        @app = app
        @compressor = options[:compressor]
      end

      def call(env)
        status, headers, response = @app.call(env)

        if env["PATH_INFO"].match(/\.html$/)
          uncompressed_source = case(response)
            when String
              response
            when Array
              response.join
            when Rack::Response
              response.body.join
            when Rack::File
              File.read(response.path)
          end

          minified = uncompressed_source.gsub(/(<scri.*?\/\/<!\[CDATA\[\n)(.*?)(\/\/\]\].*?<\/script>)/m) do |m|
            first = $1
            uncompressed_source = $2
            last = $3
            minified_js = @compressor.compress(uncompressed_source)

            first << minified_js << "\n" << last
          end
          headers["Content-Length"] = ::Rack::Utils.bytesize(minified).to_s
          response = [minified]
        end

        [status, headers, response]
      end
    end
  end
  
  register :minify_javascript, MinifyJavascript
end