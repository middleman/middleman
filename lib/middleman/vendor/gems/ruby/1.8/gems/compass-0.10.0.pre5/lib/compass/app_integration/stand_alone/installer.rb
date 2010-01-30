module Compass
  module Installers
    class Base
    end
    class ManifestInstaller < Base
    end
  end

  module AppIntegration
    module StandAlone
      class Installer < Compass::Installers::ManifestInstaller

        def init
          directory targetize("")
          super
        end

        def write_configuration_files(config_file = nil)
          config_file ||= targetize('config.rb')
          write_file config_file, config_contents
        end

        def config_files_exist?
          File.exists? targetize('config.rb')
        end

        def config_contents
          project_path, Compass.configuration.project_path = Compass.configuration.project_path, nil
          Compass.configuration.serialize
        ensure
          Compass.configuration.project_path = project_path
        end

        def prepare
          write_configuration_files unless config_files_exist? || !@manifest.generate_config?
        end

        def completed_configuration
          nil
        end

        def finalize(options = {})
          if options[:create] && !manifest.welcome_message_options[:replace]
            puts <<-NEXTSTEPS

*********************************************************************
Congratulations! Your compass project has been created.

You may now add and edit sass stylesheets in the #{Compass.configuration.sass_dir} subdirectory of your project.

Sass files beginning with an underscore are called partials and won't be
compiled to CSS, but they can be imported into other sass stylesheets.

You can configure your project by editing the config.rb configuration file.

You must compile your sass stylesheets into CSS when they change.
This can be done in one of the following ways:
  1. To compile on demand:
     compass compile [path/to/project]
  2. To monitor your project for changes and automatically recompile:
     compass watch [path/to/project]

More Resources:
  * Wiki: http://wiki.github.com/chriseppstein/compass
  * Sass: http://sass-lang.com
  * Community: http://groups.google.com/group/compass-users/

NEXTSTEPS
          end
          puts manifest.welcome_message if manifest.welcome_message
          if manifest.has_stylesheet? && !manifest.welcome_message_options[:replace]
            puts "\nTo import your new stylesheets add the following lines of HTML (or equivalent) to your webpage:"
            puts stylesheet_links
          end
        end

        def compilation_required?
          @manifest.compile?
        end
      end
    end
  end
end
