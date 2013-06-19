module Middleman

  module Sitemap

    module Extensions

      module RequestEndpoints

        # Setup extension
        class << self

          # Once registered
          def registered(app)
            # Include methods
            app.send :include, InstanceMethods
          end

          alias :included :registered
        end

        module InstanceMethods
          def endpoint_manager
            @_endpoint_manager ||= EndpointManager.new(self)
          end

          def endpoint(*args, &block)
            endpoint_manager.create_endpoint(*args, &block)
          end
        end

        # Manages the list of proxy configurations and manipulates the sitemap
        # to include new resources based on those configurations
        class EndpointManager
          def initialize(app)
            @app = app
            @endpoints = {}
          end

          # Setup a proxy from a path to a target
          # @param [String] path
          # @param [Hash] The :path value gives a request path if it
          # differs from the output path
          # @return [void]
          def create_endpoint(path, opts={}, &block)
            endpoint = {
              :request_path => path
            }

            if block_given?
              endpoint[:output] = block
            else
              endpoint[:request_path] = opts[:path] if opts.has_key?(:path)
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
              r.output = config[:output] if config.has_key?(:output)
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
      
          def render(*args, &block)
            return self.output.call if self.output
          end

          def request_path
            @request_path
          end

          def binary?
            false
          end

          def raw_data
            {}
          end

          def ignored?
            false
          end

          def metadata
            @local_metadata.dup
          end

        end
      end
    end
  end
end
