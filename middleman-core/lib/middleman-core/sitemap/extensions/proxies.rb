module Middleman
  module Sitemap
    module Extensions
      module Proxies
        # Setup extension
        class << self
          # Once registered
          def registered(app)
            ::Middleman::Sitemap::Resource.send :include, ResourceInstanceMethods

            # Include methods
            app.send :include, InstanceMethods
          end

          alias_method :included, :registered
        end

        module ResourceInstanceMethods
          # Whether this page is a proxy
          # rubocop:disable TrivialAccessors
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
            proxy_resource = store.find_resource_by_path(proxied_to)

            unless proxy_resource
              raise "Path #{path} proxies to unknown file #{proxied_to}:#{store.resources.map(&:path)}"
            end

            if proxy_resource.proxy?
              raise "You can't proxy #{path} to #{proxied_to} which is itself a proxy."
            end

            proxy_resource
          end

          # rubocop:disable Style/AccessorMethodName
          def get_source_file
            if proxy?
              proxied_to_resource.source_file
            else
              super
            end
          end
          # rubocop:enable Style/AccessorMethodName

          def content_type
            mime_type = super
            return mime_type if mime_type

            return proxied_to_resource.content_type if proxy?

            nil
          end
        end

        module InstanceMethods
          def proxy_manager
            @_proxy_manager ||= ProxyManager.new(self)
          end

          def proxy(*args, &block)
            proxy_manager.proxy(*args, &block)
          end
        end

        # Manages the list of proxy configurations and manipulates the sitemap
        # to include new resources based on those configurations
        class ProxyManager
          def initialize(app)
            @app = app
            @proxy_configs = Set.new
          end

          # Setup a proxy from a path to a target
          # @param [String] path
          # @param [String] target
          # @param [Hash] opts options to apply to the proxy, including things like
          #               :locals, :ignore to hide the proxy target, :layout, and :directory_indexes.
          # @return [void]
          def proxy(path, target, opts={}, &block)
            metadata = { options: {}, locals: {}, blocks: [] }
            metadata[:blocks] << block if block_given?
            metadata[:locals] = opts.delete(:locals) || {}

            @app.ignore(target) if opts.delete(:ignore)
            metadata[:options] = opts

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

          # Additional metadata like blocks and locals to apply to the proxy
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
end
