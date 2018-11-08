require 'middleman-core/sitemap/resource'
require 'middleman-core/core_extensions/collections/step_context'

module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class MoveFile < ConfigExtension
        self.resource_list_manipulator_priority = 101

        # Expose `move_file`
        expose_to_config :move_file

        MoveFileDescriptor = Struct.new(:from, :to) do
          def execute_descriptor(_app, resource_list)
            resource_list.each do |r|
              next unless from == r.path || from == r.destination_path

              resource_list.update!(r, :destination_path) do
                r.destination_path = to
              end
            end
          end
        end

        # Setup a move from one path to another
        # @param [String] from The original path.
        # @param [String] to The new path.
        # @return [void]
        Contract String, String => MoveFileDescriptor
        def move_file(from, to)
          MoveFileDescriptor.new(
            ::Middleman::Util.normalize_path(from),
            ::Middleman::Util.normalize_path(to)
          )
        end
      end
    end
  end
end
