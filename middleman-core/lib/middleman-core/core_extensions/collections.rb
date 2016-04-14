require 'monitor'
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

        attr_accessor :leaves

        # Expose `resources`, `data`, and `collection` to config.
        expose_to_config resources: :sitemap_collector,
                         data: :data_collector,
                         collection: :register_collector,
                         live: :live_collector

        # Exposes `collection` to templates
        expose_to_template collection: :collector_value

        helpers do
          def pagination
            current_resource.data.pagination
          end
        end

        def initialize(app, options_hash={}, &block)
          super

          @leaves = Set.new
          @collectors_by_name = {}
          @values_by_name = {}

          @collector_roots = []

          @lock = Monitor.new
        end

        def before_configuration
          @leaves.clear
        end

        Contract Symbol, LazyCollectorStep => Any
        def register_collector(label, endpoint)
          @collectors_by_name[label] = endpoint
        end

        Contract LazyCollectorRoot
        def sitemap_collector
          live_collector { |_, resources| resources }
        end

        Contract LazyCollectorRoot
        def data_collector
          live_collector { |app, _| app.data }
        end

        Contract Proc => LazyCollectorRoot
        def live_collector(&block)
          root = LazyCollectorRoot.new(self)

          @collector_roots << {
            root: root,
            block: block
          }

          root
        end

        Contract Symbol => Any
        def collector_value(label)
          @values_by_name[label]
        end

        Contract ResourceList => ResourceList
        def manipulate_resource_list(resources)
          @lock.synchronize do
            @collector_roots.each do |pair|
              dataset = pair[:block].call(app, resources)
              pair[:root].realize!(dataset)
            end

            ctx = StepContext.new(app)
            StepContext.current = ctx

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
            results = ctx.descriptors.reduce(resources) do |sum, d|
              d.execute_descriptor(app, sum)
            end

            StepContext.current = nil

            results
          end
        end
      end
    end
  end
end
