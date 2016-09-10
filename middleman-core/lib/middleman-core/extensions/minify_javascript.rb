require 'active_support/core_ext/object/try'
require 'middleman-core/contracts'
require 'memoist'

# Minify Javascript Extension
class Middleman::Extensions::MinifyJavascript < ::Middleman::Extension
  option :inline, false, 'Whether to minify JS inline within HTML files'
  option :ignore, [], 'Patterns to avoid minifying'
  option :compressor, proc {
    require 'uglifier'
    ::Uglifier.new
  }, 'Set the JS compressor to use.'
  option :content_types, %w(application/javascript), 'Content types of resources that contain JS'
  option :inline_content_types, %w(text/html text/php), 'Content types of resources that contain inline JS'

  def ready
    # Setup Rack middleware to minify JS
    app.use Rack, compressor: options[:compressor],
                  ignore: Array(options[:ignore]) + [/\.min\./],
                  inline: options[:inline],
                  content_types: options[:content_types],
                  inline_content_types: options[:inline_content_types]
  end

  # Rack middleware to look for JS and compress it
  class Rack
    extend Memoist
    include Contracts
    INLINE_JS_REGEX = /(<script[^>]*>\s*(?:\/\/(?:(?:<!--)|(?:<!\[CDATA\[))\n)?)(.*?)((?:(?:\n\s*)?\/\/(?:(?:-->)|(?:\]\]>)))?\s*<\/script>)/m

    # Init
    # @param [Class] app
    # @param [Hash] options
    Contract RespondTo[:call], {
      ignore: ArrayOf[PATH_MATCHER],
      inline: Bool,
      compressor: Or[Proc, RespondTo[:to_proc], RespondTo[:compress]]
    } => Any
    def initialize(app, options={})
      @app = app
      @ignore = options.fetch(:ignore)
      @inline = options.fetch(:inline)

      @compressor = options.fetch(:compressor)
      @compressor = @compressor.to_proc if @compressor.respond_to? :to_proc
      @compressor = @compressor.call if @compressor.is_a? Proc
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
        headers['Content-Length'] = minified.bytesize.to_s
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
    memoize :ignore?

    # Whether this type of content can be minified
    # @param [String, nil] content_type
    # @return [Boolean]
    def minifiable?(content_type)
      @content_types.include?(content_type)
    end
    memoize :minifiable?

    # Whether this type of content contains inline content that can be minified
    # @param [String, nil] content_type
    # @return [Boolean]
    def minifiable_inline?(content_type)
      @inline_content_types.include?(content_type)
    end
    memoize :minifiable_inline?

    # Minify the content
    # @param [String] content
    # @return [String]
    def minify(content)
      @compressor.compress(content)
    rescue ExecJS::ProgramError => e
      warn "WARNING: Couldn't compress JavaScript in #{@path}: #{e.message}"
      content
    end
    memoize :minify

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
        if !first.include?('type=') || first.include?('text/javascript')
          first + minify(inline_content) + last
        else
          match
        end
      end
    end
    memoize :minify_inline
  end
end
