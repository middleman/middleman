# Load helpers in helpers/
module Middleman
  module CoreExtensions
    module ExternalHelpers
      # Setup extension
      class << self
        # once registered
        def registered(app)
          # Setup a default helpers paths
          app.config.define_setting :helpers_dir, 'helpers', 'Directory to autoload helper modules from'
          app.config.define_setting :helpers_filename_glob, '**.rb', 'Glob pattern for matching helper ruby files'
          app.config.define_setting :helpers_filename_to_module_name_proc, proc { |filename|
            basename = File.basename(filename, File.extname(filename))
            basename.camelcase
          }, 'Proc implementing the conversion from helper filename to module name'

          # Before config
          app.before_configuration do

            # Watch for changes in the helpers directory
            files.changed Regexp.new("#{config[:helpers_dir]}/.*\\.rb") do |path|
              helper_path = File.join(root, path)
              next unless File.exist?(helper_path)

              module_name = config[:helpers_filename_to_module_name_proc].call(helper_path)
              next unless module_name

              Object.send(:remove_const, module_name.to_sym) if Object.const_defined?(module_name.to_sym)
              load helper_path
              next unless Object.const_defined?(module_name.to_sym)

              helpers Object.const_get(module_name.to_sym)
            end
          end
        end
        alias_method :included, :registered
      end
    end
  end
end
