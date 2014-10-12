# Minify CSS Extension
class Middleman::Extensions::MinifyCss < ::Middleman::Extension
  option :compressor, nil, 'Set the CSS compressor to use.'
  option :inline, false, 'Whether to minify CSS inline within HTML files'
  option :ignore, [], 'Patterns to avoid minifying'
  option :content_types, %w(text/css), 'Content types of resources that contain CSS'
  option :inline_content_types, %w(text/html text/php), 'Content types of resources that contain inline CSS'

  def initialize(app, options_hash={}, &block)
    super

    app.config.define_setting :css_compressor, nil, 'Set the CSS compressor to use. Deprecated in favor of the :compressor option when activating :minify_css'
  end

  def after_configuration
    chosen_compressor = app.config[:css_compressor] || options[:compressor] || SassCompressor

    # Setup Rack middleware to minify CSS
    app.use Rack, compressor: chosen_compressor,
                  ignore: Array(options[:ignore]) + [/\.min\./],
                  inline: options[:inline],
                  content_types: options[:content_types],
                  inline_content_types: options[:inline_content_types]
  end

  class SassCompressor
    def self.compress(style, options={})
      root_node = ::Sass::SCSS::CssParser.new(style, 'middleman-css-input', 1).parse
      root_node.options = options.merge(style: :compressed)
      root_node.render.strip
    end
  end

  # Rack middleware to look for CSS and compress it
  class Rack
    INLINE_CSS_REGEX = /(<style[^>]*>\s*(?:\/\*<!\[CDATA\[\*\/\n)?)(.*?)((?:(?:\n\s*)?\/\*\]\]>\*\/)?\s*<\/style>)/m

    # Init
    # @param [Class] app
    # @param [Hash] options
    def initialize(app, options={})
      @app = app
      @compressor = options[:compressor]
      @ignore = options[:ignore]
      @inline = options[:inline]
      @content_types = options[:content_types]
      @inline_content_types = options[:inline_content_types]
    end

    # Rack interface
    # @param [Rack::Environmemt] env
    # @return [Array]
    def call(env)
      status, headers, response = @app.call(env)

      content_type = headers['Content-Type'].try(:slice, /^[^;]*/)
      path = env['PATH_INFO']

      minified = if @inline && minifiable_inline?(content_type)
        minify_inline(::Middleman::Util.extract_response_text(response))
      elsif minifiable?(content_type) && !ignore?(path)
        minify(::Middleman::Util.extract_response_text(response))
      end

      if minified
        headers['Content-Length'] = ::Rack::Utils.bytesize(minified).to_s
        response = [minified]
      end

      [status, headers, response]
    end

    private

    # Whether the path should be ignored
    # @param [String] path
    # @return [Boolean]
    def ignore?(path)
      @ignore.any? { |ignore| Middleman::Util.path_match(ignore, path) }
    end

    # Whether this type of content can be minified
    # @param [String, nil] content_type
    # @return [Boolean]
    def minifiable?(content_type)
      @content_types.include?(content_type)
    end

    # Whether this type of content contains inline content that can be minified
    # @param [String, nil] content_type
    # @return [Boolean]
    def minifiable_inline?(content_type)
      @inline_content_types.include?(content_type)
    end

    # Minify the content
    # @param [String] content
    # @return [String]
    def minify(content)
      @compressor.compress(content)
    end

    # Detect and minify inline content
    # @param [String] content
    # @return [String]
    def minify_inline(content)
      content.gsub(INLINE_CSS_REGEX) do
        $1 + minify($2) + $3
      end
    end
  end
end
