# Load helpers in helpers/
module Middleman
  module CoreExtensions
    module ExternalHelpers

      # Setup extension
      class << self

        # once registered
        def registered(app)
          # Setup a default helpers paths
          app.set :helpers_dir, "helpers"
          app.set :helpers_filename_glob, "**{,/*/**}/*.rb"
          app.set :helpers_filename_to_module_name_proc, Proc.new { |filename|
            basename = File.basename(filename, File.extname(filename))
            basename.camelcase
          }

          # After config
          app.after_configuration do
            helpers_path = File.expand_path(helpers_dir, root)
            next unless File.exists?(helpers_path)

            Dir[File.join(helpers_path, helpers_filename_glob)].each do |filename|
              module_name = helpers_filename_to_module_name_proc.call(filename)
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
