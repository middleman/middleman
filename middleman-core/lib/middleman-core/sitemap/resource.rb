require 'rack/mime'
require 'middleman-core/sitemap/extensions/traversal'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'
require 'middleman-core/contracts'
require 'set'
require 'middleman-core/inline_url_rewriter'

module Middleman
  # Sitemap namespace
  module Sitemap
    # Sitemap Resource class
    class Resource
      include Contracts
      include Middleman::Sitemap::Extensions::Traversal

      # The source path of this resource (relative to the source directory,
      # without template extensions)
      # @return [String]
      attr_reader :path

      # The output path in the build directory for this resource
      # @return [String]
      attr_accessor :destination_path

      # The on-disk source file for this resource, if there is one
      # @return [String]
      Contract Maybe[IsA['Middleman::SourceFile']]
      attr_reader :file_descriptor

      # The path to use when requesting this resource. Normally it's
      # the same as {#destination_path} but it can be overridden in subclasses.
      # @return [String]
      alias request_path destination_path

      METADATA_HASH = { options: Maybe[Hash], locals: Maybe[Hash], page: Maybe[Hash] }.freeze

      # The metadata for this resource
      # @return [Hash]
      Contract METADATA_HASH
      attr_reader :metadata

      attr_accessor :ignored
      attr_accessor :filters

      # Initialize resource with parent store and URL
      # @param [Middleman::Sitemap::Store] store
      # @param [String] path
      # @param [String] source
      Contract IsA['Middleman::Sitemap::Store'], String, Maybe[Or[IsA['Middleman::SourceFile'], String]] => Any
      def initialize(store, path, source = nil)
        @store       = store
        @app         = @store.app
        @path        = path
        @ignored     = false
        @filters     = []

        source = Pathname(source) if source&.is_a?(String)

        @file_descriptor = if source&.is_a?(Pathname)
                             ::Middleman::SourceFile.new(source.relative_path_from(@app.source_dir), source, @app.source_dir, Set.new([:source]), 0)
                           else
                             source
                           end

        @destination_path = @path

        @set_of_extensions_with_layout = Set.new @app.config.extensions_with_layout

        # Options are generally rendering/sitemap options
        # Locals are local variables for rendering this resource's template
        # Page are data that is exposed through this resource's data member.
        # Note: It is named 'page' for backwards compatibility with older MM.
        @metadata = { options: {}, locals: {}, page: {} }

        @page_data = nil
      end

      # Whether this resource has a template file
      # @return [Boolean]
      Contract Bool
      def template?
        return false if file_descriptor.nil?

        !::Middleman::Util.tilt_class(file_descriptor[:full_path].to_s).nil?
      end

      # Backwards compatible method for turning descriptor into a string.
      # @return [String]
      Contract Maybe[String]
      def source_file
        file_descriptor && file_descriptor[:full_path].to_s
      end

      Contract Or[Symbol, String, Integer]
      def page_id
        metadata[:page][:id] || make_implicit_page_id(destination_path)
      end

      # Merge in new metadata specific to this resource.
      # @param [Hash] meta A metadata block with keys :options, :locals, :page.
      #   Options are generally rendering/sitemap options
      #   Locals are local variables for rendering this resource's template
      #   Page are data that is exposed through this resource's data member.
      #   Note: It is named 'page' for backwards compatibility with older MM.
      Contract METADATA_HASH, Maybe[Bool] => METADATA_HASH
      def add_metadata(meta = {}, reverse = false)
        @page_data = nil

        @metadata = if reverse
                      meta.deep_merge(@metadata)
                    else
                      @metadata.deep_merge(meta)
                    end
      end

      # Data about this resource, populated from frontmatter or extensions.
      # @return [Hash]
      Contract RespondTo[:indifferent_access?]
      def data
        @page_data ||= ::Middleman::Util.recursively_enhance(metadata[:page])
      end

      # Options about how this resource is rendered, such as its :layout,
      # :renderer_options, and whether or not to use :directory_indexes.
      # @return [Hash]
      Contract Hash
      def options
        metadata[:options]
      end

      # Local variable mappings that are used when rendering the template for this resource.
      # @return [Hash]
      Contract Hash
      def locals
        metadata[:locals]
      end

      # Extension of the path (i.e. '.js')
      # @return [String]
      Contract String
      def ext
        File.extname(path)
      end

      # Render this resource
      # @return [String]
      Contract Hash, Hash, Maybe[Proc] => String
      def render(options_hash = {}, locs = {}, &_block)
        body = render_without_filters(options_hash, locs)

        return body if @filters.empty?

        sortable_filters = @filters.select { |f| f.respond_to?(:filter_name) }.sort do |a, b|
          if b.after_filter == a.filter_name
            1
          else
            -1
          end
        end.reverse

        n = 0
        sorted_filters = @filters.sort_by do |m|
          n += 1
          idx = sortable_filters.index(m)

          [idx.nil? ? 0 : idx, n]
        end

        sorted_filters.reduce(body) do |output, filter|
          if block_given? && !yield(filter)
            output
          elsif filter.respond_to?(:execute_filter)
            filter.execute_filter(output)
          elsif filter.respond_to?(:call)
            filter.call(output)
          else
            output
          end
        end
      end

      # Render this resource without content filters
      # @return [String]
      Contract Hash, Hash => String
      def render_without_filters(options_hash = {}, locs = {})
        return ::Middleman::FileRenderer.new(@app, file_descriptor[:full_path].to_s).template_data_for_file unless template?

        md = metadata
        options = md[:options].deep_merge(options_hash)
        locs = md[:locals].deep_merge(locs)
        locs[:current_path] ||= destination_path

        # Certain output file types don't use layouts
        options[:layout] = false if !options.key?(:layout) && !@set_of_extensions_with_layout.include?(ext)

        renderer = ::Middleman::TemplateRenderer.new(@app, file_descriptor[:full_path].to_s)
        renderer.render(locs, options).to_str
      end

      # A path without the directory index - so foo/index.html becomes
      # just foo. Best for linking.
      # @return [String]
      Contract String
      def url
        url_path = destination_path
        if @app.config[:strip_index_file]
          url_path = url_path.sub(/(^|\/)#{Regexp.escape(@app.config[:index_file])}$/,
                                  @app.config[:trailing_slash] ? '/' : '')
        end
        File.join(@app.config[:http_prefix], url_path)
      end

      # Whether the source file is binary.
      #
      # @return [Boolean]
      Contract Bool
      def binary?
        !file_descriptor.nil? && (file_descriptor[:types].include?(:binary) || ::Middleman::Util.binary?(file_descriptor[:full_path].to_s))
      end

      # Ignore a resource directly, without going through the whole
      # ignore filter stuff.
      # @return [void]
      Contract Any
      def ignore!
        @ignored = true
      end

      # Whether the Resource is ignored
      # @return [Boolean]
      Contract Bool
      def ignored?
        @ignored
      end

      # The preferred MIME content type for this resource based on extension or metadata
      # @return [String] MIME type for this resource
      Contract Maybe[String]
      def content_type
        options[:content_type] || ::Rack::Mime.mime_type(ext, nil)
      end

      # The normalized source path of this resource (relative to the source directory,
      # without template extensions)
      # @return [String]
      def normalized_path
        @normalized_path ||= ::Middleman::Util.normalize_path @path
      end

      def to_s
        "#<#{self.class} path=#{@path}>"
      end
      alias inspect to_s # Ruby 2.0 calls inspect for NoMethodError instead of to_s

      protected

      # Makes a page id based on path (when not otherwise given)
      #
      # Removes .html extension and potential leading slashes or dots
      # eg. "foo/bar/baz.foo.html" => "foo/bar/baz.foo"
      Contract String => String
      def make_implicit_page_id(path)
        @id ||= begin
          prok = @app.config[:page_id_generator]

          return prok.call(path) if prok

          basename = if ext == '.html'
                       File.basename(path, ext)
                     else
                       File.basename(path)
                     end

          # Remove leading dot or slash if present
          File.join(File.dirname(path), basename).gsub(/^\.?\//, '')
        end
      end
    end

    class StringResource < Resource
      Contract IsA['Middleman::Sitemap::Store'], String, Maybe[Or[String, Proc]] => Any
      def initialize(store, path, contents)
        @request_path = path
        @contents = contents
        super(store, path)
      end

      def template?
        true
      end

      def render(*)
        @contents
      end

      def binary?
        false
      end
    end
  end
end
