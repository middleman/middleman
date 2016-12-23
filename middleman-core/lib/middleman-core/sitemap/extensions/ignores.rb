module Middleman
  module Sitemap
    module Extensions
      # Class to handle managing ignores
      class Ignores < ConfigExtension
        self.resource_list_manipulator_priority = 0

        expose_to_application :ignore
        expose_to_config :ignore

        # Ignore a path or add an ignore callback
        # @param [String, Regexp] path Path glob expression, or path regex
        # @return [IgnoreDescriptor]
        Contract Or[String, Regexp, Proc] => RespondTo[:execute_descriptor]
        def ignore(path=nil, &block)
          @app.sitemap.invalidate_resources_not_ignored_cache!

          if path.is_a? Regexp
            RegexpIgnoreDescriptor.new(path)
          elsif path.is_a? String
            path_clean = ::Middleman::Util.normalize_path(path)

            if path_clean.include?('*') # It's a glob
              GlobIgnoreDescriptor.new(path_clean)
            else
              StringIgnoreDescriptor.new(path_clean)
            end
          elsif block
            BlockIgnoreDescriptor.new(nil, block)
          else
            IgnoreDescriptor.new(path, block)
          end
        end

        IgnoreDescriptor = Struct.new(:path, :block) do
          def execute_descriptor(_app, resources)
            resources.map do |r|
              # Ignore based on the source path (without template extensions)
              if ignored?(r.normalized_path)
                r.ignore!
              elsif !r.is_a?(ProxyResource) && r.file_descriptor && ignored?(r.file_descriptor.normalized_relative_path)
                # This allows files to be ignored by their source file name (with template extensions)
                r.ignore!
              end

              r
            end
          end

          def ignored?(_match_path)
            raise NotImplementedError
          end
        end

        class RegexpIgnoreDescriptor < IgnoreDescriptor
          def ignored?(match_path)
            match_path =~ path
          end
        end

        class GlobIgnoreDescriptor < IgnoreDescriptor
          def ignored?(match_path)
            if defined?(::File::FNM_EXTGLOB)
              ::File.fnmatch(path, match_path, ::File::FNM_EXTGLOB)
            else
              ::File.fnmatch(path, match_path)
            end
          end
        end

        class StringIgnoreDescriptor < IgnoreDescriptor
          def ignored?(match_path)
            match_path == path
          end
        end

        class BlockIgnoreDescriptor < IgnoreDescriptor
          def ignored?(match_path)
            block.call(match_path)
          end
        end
      end
    end
  end
end
