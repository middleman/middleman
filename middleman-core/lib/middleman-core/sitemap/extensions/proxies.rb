require 'middleman-core/sitemap/resource'
require 'middleman-core/core_extensions/collections/step_context'

module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class Proxies < Extension
        self.resource_list_manipulator_priority = 0

        # Expose `create_proxy` as `app.proxy`
        expose_to_application proxy: :create_proxy

        # Expose `create_proxy` to config as `proxy`
        expose_to_config proxy: :create_proxy

        def initialize(app, config={}, &block)
          super

          @proxy_configs = Set.new
          @post_config = false
        end

        def after_configuration
          @post_config = true

          ::Middleman::CoreExtensions::Collections::StepContext.add_to_context(:proxy, &method(:create_anonymous_proxy))
        end

        # Setup a proxy from a path to a target
        # @param [String] path The new, proxied path to create
        # @param [String] target The existing path that should be proxied to. This must be a real resource, not another proxy.
        # @option opts [Boolean] ignore Ignore the target from the sitemap (so only the new, proxy resource ends up in the output)
        # @option opts [Symbol, Boolean, String] layout The layout name to use (e.g. `:article`) or `false` to disable layout.
        # @option opts [Boolean] directory_indexes Whether or not the `:directory_indexes` extension applies to these paths.
        # @option opts [Hash] locals Local variables for the template. These will be available when the template renders.
        # @option opts [Hash] data Extra metadata to add to the page. This is the same as frontmatter, though frontmatter will take precedence over metadata defined here. Available via {Resource#data}.
        # @return [void]
        Contract String, String, Maybe[Hash] => Any
        def create_proxy(path, target, opts={})
          options = opts.dup
          @app.ignore(target) if options.delete(:ignore)

          @proxy_configs << create_anonymous_proxy(path, target, options)
          @app.sitemap.rebuild_resource_list!(:added_proxy)
        end

        # Setup a proxy from a path to a target
        # @param [String] path The new, proxied path to create
        # @param [String] target The existing path that should be proxied to. This must be a real resource, not another proxy.
        # @option opts [Boolean] ignore Ignore the target from the sitemap (so only the new, proxy resource ends up in the output)
        # @option opts [Symbol, Boolean, String] layout The layout name to use (e.g. `:article`) or `false` to disable layout.
        # @option opts [Boolean] directory_indexes Whether or not the `:directory_indexes` extension applies to these paths.
        # @option opts [Hash] locals Local variables for the template. These will be available when the template renders.
        # @option opts [Hash] data Extra metadata to add to the page. This is the same as frontmatter, though frontmatter will take precedence over metadata defined here. Available via {Resource#data}.
        # @return [void]
        def create_anonymous_proxy(path, target, options={})
          ProxyDescriptor.new(
            ::Middleman::Util.normalize_path(path),
            ::Middleman::Util.normalize_path(target),
            options
          )
        end

        # Update the main sitemap resource list
        # @return Array<Middleman::Sitemap::Resource>
        Contract ResourceList => ResourceList
        def manipulate_resource_list(resources)
          resources + @proxy_configs.map { |c| c.to_resource(@app) }
        end
      end

      ProxyDescriptor = Struct.new(:path, :target, :metadata) do
        def to_resource(app)
          ProxyResource.new(app.sitemap, path, target).tap do |p|
            md = metadata.dup
            p.add_metadata(
              locals: md.delete(:locals) || {},
              page: md.delete(:data) || {},
              options: md
            )
          end
        end
      end
    end

    class Resource
      def proxy_to(_path)
        throw 'Resource#proxy_to has been removed. Use ProxyResource class instead.'
      end
    end

    class ProxyResource < ::Middleman::Sitemap::Resource
      Contract String
      attr_reader :target

      # Initialize resource with parent store and URL
      # @param [Middleman::Sitemap::Store] store
      # @param [String] path
      # @param [String] target
      def initialize(store, path, target)
        super(store, path)

        target = ::Middleman::Util.normalize_path(target)
        raise "You can't proxy #{path} to itself!" if target == path
        @target = target
      end

      # The resource for the page this page is proxied to. Throws an exception
      # if there is no resource.
      # @return [Sitemap::Resource]
      Contract IsA['Middleman::Sitemap::Resource']
      def target_resource
        resource = @store.find_resource_by_path(@target)

        unless resource
          raise "Path #{path} proxies to unknown file #{@target}:#{@store.resources.map(&:path)}"
        end

        if resource.is_a? ProxyResource
          raise "You can't proxy #{path} to #{@target} which is itself a proxy."
        end

        resource
      end

      Contract IsA['Middleman::SourceFile']
      def file_descriptor
        target_resource.file_descriptor
      end

      def metadata
        target_resource.metadata.deep_merge super
      end

      Contract Maybe[String]
      def content_type
        mime_type = super
        return mime_type if mime_type

        target_resource.content_type
      end

      def to_s
        "#<#{self.class} path=#{@path} target=#{@target}>"
      end
      alias_method :inspect, :to_s
    end
  end
end
