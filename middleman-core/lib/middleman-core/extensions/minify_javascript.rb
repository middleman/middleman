require 'middleman-core/contracts'

# Minify Javascript Extension
class Middleman::Extensions::MinifyJavascript < ::Middleman::Extension
  option :inline, false, 'Whether to minify JS inline within HTML files'
  option :ignore, [], 'Patterns to avoid minifying'
  option :compressor, proc {
    require 'uglifier'
    ::Uglifier.new
  }, 'Set the JS compressor to use.'

  def initialize(app, options_hash={}, &block)
    super

    require 'oga'
  end

  def after_configuration
    # Setup Rack middleware to minify CSS
    app.use Rack, compressor: options[:compressor],
                  ignore: Array(options[:ignore]) + [/\.min\./],
                  inline: options[:inline]
  end

  # Rack middleware to look for JS and compress it
  class Rack
    include Contracts

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

      path = env['PATH_INFO']

      begin
        if @inline && (path.end_with?('.html') || path.end_with?('.php'))
          uncompressed_source = ::Middleman::Util.extract_response_text(response)

          minified = minify_inline(uncompressed_source)

          headers['Content-Length'] = ::Rack::Utils.bytesize(minified).to_s
          response = [minified]
        elsif path.end_with?('.js') && @ignore.none? { |ignore| Middleman::Util.path_match(ignore, path) }
          uncompressed_source = ::Middleman::Util.extract_response_text(response)
          minified = @compressor.compress(uncompressed_source)

          headers['Content-Length'] = ::Rack::Utils.bytesize(minified).to_s
          response = [minified]
        end
      rescue ExecJS::ProgramError => e
        warn "WARNING: Couldn't compress JavaScript in #{path}: #{e.message}"
      end

      [status, headers, response]
    end

    private

    Contract String => String
    def minify_inline(content)
      document = Oga.parse_html(content)

      document.xpath('//script[@type="text/javascript" or not(@type)]').each do |script|
        if comment = script.at_xpath('comment()')
          comment.text = comment.text.sub(%r{^(\s*)(.*?)(\s*//\s*)$}m) do
            $1 + @compressor.compress($2) + $3
          end
        else
          script.inner_text = @compressor.compress(script.inner_text)
        end
      end

      document.to_xml
    end
  end
end
