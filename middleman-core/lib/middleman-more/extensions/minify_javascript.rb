# Minify Javascript Extension
class Middleman::Extensions::MinifyJavascript < ::Middleman::Extension
  option :compressor, nil, 'Set the JS compressor to use.'
  option :inline, false, 'Whether to minify JS inline within HTML files'
  option :ignore, [], 'Patterns to avoid minifying'
  option :content_types, %w(application/javascript), 'Content types of resources that contain JS'
  option :inline_content_types, %w(text/html text/php), 'Content types of resources that contain inline JS'

  def initialize(app, options_hash={}, &block)
    super

    app.config.define_setting :js_compressor, nil, 'Set the JS compressor to use. Deprecated in favor of the :compressor option when activating :minify_js'
  end

  def after_configuration
    chosen_compressor = app.config[:js_compressor] || options[:compressor] || begin
      require 'uglifier'
      ::Uglifier.new
    end

    # Setup Rack middleware to minify JS
    app.use Rack, compressor: chosen_compressor,
                  ignore: Array(options[:ignore]) + [/\.min\./],
                  inline: options[:inline],
                  content_types: options[:content_types],
                  inline_content_types: options[:inline_content_types]
  end

  # Rack middleware to look for JS and compress it
  class Rack
    INLINE_JS_REGEX = /(<script[^>]*>\s*(?:\/\/(?:(?:<!--)|(?:<!\[CDATA\[))\n)?)(.*?)((?:(?:\n\s*)?\/\/(?:(?:-->)|(?:\]\]>)))?\s*<\/script>)/m

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

      type = headers['Content-Type'].try(:slice, /^[^;]*/)
      @path = env['PATH_INFO']

      minified = if @inline && minifiable_inline?(type)
        minify_inline(::Middleman::Util.extract_response_text(response))
      elsif minifiable?(type) && !ignore?(@path)
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
    rescue ExecJS::ProgramError => e
      warn "WARNING: Couldn't compress JavaScript in #{@path}: #{e.message}"
      content
    end

    # Detect and minify inline content
    # @param [String] content
    # @return [String]
    def minify_inline(content)
      content.gsub(INLINE_JS_REGEX) do |match|
        first = $1
        inline_content = $2
        last = $3

        # Only compress script tags that contain JavaScript (as opposed to
        # something like jQuery templates, identified with a "text/html" type).
        if first.include?('<script>') || first.include?('text/javascript')
          first + minify(inline_content) + last
        else
          match
        end
      end
    end
  end
end
