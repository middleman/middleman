module Middleman
  module Sitemap
    module Extensions
      class RequestEndpoints
        # Manages the list of proxy configurations and manipulates the sitemap
        # to include new resources based on those configurations
        def initialize(sitemap)
          @app = sitemap.app
          @app.add_to_config_context :endpoint, &method(:create_endpoint)

          @endpoints = {}
        end

        # Setup a proxy from a path to a target
        # @param [String] path
        # @param [Hash] opts The :path value gives a request path if it
        # differs from the output path
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
        # @return [void]
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
        attr_accessor :output

        def initialize(store, path, source_file)
          @request_path = ::Middleman::Util.normalize_path(source_file)

          super(store, path)
        end

        def template?
          true
        end

        def render(*)
          return output.call if output
        end

        attr_reader :request_path

        def ignored?
          false
        end
      end
    end
  end
end
