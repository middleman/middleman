module Compass
  module Configuration
    # The adapters module provides methods that make configuration data from a compass project
    # adapt to various consumers of configuration data
    module Adapters
      def to_compiler_arguments(additional_options)
        [project_path, sass_path, css_path, to_sass_engine_options.merge(additional_options)]
      end

      def to_sass_plugin_options
        locations = {}
        locations[sass_path] = css_path if sass_path && css_path
        Compass::Frameworks::ALL.each do |framework|
          locations[framework.stylesheets_directory] = css_path || css_dir || "."
        end
        resolve_additional_import_paths.each do |additional_path|
          locations[additional_path] = File.join(css_path || css_dir || ".", File.basename(additional_path))
        end
        plugin_opts = {:template_location => locations}
        plugin_opts[:style] = output_style if output_style
        plugin_opts[:line_comments] = line_comments if environment
        plugin_opts.merge!(sass_options || {})
        plugin_opts
      end

      def resolve_additional_import_paths
        (additional_import_paths || []).map do |path|
          if project_path && !absolute_path?(path)
            File.join(project_path, path)
          else
            path
          end
        end
      end

      def absolute_path?(path)
        # This is only going to work on unix, gonna need a better implementation.
        path.index(File::SEPARATOR) == 0
      end

      def to_sass_engine_options
        engine_opts = {:load_paths => sass_load_paths}
        engine_opts[:style] = output_style if output_style
        engine_opts[:line_comments] = line_comments if environment
        engine_opts.merge!(sass_options || {})
      end

      def sass_load_paths
        load_paths = []
        load_paths << sass_path if sass_path
        Compass::Frameworks::ALL.each do |framework|
          load_paths << framework.stylesheets_directory if File.exists?(framework.stylesheets_directory)
        end
        load_paths += resolve_additional_import_paths
        load_paths
      end
    end
  end
end
