require "middleman-core/sitemap/extensions/traversal"

module Middleman

  # Sitemap namespace
  module Sitemap

    # Sitemap Resource class
    class Resource
      include Middleman::Sitemap::Extensions::Traversal

      # @return [Middleman::Application]
      attr_reader :app
      delegate :logger, :instrument, :to => :app

      # @return [Middleman::Sitemap::Store]
      attr_reader :store

      # The source path of this resource (relative to the source directory,
      # without template extensions)
      # @return [String]
      attr_reader :path

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
        @path        = path
        @source_file = source_file

        @destination_paths = [@path]

        @local_metadata = { :options => {}, :locals => {}, :page => {}, :blocks => [] }
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
        if file_meta.has_key?(:blocks)
          result[:blocks] << file_meta.delete(:blocks)
        end
        result.deep_merge!(file_meta)

        local_meta = @local_metadata.dup
        if local_meta.has_key?(:blocks)
          result[:blocks] << local_meta.delete(:blocks)
        end
        result.deep_merge!(local_meta)

        result[:blocks] = result[:blocks].flatten.compact

        result
      end

      # Merge in new metadata specific to this resource.
      # @param [Hash] metadata A metadata block like provides_metadata_for_path takes
      def add_metadata(metadata={}, &block)
        if metadata.has_key?(:blocks)
          @local_metadata[:blocks] << metadata.delete(:blocks)
        end
        @local_metadata.deep_merge!(metadata)
        @local_metadata[:blocks] << block if block_given?
      end

      # Get the output/preview URL for this resource
      # @return [String]
      def destination_path
        @destination_paths.last
      end

      # Set the output/preview URL for this resource
      # @param [String] path
      # @return [void]
      def destination_path=(path)
        @destination_paths << path
      end

      # Extension of the path (i.e. '.js')
      # @return [String]
      def ext
        File.extname(path)
      end

      # Mime type of the path
      # @return [String]
      def mime_type
        app.mime_type ext
      end

      # Render this resource
      # @return [String]
      def render(opts={}, locs={}, &block)
        if !template?
          return app.template_data_for_file(source_file)
        end

        relative_source = Pathname(source_file).relative_path_from(Pathname(app.root))

        instrument "render.resource", :path => relative_source  do
          md   = metadata.dup
          opts = md[:options].deep_merge(opts)
          locs = md[:locals].deep_merge(locs)

          # Forward remaining data to helpers
          if md.has_key?(:page)
            app.data.store("page", md[:page])
          end

          blocks = md[:blocks].dup rescue []
          blocks << block if block_given?

          app.current_path ||= self.destination_path
          app.render_template(source_file, locs, opts, blocks)
        end
      end

      # A path without the directory index - so foo/index.html becomes
      # just foo. Best for linking.
      # @return [String]
      def url
        url_path = destination_path
        if app.strip_index_file
          url_path = url_path.sub(/(^|\/)#{Regexp.escape(app.index_file)}$/,
                                  app.trailing_slash ? '/' : '')
        end
        File.join(app.respond_to?(:http_prefix) ? app.http_prefix : '/', url_path)
      end

      # Whether the source file is binary.
      #
      # @retrun [Boolean]
      def binary?
        ::Middleman::Util.binary?(source_file)
      end
    end
  end
end
