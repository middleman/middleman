require 'rack/mime'
require 'set'
require 'hamster'
require 'middleman-core/sitemap/extensions/traversal'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'
require 'middleman-core/contracts'
require 'middleman-core/inline_url_filter'
require 'middleman-core/dependencies/vertices/vertex'

module Middleman
  # Sitemap namespace
  module Sitemap
    # Sitemap Resource class
    class Resource
      include Contracts
      include Comparable
      include Middleman::Sitemap::Extensions::Traversal

      attr_reader :app

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

      Contract Num
      attr_reader :priority

      Contract ImmutableSetOf[::Middleman::Dependencies::Vertex]
      attr_reader :vertices

      # Initialize resource with parent store and URL
      # @param [Middleman::Sitemap::Store] store
      # @param [String] path
      # @param [String] source
      Contract IsA['Middleman::Sitemap::Store'], String, Maybe[Or[IsA['Middleman::SourceFile'], String]], Maybe[Num] => Any
      def initialize(store, path, source = nil, priority = 1)
        @store    = store
        @app      = @store.app
        @path     = path
        @ignored  = false
        @filters  = ::Hamster::SortedSet.empty
        @priority = priority
        @vertices = ::Hamster::Set.empty

        source = Pathname(source) if source&.is_a?(String)

        @file_descriptor = if source&.is_a?(Pathname)
                             ::Middleman::SourceFile.new(source.relative_path_from(@app.source_dir), source, @app.source_dir, Set.new([:source]), 0)
                           else
                             source
                           end

        @destination_path = @path

        # Options are generally rendering/sitemap options
        @metadata_options = ::Middleman::EMPTY_HASH

        # Locals are local variables for rendering this resource's template
        @metadata_locals  = ::Middleman::EMPTY_HASH

        # Page are data that is exposed through this resource's data member.
        # Note: It is named 'page' for backwards compatibility with older MM.
        @metadata_page    = ::Middleman::EMPTY_HASH

        # Recursively enhanced page data cache
        @page_data = nil
      end

      # Whether this resource has a template file
      # @return [Boolean]
      Contract Bool
      def template?
        return false if file_descriptor.nil?

        !::Middleman::Util.tilt_class(file_descriptor[:full_path].to_s).nil?
      end

      Contract Bool
      def static_file?
        ::Middleman::Util.static_file?(file_descriptor[:full_path].to_s, app.config[:frontmatter_delims])
      end

      # Backwards compatible method for turning descriptor into a string.
      # @return [String]
      Contract Maybe[String]
      def source_file
        file_descriptor && file_descriptor[:full_path].to_s
      end

      Contract Or[Symbol, String, Integer]
      def page_id
        @metadata_page[:id] || make_implicit_page_id(destination_path)
      end

      Contract Hash, Maybe[Bool] => Any
      def add_metadata_options(opts, reverse = false)
        if @metadata_options == ::Middleman::EMPTY_HASH
          @metadata_options = opts.dup
        elsif reverse
          @metadata_options = opts.deep_merge(@metadata_options)
        else
          @metadata_options.deep_merge!(opts)
        end
      end

      Contract Hash, Maybe[Bool] => Any
      def add_metadata_locals(locs, reverse = false)
        if @metadata_locals == ::Middleman::EMPTY_HASH
          @metadata_locals = locs.dup
        elsif reverse
          @metadata_locals = locs.deep_merge(@metadata_locals)
        else
          @metadata_locals.deep_merge!(locs)
        end
      end

      Contract Hash, Maybe[Bool] => Any
      def add_metadata_page(page, reverse = false)
        # Clear recursively enhanced cache
        @page_data = nil

        if @metadata_page == ::Middleman::EMPTY_HASH
          @metadata_page = page.dup
        elsif reverse
          @metadata_page = page.deep_merge(@metadata_page)
        else
          @metadata_page.deep_merge!(page)
        end
      end

      # Backwards compat to old API from MM v4.
      MAYBE_METADATA_CONTRACT = { page: Maybe[Hash], options: Maybe[Hash], locals: Maybe[Hash] }.freeze
      Contract MAYBE_METADATA_CONTRACT, Maybe[Bool] => Any
      def add_metadata(data, reverse = false)
        add_metadata_page(data[:page], reverse) if data.key? :page
        add_metadata_options(data[:options], reverse) if data.key? :options
        add_metadata_locals(data[:locals], reverse) if data.key? :locals
      end

      # Data about this resource, populated from frontmatter or extensions.
      # @return [Hash]
      Contract IsA['::Middleman::Util::EnhancedHash']
      def data
        @page_data ||= ::Middleman::Util.recursively_enhance(page)
      end

      Contract Hash
      def page
        @metadata_page
      end

      # Options about how this resource is rendered, such as its :layout,
      # :renderer_options, and whether or not to use :directory_indexes.
      # @return [Hash]
      Contract Hash
      def options
        @metadata_options
      end

      # Local variable mappings that are used when rendering the template for this resource.
      # @return [Hash]
      Contract Hash
      def locals
        @metadata_locals
      end

      # Backwards compat to old API from MM v4.
      METADATA_CONTRACT = { page: Hash, options: Hash, locals: Hash }.freeze
      Contract METADATA_CONTRACT
      def metadata
        {
          page: page,
          options: options,
          locals: locals
        }.freeze
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
      def render(options_hash = ::Middleman::EMPTY_HASH, locs = ::Middleman::EMPTY_HASH, &_block)
        @vertices = ::Hamster::Set.empty

        body = render_without_filters(options_hash, locs)

        return body if @filters.empty?

        @filters.reduce(body) do |output, filter|
          if block_given? && !yield(filter)
            output
          elsif filter.is_a?(Filter)
            result = filter.execute_filter(output)
            @vertices |= result[1]
            result[0]
          else
            output
          end
        end
      end

      # Render this resource without content filters
      # @return [String]
      Contract Hash, Hash => String
      def render_without_filters(options_hash = ::Middleman::EMPTY_HASH, locals_hash = ::Middleman::EMPTY_HASH)
        return ::Middleman::FileRenderer.new(@app, file_descriptor[:full_path].to_s).template_data_for_file unless template?

        opts = if options_hash == ::Middleman::EMPTY_HASH
                 options.dup
               else
                 options.deep_merge(options_hash)
               end

        # Certain output file types don't use layouts
        opts[:layout] = false if !opts.key?(:layout) && !@app.set_of_extensions_with_layout.include?(ext)

        locs = if locals_hash == ::Middleman::EMPTY_HASH
                 locals.dup
               else
                 locals.deep_merge(locals_hash)
               end

        locs[:current_path] ||= destination_path

        renderer = ::Middleman::TemplateRenderer.new(@app, file_descriptor[:full_path].to_s)
        renderer.render(locs, opts).to_str.tap do
          @vertices |= renderer.vertices
        end
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

      FILTER = Or[RespondTo[:call], Filter]
      Contract FILTER => Any
      def add_filter(filter)
        filter = ProcFilter.new(:"proc_#{filter.object_id}", filter) if filter.respond_to?(:call)

        @filters = @filters.add filter
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

      # The `object_id` inclusion is because Hamster::SortedSet will assume
      # <=> of 0 (same priority) actually means equality and removes duplicates
      # from the set. Bug filed here: https://github.com/hamstergem/hamster/issues/246
      Contract RespondTo[:priority] => Num
      def <=>(other)
        [priority, object_id] <=> [other.priority, other.object_id]
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
