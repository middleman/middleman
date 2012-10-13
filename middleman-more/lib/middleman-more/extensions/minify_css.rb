# Extensions namespace
module Middleman
  module Extensions
  
    # Minify CSS Extension 
    class MinifyCss < ::Middleman::Extension
      config_options :compressor => false,
                     :ignore => [],
                     :inline => false
      
      def after_configuration
        # TODO: Deprecation warning for set :css_compressor 
        chosen_compressor = options[:compressor] || begin
          require "middleman-more/extensions/minify_css/rainpress"
          ::Rainpress
        end

        # Setup Rack middleware to minify CSS
        ignore = Array(options[:ignore]) << /\.min\./
        use Rack, :compressor => chosen_compressor,
                  :ignore     => ignore,
                  :inline     => options[:inline]
      end

      # Rack middleware to look for CSS and compress it
      class Rack

        # Init
        # @param [Class] app
        # @param [Hash] options
        def initialize(app, options={})
          @app = app
          @compressor = options[:compressor]
          @ignore = options[:ignore]
          @inline = options[:inline]
        end

        # Rack interface
        # @param [Rack::Environmemt] env
        # @return [Array]
        def call(env)
          status, headers, response = @app.call(env)

          path = env["PATH_INFO"]

          if (path.end_with?('.html') || path.end_with?('.php')) && @inline
            uncompressed_source = ::Middleman::Util.extract_response_text(response)

            minified = uncompressed_source.gsub(/(<style[^>]*>\s*(?:\/\*<!\[CDATA\[\*\/\n)?)(.*?)((?:(?:\n\s*)?\/\*\]\]>\*\/)?\s*<\/style>)/m) do |match|
              first = $1
              css = $2
              last = $3

              minified_css = @compressor.compress(css)

              first << minified_css << last
            end

            headers["Content-Length"] = ::Rack::Utils.bytesize(minified).to_s
            response = [minified]
          elsif path.end_with?('.css') && @ignore.none? {|ignore| Middleman::Util.path_match(ignore, path) }
            uncompressed_source = ::Middleman::Util.extract_response_text(response)
            minified_css = @compressor.compress(uncompressed_source)

            headers["Content-Length"] = ::Rack::Utils.bytesize(minified_css).to_s
            response = [minified_css]
          end

          [status, headers, response]
        end
      end
    end
  end
end
