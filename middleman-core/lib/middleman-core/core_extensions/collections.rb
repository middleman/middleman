require 'middleman-core/core_extensions/collections/pagination'
require 'middleman-core/core_extensions/collections/step_context'
require 'middleman-core/core_extensions/collections/lazy_root'
require 'middleman-core/core_extensions/collections/lazy_step'

# Super "class-y" injection of array helpers
class Array
  include Middleman::Pagination::ArrayHelpers
end

module Middleman
  module CoreExtensions
    module Collections
      class CollectionsExtension < Extension
        # This should run after most other sitemap manipulators so that it
        # gets a chance to modify any new resources that get added.
        self.resource_list_manipulator_priority = 110

        attr_accessor :sitemap_collector, :data_collector, :leaves

        def initialize(app, options_hash={}, &block)
          super

          @leaves = Set.new
          @collectors_by_name = {}
          @values_by_name = {}

          @sitemap_collector = LazyCollectorRoot.new(self)
          @data_collector = LazyCollectorRoot.new(self)
        end

        Contract Any
        def before_configuration
          @leaves.clear

          app.add_to_config_context :resources, &method(:sitemap_collector)
          app.add_to_config_context :data, &method(:data_collector)
          app.add_to_config_context :collection, &method(:register_collector)
        end

        Contract Symbol, LazyCollectorStep => Any
        def register_collector(label, endpoint)
          @collectors_by_name[label] = endpoint
        end

        Contract Symbol => Any
        def collector_value(label)
          @values_by_name[label]
        end

        Contract ResourceList => ResourceList
        def manipulate_resource_list(resources)
          @sitemap_collector.realize!(resources)
          @data_collector.realize!(app.data)

          ctx = StepContext.new
          leaves = @leaves.dup

          @collectors_by_name.each do |k, v|
            @values_by_name[k] = v.value(ctx)
            leaves.delete v
          end

          # Execute code paths
          leaves.each do |v|
            v.value(ctx)
          end

          # Inject descriptors
          resources + ctx.descriptors.map { |d| d.to_resource(app) }
        end

        helpers do
          def collection(label)
            extensions[:collections].collector_value(label)
          end

          def pagination
            current_resource.data.pagination
          end
        end
      end
    end
  end
end
