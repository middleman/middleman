require 'middleman-core/sitemap/resource'
require 'middleman-core/core_extensions/collections/step_context'

module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class MoveFile < Extension
        MoveFileDescriptor = Struct.new(:from, :to)

        self.resource_list_manipulator_priority = 101

        # Expose `create_move_file` to config as `move_file`
        expose_to_config move_file: :create_move_file

        def initialize(app, config={}, &block)
          super

          @move_configs = Set.new
        end

        def after_configuration
          ::Middleman::CoreExtensions::Collections::StepContext.add_to_context(:move_file, &method(:create_move_file))
        end

        # Setup a move from one path to another
        # @param [String] from The original path.
        # @param [String] to The new path.
        # @return [void]
        Contract String, String => Any
        def create_move_file(from, to)
          @move_configs << create_anonymous_move(from, to)
          @app.sitemap.rebuild_resource_list!(:added_move_file)
        end

        # Setup a move from one path to another
        # @param [String] from The original path.
        # @param [String] to The new path.
        # @return [MoveFileDescriptor]
        Contract String, String => MoveFileDescriptor
        def create_anonymous_move(from, to)
          MoveFileDescriptor.new(
            ::Middleman::Util.normalize_path(from),
            ::Middleman::Util.normalize_path(to)
          )
        end

        # Update the main sitemap resource list
        # @return Array<Middleman::Sitemap::Resource>
        Contract ResourceList => ResourceList
        def manipulate_resource_list(resources)
          resources.each do |r|
            matches = @move_configs.select do |c|
              c.from == r.path || c.from == r.destination_path
            end

            if c = matches.last
              r.destination_path = c.to
            end
          end

          resources
        end
      end
    end
  end
end
