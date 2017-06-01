require 'set'
require 'middleman-core/contracts'

module Middleman
  module Sitemap
    module Extensions
      class Import < ConfigExtension
        self.resource_list_manipulator_priority = 1

        # Expose methods
        expose_to_config :import_file, :import_path

        ImportFileDescriptor = Struct.new(:from, :to) do
          def execute_descriptor(app, resources)
            resources + [ Import.create_resource!(app, from, to) ]
          end
        end

        ImportPathDescriptor = Struct.new(:from, :renameProc) do
          def execute_descriptor(app, resources)
            resources + ::Middleman::Util.glob_directory(File.join(from, '**/*'))
                                         .reject { |path| File.directory?(path) }
                                         .map do |path|
                          target_path = Pathname(path).relative_path_from(Pathname(from).parent).to_s

                          Import.create_resource!(app, path, renameProc.call(target_path, path))
                        end
          end
        end

        # Import an external file into `source`
        # @param [String] from The original path.
        # @param [String] to The new path.
        # @return [void]
        Contract String, String => ImportFileDescriptor
        def import_file(from, to)
          ImportFileDescriptor.new(
            File.expand_path(from, @app.root),
            ::Middleman::Util.normalize_path(to)
          )
        end

        # Import an external glob into `source`
        # @param [String] from The original path.
        # @param [Proc] block Renaming method
        # @return [void]
        Contract String, Maybe[Proc] => ImportPathDescriptor
        def import_path(from, &block)
          ImportPathDescriptor.new(
            from,
            block_given? ? block : proc { |path| path }
          )
        end

        # Utility method for use in imported descriptors
        #
        Contract ::Middleman::Application, String, String => ::Middleman::Sitemap::Resource
        def self.create_resource! app, from, to
          source = ::Middleman::SourceFile.new(Pathname(from).relative_path_from(app.source_dir), Pathname(from), app.source_dir, Set.new([:source]), 0)
          source.types.add(:binary) if ::Middleman::Util.binary?(source.full_path.to_s)
          new_resource = ::Middleman::Sitemap::Resource.new(app.sitemap, to, source)

          if new_resource.template? && !app.files.exists?(:source, source[:full_path].to_s)
            app.files.watch :source, path: File.dirname(source[:full_path].to_s)
          end

          new_resource
        end
      end
    end
  end
end
