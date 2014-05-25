require 'rack'
require 'middleman-core/sitemap/extensions/traversal'
require 'middleman-core/sitemap/extensions/metadata'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

module Middleman
  # Sitemap namespace
  module Sitemap
    # Sitemap Resource class
    class Resource
      include Middleman::Sitemap::Extensions::Traversal

      # @return [Middleman::Application]
      attr_reader :app
      delegate :logger, :instrument, to: :app

      attr_reader :metadata
      delegate :data, :raw_data, to: :metadata

      # @return [Middleman::Sitemap::Store]
      attr_reader :store

      # The source path of this resource (relative to the source directory,
      # without template extensions)
      # @return [String]
      attr_reader :path

      # The output path for this resource
      # @return [String]
      attr_accessor :destination_path

      # Get the on-disk source file for this resource
      # @return [String]
      # rubocop:disable AccessorMethodName
      def source_file
        if @source_file
          @source_file
        elsif proxy?
          proxied_to_resource.source_file
        else
        end
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

        @metadata = Middleman::Sitemap::Extensions::Metadata.new(self)
      end

      # Whether this resource has a template file
      # @return [Boolean]
      def template?
        return false if source_file.nil?
        !::Tilt[source_file].nil?
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
        destination_path
      end

      # Whether the Resource is ignored
      # @return [Boolean]
      def ignored?
        if !proxy? && raw_data[:ignored] == true
          true
        else
          @app.sitemap.ignored?(path) ||
          (!proxy? &&
            @app.sitemap.ignored?(source_file.sub("#{@app.source_dir}/", ''))
          )
        end
      end

      def render_options
        metadata.fetch(:options)
      end

      def render_locals
        metadata.fetch(:locals)
      end

      def add_metadata(meta)
        metadata.add(meta)
      end

      # The preferred MIME content type for this resource
      # Look up mime type based on extension
      def content_type
        mime_type = raw_data[:content_type] || render_options[:content_type] || ::Rack::Mime.mime_type(ext, nil)

        return mime_type if mime_type

        if proxy?
          proxied_to_resource.content_type
        else
          nil
        end
      end

      # Whether this page is a proxy
      # @return [Boolean]
      # rubocop:disable TrivialAccessors
      def proxy?
        @proxied_to
      end

      # Set this page to proxy to a target path
      # @param [String] target
      # @return [void]
      def proxy_to(target)
        target = ::Middleman::Util.normalize_path(target)
        raise "You can't proxy #{path} to itself!" if target == path
        @proxied_to = target
      end

      # The path of the page this page is proxied to, or nil if it's not proxied.
      # @return [String]
      attr_reader :proxied_to

      # The resource for the page this page is proxied to. Throws an exception
      # if there is no resource.
      # @return [Sitemap::Resource]
      def proxied_to_resource
        proxy_resource = store.find_resource_by_path(proxied_to)

        unless proxy_resource
          raise "Path #{path} proxies to unknown file #{proxied_to}:#{store.resources.map(&:path)}"
        end

        if proxy_resource.proxy?
          raise "You can't proxy #{path} to #{proxied_to} which is itself a proxy."
        end

        proxy_resource
      end

      # Render this resource
      # @return [String]
      def render(opts={}, locs={})
        return ::Middleman::FileRenderer.new(@app, source_file).template_data_for_file unless template?

        relative_source = Pathname(source_file).relative_path_from(Pathname(app.root))

        instrument 'render.resource', path: relative_source, destination_path: destination_path do
          opts = render_options.deep_merge(opts)
          locs = render_locals.deep_merge(locs)
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
        source_file && ::Middleman::Util.binary?(source_file)
      end
    end
  end
end
