module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class Proxies
        def initialize(sitemap)
          @app = sitemap.app
          @app.add_to_config_context :proxy, &method(:create_proxy)
          @app.define_singleton_method(:proxy, &method(:create_proxy))

          @proxy_configs = Set.new
        end

        # Setup a proxy from a path to a target
        # @param [String] path
        # @param [String] target
        # @param [Hash] opts options to apply to the proxy, including things like
        #               :locals, :ignore to hide the proxy target, :layout, and :directory_indexes.
        # @return [void]
        def create_proxy(path, target, opts={})
          options = opts.dup

          metadata = { options: {}, locals: {} }
          metadata[:locals] = options.delete(:locals) || {}

          @app.ignore(target) if options.delete(:ignore)
          metadata[:options] = options

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
    end
  end
end
