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
            source = ::Middleman::SourceFile.new(Pathname(from).relative_path_from(app.source_dir), Pathname(from), app.source_dir, Set.new([:source, :binary]), 0)

            resources + [
              ::Middleman::Sitemap::Resource.new(app.sitemap, to, source)
            ]
          end
        end

        ImportPathDescriptor = Struct.new(:from, :renameProc) do
          def execute_descriptor(app, resources)
            resources + ::Middleman::Util.glob_directory(File.join(from, '**/*'))
                                         .reject { |path| File.directory?(path) }
                                         .map do |path|
                          target_path = Pathname(path).relative_path_from(Pathname(from).parent).to_s

                          ::Middleman::Sitemap::Resource.new(
                            app.sitemap,
                            renameProc.call(target_path, path),
                            path
                          )
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
      end
    end
  end
end
