module Middleman
  module Sitemap
    module Extensions
      module Ignores
        # Setup extension
        class << self
          # Once registered
          def registered(app)
            # Include methods
            app.send :include, InstanceMethods

            ::Middleman::Sitemap::Resource.send :include, ResourceInstanceMethods
          end

          alias_method :included, :registered
        end

        # Helpers methods for Resources
        module ResourceInstanceMethods
          # Whether the Resource is ignored
          # @return [Boolean]
          def ignored?
            @app.ignore_manager.ignored?(path) ||
              (!proxy? &&
                @app.ignore_manager.ignored?(source_file.sub("#{@app.source_dir}/", ''))
              )
          end
        end

        # Ignore-related instance methods
        module InstanceMethods
          def ignore_manager
            @_ignore_manager ||= IgnoreManager.new(self)
          end

          # Ignore a path or add an ignore callback
          # @param [String, Regexp] path Path glob expression, or path regex
          # @return [void]
          def ignore(path=nil, &block)
            ignore_manager.ignore(path, &block)
          end
        end

        # Class to handle managing ignores
        class IgnoreManager
          def initialize(app)
            @app = app

            # Array of callbacks which can ass ignored
            @ignored_callbacks = []
          end

          # Ignore a path or add an ignore callback
          # @param [String, Regexp] path Path glob expression, or path regex
          # @return [void]
          def ignore(path=nil, &block)
            if path.is_a? Regexp
              @ignored_callbacks << proc { |p| p =~ path }
            elsif path.is_a? String
              path_clean = ::Middleman::Util.normalize_path(path)
              if path_clean.include?('*') # It's a glob
                @ignored_callbacks << proc { |p| File.fnmatch(path_clean, p) }
              else
                # Add a specific-path ignore unless that path is already covered
                return if ignored?(path_clean)
                @ignored_callbacks << proc { |p| p == path_clean }
              end
            elsif block_given?
              @ignored_callbacks << block
            end

            @app.sitemap.invalidate_resources_not_ignored_cache!
          end

          # Whether a path is ignored
          # @param [String] path
          # @return [Boolean]
          def ignored?(path)
            path_clean = ::Middleman::Util.normalize_path(path)
            @ignored_callbacks.any? { |b| b.call(path_clean) }
          end
        end
      end
    end
  end
end
