# Extension namespace
module Middleman::Extensions
  
  # Minify Javascript Extension
  module MinifyJavascript
    
    # Setup extension
    class << self
      
      # Once registered
      def registered(app)
        app.set :js_compressor, false

        # Once config is parsed
        app.after_configuration do
          unless respond_to?(:js_compressor) && js_compressor
            require 'uglifier'
            set :js_compressor, ::Uglifier.new
          end
          
          # Setup Rack to watch for inline JS
          use InlineJavascriptRack, :compressor => js_compressor
        end
      end
      alias :included :registered
    end

    # Rack middleware to look for JS in HTML and compress it
    class InlineJavascriptRack
      
      # Init
      # @param [Class] app
      # @param [Hash] options
      def initialize(app, options={})
        @app = app
        @compressor = options[:compressor]
      end

      # Rack interface
      # @param [Rack::Environmemt] env
      # @return [Array]
      def call(env)
        status, headers, response = @app.call(env)

        path = env["PATH_INFO"]

        if path.end_with?('.html') || path.end_with?('.php')
          uncompressed_source = extract_response_text(response)

          minified = uncompressed_source.gsub(/(<script[^>]*>\s*(?:\/\/(?:(?:<!--)|(?:<!\[CDATA\[))\n)?)(.*?)((?:(?:\n\s*)?\/\/(?:(?:-->)|(?:\]\]>)))?\s*<\/script>)/m) do |match|
            first = $1
            javascript = $2
            last = $3

            # Only compress script tags that contain JavaScript (as opposed
            # to something like jQuery templates, identified with a "text/html"
            # type.
            if first =~ /<script>/ || first.include?('text/javascript')
              minified_js = @compressor.compress(javascript)

              first << minified_js << last
            else
              match
            end
          end

          headers["Content-Length"] = ::Rack::Utils.bytesize(minified).to_s
          response = [minified]
        elsif path.end_with?('.js') && path !~ /\.min\./
          uncompressed_source = extract_response_text(response)
          minified_js = @compressor.compress(uncompressed_source)

          headers["Content-Length"] = ::Rack::Utils.bytesize(minified_js).to_s
          response = [minified_js]
        end

        [status, headers, response]
      end

      private

      def extract_response_text(response)
        case(response)
        when String
          response
        when Array
          response.join
        when Rack::Response
          response.body.join
        when Rack::File
          File.read(response.path)
        else
          response.to_s
        end
      end
    end
  end
  
  # Register extension
  # register :minify_javascript, MinifyJavascript
end
