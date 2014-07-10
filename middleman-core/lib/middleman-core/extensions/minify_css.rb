require 'middleman-core/contracts'

# Minify CSS Extension
class Middleman::Extensions::MinifyCss < ::Middleman::Extension
  option :inline, false, 'Whether to minify CSS inline within HTML files'
  option :ignore, [], 'Patterns to avoid minifying'
  option :compressor, proc {
    require 'sass'
    SassCompressor
  }, 'Set the CSS compressor to use.'

  def after_configuration
    # Setup Rack middleware to minify CSS
    app.use Rack, compressor: options[:compressor],
                  ignore: Array(options[:ignore]) + [/\.min\./],
                  inline: options[:inline]
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
    include Contracts
    INLINE_CSS_REGEX = /(<style[^>]*>\s*(?:\/\*<!\[CDATA\[\*\/\n)?)(.*?)((?:(?:\n\s*)?\/\*\]\]>\*\/)?\s*<\/style>)/m

    # Init
    # @param [Class] app
    # @param [Hash] options
    Contract RespondTo[:call], ({
      ignore: ArrayOf[PATH_MATCHER],
      inline: Bool,
      compressor: Or[Proc, RespondTo[:to_proc], RespondTo[:compress]]
    }) => Any
    def initialize(app, options={})
      @app = app
      @ignore = options.fetch(:ignore)
      @inline = options.fetch(:inline)

      @compressor = options.fetch(:compressor)
      @compressor = @compressor.to_proc if @compressor.respond_to? :to_proc
      @compressor = @compressor.call if @compressor.is_a? Proc
    end

    # Rack interface
    # @param [Rack::Environmemt] env
    # @return [Array]
    def call(env)
      status, headers, response = @app.call(env)

      if inline_html_content?(env['PATH_INFO'])
        minified = ::Middleman::Util.extract_response_text(response)
        minified.gsub!(INLINE_CSS_REGEX) do
          $1 << @compressor.compress($2) << $3
        end

        headers['Content-Length'] = ::Rack::Utils.bytesize(minified).to_s
        response = [minified]
      elsif standalone_css_content?(env['PATH_INFO'])
        minified_css = @compressor.compress(::Middleman::Util.extract_response_text(response))

        headers['Content-Length'] = ::Rack::Utils.bytesize(minified_css).to_s
        response = [minified_css]
      end

      [status, headers, response]
    end

    private

    Contract String => Bool
    def inline_html_content?(path)
      (path.end_with?('.html') || path.end_with?('.php')) && @inline
    end

    Contract String => Bool
    def standalone_css_content?(path)
      path.end_with?('.css') && @ignore.none? { |ignore| Middleman::Util.path_match(ignore, path) }
    end
  end
end
