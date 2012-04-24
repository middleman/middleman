# Extensions namespace
module Middleman::Extensions
  
  # Minify CSS Extension 
  module MinifyCss
    
    # Setup extension
    class << self
      
      # Once registered
      def registered(app, options={})
        app.set :css_compressor, false

        ignore = Array(options[:ignore]) << /\.min\./

        app.after_configuration do
          unless respond_to?(:css_compressor) && css_compressor
            require "middleman-more/extensions/minify_css/rainpress"
            set :css_compressor, ::Rainpress
          end

          # Setup Rack to watch for inline JS
          use InlineCSSRack, :compressor => css_compressor, :ignore => ignore
        end
      end
      alias :included :registered
    end
  end

  # Rack middleware to look for JS in HTML and compress it
  class InlineCSSRack
      
    # Init
    # @param [Class] app
    # @param [Hash] options
    def initialize(app, options={})
      @app = app
      @compressor = options[:compressor]
      @ignore = options[:ignore]
    end

    # Rack interface
    # @param [Rack::Environmemt] env
    # @return [Array]
    def call(env)
      status, headers, response = @app.call(env)

      path = env["PATH_INFO"]

      if path.end_with?('.html') || path.end_with?('.php')
        uncompressed_source = extract_response_text(response)

        minified = uncompressed_source.gsub(/(<style[^>]*>\s*(?:\/\*<!\[CDATA\[\*\/\n)?)(.*?)((?:(?:\n\s*)?\/\*\]\]>\*\/)?\s*<\/style>)/m) do |match|
          first = $1
          css = $2
          last = $3

          minified_css = @compressor.compress(css)

          first << minified_css << last
        end

        headers["Content-Length"] = ::Rack::Utils.bytesize(minified).to_s
        response = [minified]
      elsif path.end_with?('.css') && @ignore.none? {|ignore| path =~ ignore }
        uncompressed_source = extract_response_text(response)
        minified_css = @compressor.compress(uncompressed_source)

        headers["Content-Length"] = ::Rack::Utils.bytesize(minified_css).to_s
        response = [minified_css]
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
  # Register extension
  # register :minify_css, MinifyCss
end
