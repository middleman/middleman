require 'middleman-core/sitemap/resource'

module Middleman
  module Sitemap
    module Extensions
      class RequestEndpoints < Extension
        self.resource_list_manipulator_priority = 0

        # Expose `create_endpoint` to config as `endpoint`
        expose_to_config endpoint: :create_endpoint

        # Manages the list of proxy configurations and manipulates the sitemap
        # to include new resources based on those configurations
        def initialize(app, config={}, &block)
          super

          @endpoints = {}
        end

        # Setup a proxy from a path to a target
        # @param [String] path
        # @param [Hash] opts The :path value gives a request path if it
        # differs from the output path
        Contract String, Or[({ path: String }), Proc] => Any
        def create_endpoint(path, opts={}, &block)
          endpoint = {
            request_path: path
          }

          if block_given?
            endpoint[:output] = block
          else
            endpoint[:request_path] = opts[:path] if opts.key?(:path)
          end

          @endpoints[path] = endpoint

          @app.sitemap.rebuild_resource_list!(:added_endpoint)
        end

        # Update the main sitemap resource list
        # @return Array<Middleman::Sitemap::Resource>
        Contract ResourceList => ResourceList
        def manipulate_resource_list(resources)
          resources + @endpoints.map do |path, config|
            r = EndpointResource.new(
              @app.sitemap,
              path,
              config[:request_path]
            )
            r.output = config[:output] if config.key?(:output)
            r
          end
        end
      end

      class EndpointResource < ::Middleman::Sitemap::Resource
        Contract Maybe[Proc]
        attr_accessor :output

        def initialize(store, path, request_path)
          super(store, path)
          @request_path = ::Middleman::Util.normalize_path(request_path)
        end

        Contract String
        attr_reader :request_path

        Contract Bool
        def template?
          true
        end

        Contract Args[Any] => String
        def render(*)
          return output.call if output
        end

        Contract Bool
        def ignored?
          false
        end
      end
    end
  end
end
