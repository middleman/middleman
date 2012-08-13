# Extension namespace
module Middleman
  module Extensions

    # Minify Javascript Extension
    module MinifyJavascript

      # Setup extension
      class << self

        # Once registered
        def registered(app, options={})
          app.set :js_compressor, false

          ignore = Array(options[:ignore]) << /\.min\./
          inline = options[:inline] || false

          # Once config is parsed
          app.after_configuration do
            chosen_compressor = js_compressor || options[:compressor] || begin
              require 'uglifier'
              ::Uglifier.new
            end

            # Setup Rack middlware to minify JS
            use Rack, :compressor => chosen_compressor,
                      :ignore     => ignore,
                      :inline     => inline
          end
        end
        alias :included :registered
      end

      # Rack middleware to look for JS and compress it
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

          begin
            if (path.end_with?('.html') || path.end_with?('.php')) && @inline
              uncompressed_source = ::Middleman::Util.extract_response_text(response)

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
            elsif path.end_with?('.js') && @ignore.none? {|ignore| Middleman::Util.path_match(ignore, path) }
              uncompressed_source = ::Middleman::Util.extract_response_text(response)
              minified_js = @compressor.compress(uncompressed_source)

              headers["Content-Length"] = ::Rack::Utils.bytesize(minified_js).to_s
              response = [minified_js]
            end
          rescue ExecJS::ProgramError => e
            warn "WARNING: Couldn't compress JavaScript in #{path}: #{e.message}"
          end

          [status, headers, response]
        end
      end
    end
  end
end
