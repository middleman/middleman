require 'set'
require 'middleman-core/contracts'

module Middleman
  module Sitemap
    module Extensions
      class Import < Extension
        self.resource_list_manipulator_priority = 1

        ImportFileDescriptor = Struct.new(:from, :to)
        ImportPathDescriptor = Struct.new(:from, :renameProc)

        # Expose `create_import_file` to config as `import_file`
        expose_to_config import_file: :create_import_file

        # Expose `create_import_path` to config as `import_path`
        expose_to_config import_path: :create_import_path

        def initialize(app, config={}, &block)
          super

          @import_file_configs = Set.new
          @import_path_configs = Set.new
        end

        def after_configuration
          ::Middleman::CoreExtensions::Collections::StepContext.add_to_context(:import_file, &method(:create_import_file))
          ::Middleman::CoreExtensions::Collections::StepContext.add_to_context(:import_path, &method(:create_import_path))
        end

        # Import an external file into `source`
        # @param [String] from The original path.
        # @param [String] to The new path.
        # @return [void]
        Contract String, String => Any
        def create_import_file(from, to)
          @import_file_configs << create_anonymous_import_file(from, to)
          @app.sitemap.rebuild_resource_list!(:added_import_file)
        end

        # Import an external file into `source`
        # @param [String] from The original path.
        # @param [String] to The new path.
        # @return [ImportFileDescriptor]
        Contract String, String => ImportFileDescriptor
        def create_anonymous_import_file(from, to)
          ImportFileDescriptor.new(
            File.expand_path(from, @app.root),
            ::Middleman::Util.normalize_path(to)
          )
        end

        # Import an external glob into `source`
        # @param [String] from The original path.
        # @param [Proc] block Renaming method
        # @return [void]
        Contract String, Maybe[Proc] => Any
        def create_import_path(from, &block)
          rename_proc = block_given? ? block : proc { |path| path }
          @import_path_configs << create_anonymous_import_path(from, rename_proc)
          @app.sitemap.rebuild_resource_list!(:added_import_path)
        end

        # Import an external glob into `source`
        # @param [String] from The original path.
        # @param [Proc] block Renaming method
        # @return [ImportPathDescriptor]
        Contract String, Proc => ImportPathDescriptor
        def create_anonymous_import_path(from, block)
          ImportPathDescriptor.new(
            from,
            block
          )
        end

        Contract IsA['Middleman::SourceFile'] => Bool
        def ignored?(file)
          @app.config[:ignored_sitemap_matchers].any? { |_, fn| fn.call(file, @app) }
        end

        # Update the main sitemap resource list
        # @return Array<Middleman::Sitemap::Resource>
        Contract ResourceList => ResourceList
        def manipulate_resource_list(resources)
          resources + @import_file_configs.map { |c|
            ::Middleman::Sitemap::Resource.new(
              @app.sitemap,
              c[:to],
              c[:from]
            )
          } + @import_path_configs.flat_map { |c|
            ::Middleman::Util.glob_directory(File.join(c[:from], '**/*'))
              .reject { |path| File.directory?(path) }
              .map do |path|
              target_path = Pathname(path).relative_path_from(Pathname(c[:from]).parent).to_s

              ::Middleman::Sitemap::Resource.new(
                @app.sitemap,
                c[:renameProc].call(target_path, path),
                path
              )
            end
          }
        end
      end
    end
  end
end
