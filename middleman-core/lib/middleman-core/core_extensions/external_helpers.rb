# Load helpers in helpers/
module Middleman
  module CoreExtensions
    module ExternalHelpers

      # Setup extension
      class << self

        # once registered
        def registered(app)
          # Setup a default helpers paths
          app.config.define_setting :helpers_dir, "helpers", 'Directory to autoload helper modules from'
          app.config.define_setting :helpers_filename_glob, "**.rb", 'Glob pattern for matching helper ruby files'
          app.config.define_setting :helpers_filename_to_module_name_proc, Proc.new { |filename|
            basename = File.basename(filename, File.extname(filename))
            basename.camelcase
          }, 'Proc implementing the conversion from helper filename to module name'

          # After config
          app.after_configuration do
            helpers_path = File.join(root, config[:helpers_dir])
            next unless File.exists?(helpers_path)

            Dir[File.join(helpers_path, config[:helpers_filename_glob])].each do |filename|
              module_name = config[:helpers_filename_to_module_name_proc].call(filename)
              next unless module_name

              require filename
              next unless Object.const_defined?(module_name.to_sym)

              helpers Object.const_get(module_name.to_sym)
            end
          end
        end
        alias :included :registered
      end
    end
  end
end
