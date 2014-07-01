module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class Proxies
        def initialize(app)
          @app = app
          @app.add_to_config_context :proxy, &method(:create_proxy)
          @app.define_singleton_method(:proxy, &method(:create_proxy))

          @proxy_configs = Set.new

          ::Middleman::Sitemap::Resource.send :include, ProxyResourceInstanceMethods
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
        def create_proxy(path, target, opts={})
          options = opts.dup

          @app.ignore(target) if options.delete(:ignore)

          metadata = {
            options: options,
            locals: options.delete(:locals) || {},
            page: options.delete(:data) || {}
          }

          @proxy_configs << ProxyConfiguration.new(path: path, target: target, metadata: metadata)

          @app.sitemap.rebuild_resource_list!(:added_proxy)
        end

        # Update the main sitemap resource list
        # @return [void]
        def manipulate_resource_list(resources)
          resources + @proxy_configs.map do |config|
            p = ::Middleman::Sitemap::Resource.new(
              @app.sitemap,
              config.path
            )
            p.proxy_to(config.target)

            p.add_metadata(config.metadata)
            p
          end
        end
      end

      # Configuration for a proxy instance
      class ProxyConfiguration
        # The path that this proxy will appear at in the sitemap
        attr_reader :path
        def path=(p)
          @path = ::Middleman::Util.normalize_path(p)
        end

        # The existing sitemap path that this will proxy to
        attr_reader :target
        def target=(t)
          @target = ::Middleman::Util.normalize_path(t)
        end

        # Additional metadata like locals to apply to the proxy
        attr_accessor :metadata

        # Create a new proxy configuration from hash options
        def initialize(options={})
          options.each do |key, value|
            send "#{key}=", value
          end
        end

        # Two configurations are equal if they reference the same path
        def eql?(other)
          other.path == path
        end

        # Two configurations are equal if they reference the same path
        def hash
          path.hash
        end
      end

      module ProxyResourceInstanceMethods
        # Whether this page is a proxy
        # @return [Boolean]
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
          proxy_resource = @store.find_resource_by_path(proxied_to)

          unless proxy_resource
            raise "Path #{path} proxies to unknown file #{proxied_to}:#{@store.resources.map(&:path)}"
          end

          if proxy_resource.proxy?
            raise "You can't proxy #{path} to #{proxied_to} which is itself a proxy."
          end

          proxy_resource
        end

        # rubocop:disable AccessorMethodName
        def get_source_file
          if proxy?
            proxied_to_resource.source_file
          else
            super
          end
        end

        def content_type
          mime_type = super
          return mime_type if mime_type

          if proxy?
            proxied_to_resource.content_type
          else
            nil
          end
        end
      end
    end
  end
end
