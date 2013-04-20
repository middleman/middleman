# Minify CSS Extension
class Middleman::Extensions::MinifyCss < ::Middleman::Extension
  option :compressor, nil, 'Set the CSS compressor to use.'
  option :inline, false, 'Whether to minify CSS inline within HTML files'
  option :ignore, [], 'Patterns to avoid minifying'

  def initialize(app, options_hash={}, &block)
    super

    app.config.define_setting :css_compressor, nil, 'Set the CSS compressor to use. Deprecated in favor of the :compressor option when activating :minify_css'
  end

  def after_configuration
    chosen_compressor = app.config[:css_compressor] || options[:compressor] || SassCompressor

    # Setup Rack middleware to minify CSS
    app.use Rack, :compressor => chosen_compressor,
                  :ignore     => options[:ignore] + [/\.min\./],
                  :inline     => options[:inline]
  end

  class SassCompressor
    def self.compress(style, options = {})
      root_node = ::Sass::SCSS::CssParser.new(style, 'middleman-css-input', 1).parse
      root_node.options = { :style => :compressed }
      root_node.render.strip
    end
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
