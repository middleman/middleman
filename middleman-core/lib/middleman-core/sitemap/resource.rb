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

      # @return [Middleman::Application]
      attr_reader :app
      delegate :logger, :instrument, :to => :app

      # @return [Middleman::Sitemap::Store]
      attr_reader :store

      # The source path of this resource (relative to the source directory,
      # without template extensions)
      # @return [String]
      attr_reader :path

      # The output path for this resource
      # @return [String]
      attr_accessor :destination_path

      # Set the on-disk source file for this resource
      # @return [String]
      # attr_reader :source_file

      def source_file
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

        @local_metadata = { :options => {}, :locals => {} }
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
        result = store.metadata_for_path(path).dup

        file_meta = store.metadata_for_file(source_file).dup
        result.deep_merge!(file_meta)

        local_meta = @local_metadata.dup
        result.deep_merge!(local_meta)

        result
      end

      # Merge in new metadata specific to this resource.
      # @param [Hash] meta A metadata block like provides_metadata_for_path takes
      def add_metadata(meta={})
        @local_metadata.deep_merge!(meta.dup)
      end

      # The output/preview URL for this resource
      # @return [String]
      attr_accessor :destination_path

      # Extension of the path (i.e. '.js')
      # @return [String]
      def ext
        File.extname(path)
      end

      def request_path
        self.destination_path
      end

      # Render this resource
      # @return [String]
      def render(opts={}, locs={})
        if !template?
          return ::Middleman::FileRenderer.new(@app, source_file).get_template_data_for_file
        end

        relative_source = Pathname(source_file).relative_path_from(Pathname(app.root))

        instrument 'render.resource', :path => relative_source  do
          md   = metadata.dup
          opts = md[:options].deep_merge(opts)
          locs = md[:locals].deep_merge(locs)
          locs[:current_path] ||= self.destination_path

          # Certain output file types don't use layouts
          if !opts.has_key?(:layout)
            opts[:layout] = false if %w(.js .json .css .txt).include?(self.ext)
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
        if app.config[:strip_index_file]
          url_path = url_path.sub(/(^|\/)#{Regexp.escape(app.config[:index_file])}$/,
                                  app.config[:trailing_slash] ? '/' : '')
        end
        File.join(app.config[:http_prefix], url_path)
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
