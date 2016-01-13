module Middleman
  module CoreExtensions
    # Load helpers in `helpers/`
    class ExternalHelpers < Extension
      define_setting :helpers_dir, 'helpers', 'Directory to autoload helper modules from'
      define_setting :helpers_filename_glob, '**.rb', 'Glob pattern for matching helper ruby files'
      define_setting :helpers_filename_to_module_name_proc, proc { |filename|
        basename = File.basename(filename, File.extname(filename))
        basename.camelcase
      }, 'Proc implementing the conversion from helper filename to module name'

      def after_configuration
        helpers_path = File.join(app.root, app.config[:helpers_dir])

        return unless File.exist?(helpers_path)

        glob = File.join(helpers_path, app.config[:helpers_filename_glob])
        ::Middleman::Util.glob_directory(glob).each do |filename|
          module_name = app.config[:helpers_filename_to_module_name_proc].call(filename)
          next unless module_name

          require filename
          next unless Object.const_defined?(module_name.to_sym)

          app.template_context_class.send :include, Object.const_get(module_name.to_sym)
        end
      end
    end
  end
end
