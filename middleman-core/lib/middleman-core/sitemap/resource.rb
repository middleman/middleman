require 'middleman-core/sitemap/extensions/traversal'
require 'middleman-core/sitemap/extensions/content_type'

module Middleman
  # Sitemap namespace
  module Sitemap
    # Sitemap Resource class
    class Resource
      include Middleman::Sitemap::Extensions::Traversal
      include Middleman::Sitemap::Extensions::ContentType

      # @return [Middleman::Application]
      attr_reader :app
      delegate :logger, :instrument, to: :app

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
        @path        = path
        @source_file = source_file
        @destination_path = @path

        @local_metadata = { options: {}, locals: {}, page: {}, blocks: [] }
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
        result[:blocks] += file_meta.delete(:blocks) if file_meta.key?(:blocks)
        result.deep_merge!(file_meta)

        local_meta = @local_metadata.dup
        result[:blocks] += local_meta.delete(:blocks) if local_meta.key?(:blocks)
        result.deep_merge!(local_meta)

        result[:blocks] = result[:blocks].flatten.compact
        result
      end

      # Merge in new metadata specific to this resource.
      # @param [Hash] metadata A metadata block like provides_metadata_for_path takes
      def add_metadata(metadata={}, &block)
        metadata = metadata.dup
        @local_metadata[:blocks] += metadata.delete(:blocks) if metadata.key?(:blocks)
        @local_metadata.deep_merge!(metadata)
        @local_metadata[:blocks] += [block] if block_given?
      end

      # Extension of the path (i.e. '.js')
      # @return [String]
      def ext
        File.extname(path)
      end

      def request_path
        destination_path
      end

      # Render this resource
      # @return [String]
      def render(opts={}, locs={}, &block)
        return app.template_data_for_file(source_file) unless template?

        relative_source = Pathname(source_file).relative_path_from(Pathname(app.root))

        instrument 'render.resource', path: relative_source, destination_path: destination_path  do
          md   = metadata.dup
          opts = md[:options].deep_merge(opts)

          # Pass "renderer_options" hash from frontmatter along to renderer
          if md[:page]['renderer_options']
            opts[:renderer_options] = {}
            md[:page]['renderer_options'].each do |k, v|
              opts[:renderer_options][k.to_sym] = v
            end
          end

          locs = md[:locals].deep_merge(locs)

          # Forward remaining data to helpers
          app.data.store('page', md[:page]) if md.key?(:page)

          blocks = Array(md[:blocks]).dup
          blocks << block if block_given?

          app.current_path ||= destination_path

          # Certain output file types don't use layouts
          unless opts.key?(:layout)
            opts[:layout] = false if %w(.js .json .css .txt).include?(ext)
          end

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
      # @return [Boolean]
      def binary?
        ::Middleman::Util.binary?(source_file)
      end
    end
  end
end
