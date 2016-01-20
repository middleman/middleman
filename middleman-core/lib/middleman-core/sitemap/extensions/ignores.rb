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
          IgnoreDescriptor.new(path, block)
        end

        IgnoreDescriptor = Struct.new(:path, :block) do
          def execute_descriptor(_app, resources)
            resources.map do |r|
              # Ignore based on the source path (without template extensions)
              if ignored?(r.path)
                r.ignore!
              elsif !r.is_a?(ProxyResource) && r.file_descriptor && ignored?(r.file_descriptor[:relative_path].to_s)
                # This allows files to be ignored by their source file name (with template extensions)
                r.ignore!
              end

              r
            end
          end

          def ignored?(match_path)
            match_path = ::Middleman::Util.normalize_path(match_path)

            if path.is_a? Regexp
              match_path =~ path
            elsif path.is_a? String
              path_clean = ::Middleman::Util.normalize_path(path)

              if path_clean.include?('*') # It's a glob
                if defined?(::File::FNM_EXTGLOB)
                  ::File.fnmatch(path_clean, match_path, ::File::FNM_EXTGLOB)
                else
                  ::File.fnmatch(path_clean, match_path)
                end
              else
                match_path == path_clean
              end
            elsif block
              block.call(match_path)
            end
          end
        end
      end
    end
  end
end
