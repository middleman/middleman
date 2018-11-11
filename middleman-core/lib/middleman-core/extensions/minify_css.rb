require 'active_support/core_ext/object/try'
require 'memoist'
require 'middleman-core/contracts'
require 'rack/mime'

# Minify CSS Extension
class Middleman::Extensions::MinifyCss < ::Middleman::Extension
  option :inline, false, 'Whether to minify CSS inline within HTML files'
  option :ignore, [], 'Patterns to avoid minifying'
  option :compressor, proc {
    require 'sass'
    SassCompressor
  }, 'Set the CSS compressor to use.'
  option :content_types, %w[text/css], 'Content types of resources that contain CSS'
  option :inline_content_types, %w[text/html text/php], 'Content types of resources that contain inline CSS'

  INLINE_CSS_REGEX = /(<style[^>]*>\s*(?:\/\*<!\[CDATA\[\*\/\n)?)(.*?)((?:(?:\n\s*)?\/\*\]\]>\*\/)?\s*<\/style>)/m.freeze

  class SassCompressor
    def self.compress(style, options_hash = ::Middleman::EMPTY_HASH)
      root_node = ::Sass::SCSS::CssParser.new(style, 'middleman-css-input', 1).parse
      root_node.options = {}.merge!(options_hash).merge!(style: :compressed)
      root_node.render.strip
    end
  end

  def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
    super

    @ignore = Array(options.ignore) + [/\.min\./]
    @compressor = options.compressor
    @compressor = @compressor.to_proc if @compressor.respond_to? :to_proc
    @compressor = @compressor.call if @compressor.is_a? Proc
  end

  Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
  def manipulate_resource_list_container!(resource_list)
    resource_list.by_binary(false).each do |r|
      type = r.content_type.try(:slice, /^[^;]*/)
      if options[:inline] && minifiable_inline?(type)
        r.add_filter method(:minify_inline)
      elsif minifiable?(type) && !ignore?(r.destination_path)
        r.add_filter method(:minify)
      end
    end
  end

  # Whether the path should be ignored
  Contract String => Bool
  def ignore?(path)
    @ignore.any? { |ignore| ::Middleman::Util.path_match(ignore, path) }
  end
  memoize :ignore?

  # Whether this type of content can be minified
  Contract Maybe[String] => Bool
  def minifiable?(content_type)
    options[:content_types].include?(content_type)
  end
  memoize :minifiable?

  # Whether this type of content contains inline content that can be minified
  Contract Maybe[String] => Bool
  def minifiable_inline?(content_type)
    options[:inline_content_types].include?(content_type)
  end
  memoize :minifiable_inline?

  # Minify the content
  Contract String => String
  def minify(content)
    @compressor.compress(content)
  end
  memoize :minify

  # Detect and minify inline content
  # @param [String] content
  # @return [String]
  def minify_inline(content)
    content.gsub(INLINE_CSS_REGEX) do
      Regexp.last_match(1) + minify(Regexp.last_match(2)) + Regexp.last_match(3)
    end
  end
  memoize :minify_inline
end
