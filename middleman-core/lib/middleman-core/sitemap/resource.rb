require 'middleman-core/sitemap/extensions/traversal'
require 'middleman-core/sitemap/extensions/content_type'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

module Middleman
  # Sitemap namespace
  module Sitemap
    # Sitemap Resource class
    class Resource
      include Middleman::Sitemap::Extensions::Traversal
      include Middleman::Sitemap::Extensions::ContentType

      # The source path of this resource (relative to the source directory,
      # without template extensions)
      # @return [String]
      attr_reader :path

      # The output path in the build directory for this resource
      # @return [String]
      attr_accessor :destination_path

      # Set the on-disk source file for this resource
      # @return [String]
      def source_file
        # TODO: Make this work when get_source_file doesn't exist
        @source_file || get_source_file
      end

      # Initialize resource with parent store and URL
      # @param [Middleman::Sitemap::Store] store
      # @param [String] path
      # @param [String] source_file
      def initialize(store, path, source_file=nil)
        @store       = store
        @app         = @store.app
        @path        = path.gsub(' ', '%20') # handle spaces in filenames
        @source_file = source_file
        @destination_path = @path

        # Options are generally rendering/sitemap options
        # Locals are local variables for rendering this resource's template
        # Page are data that is exposed through this resource's data member.
        # Note: It is named 'page' for backwards compatibility with older MM.
        @local_metadata = { options: {}, locals: {}, page: {} }
      end

      # Whether this resource has a template file
      # @return [Boolean]
      def template?
        return false if source_file.nil?
        !::Tilt[source_file].nil?
      end

      # Get the metadata for both the current source_file and the current path
      # @return [Hash]
      def metadata
        # TODO: The only reason we call metadata_for_page is to power the "page" DSL
        @store.metadata_for_path(path).deep_merge @local_metadata
      end

      # Data about this resource, populated from frontmatter or extensions.
      # @return [HashWithIndifferentAccess]
      def data
        # TODO: Upconvert/freeze at this point?
        metadata[:page]
      end

      # Merge in new metadata specific to this resource.
      # @param [Hash] meta A metadata block with keys :options, :locals, :page.
      #   Options are generally rendering/sitemap options
      #   Locals are local variables for rendering this resource's template
      #   Page are data that is exposed through this resource's data member.
      #   Note: It is named 'page' for backwards compatibility with older MM.
      def add_metadata(meta={})
        @local_metadata.deep_merge!(meta)
      end

      # Extension of the path (i.e. '.js')
      # @return [String]
      def ext
        File.extname(path)
      end

      # Render this resource
      # @return [String]
      def render(opts={}, locs={})
        return ::Middleman::FileRenderer.new(@app, source_file).template_data_for_file unless template?

        relative_source = Pathname(source_file).relative_path_from(Pathname(@app.root))

        @app.instrument 'render.resource', path: relative_source, destination_path: destination_path do
          md   = metadata
          opts = md[:options].deep_merge(opts)
          locs = md[:locals].deep_merge(locs)
          locs[:current_path] ||= destination_path

          # Certain output file types don't use layouts
          unless opts.key?(:layout)
            opts[:layout] = false if %w(.js .json .css .txt).include?(ext)
          end

          renderer = ::Middleman::TemplateRenderer.new(@app, source_file)
          renderer.render(locs, opts)
        end
      end

      # A path without the directory index - so foo/index.html becomes
      # just foo. Best for linking.
      # @return [String]
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
      def binary?
        ::Middleman::Util.binary?(source_file)
      end
    end
  end
end
