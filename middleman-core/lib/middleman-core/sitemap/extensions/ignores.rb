module Middleman
  module Sitemap
    module Extensions
      # Class to handle managing ignores
      class Ignores
        def initialize(sitemap)
          @app = sitemap.app
          @app.add_to_config_context :ignore, &method(:create_ignore)
          @app.define_singleton_method(:ignore, &method(:create_ignore))

          # Array of callbacks which can ass ignored
          @ignored_callbacks = []

          sitemap.define_singleton_method(:ignored?, &method(:ignored?))
          ::Middleman::Sitemap::Resource.send :include, IgnoreResourceInstanceMethods
        end

        # Ignore a path or add an ignore callback
        # @param [String, Regexp] path Path glob expression, or path regex
        # @return [void]
        def create_ignore(path=nil, &block)
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

      # Helpers methods for Resources
      module IgnoreResourceInstanceMethods
        # Whether the Resource is ignored
        # @return [Boolean]
        def ignored?
          # Check frontmatter/data
          return true if !proxy? && data[:ignored] == true
          # Ignore based on the source path (without template extensions)
          return true if @app.sitemap.ignored?(path)
          # This allows files to be ignored by their source file name (with template extensions)
          !proxy? && @app.sitemap.ignored?(source_file.sub("#{@app.source_dir}/", ''))
        end
      end
    end
  end
end
