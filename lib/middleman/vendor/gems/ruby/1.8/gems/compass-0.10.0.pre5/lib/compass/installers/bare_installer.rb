module Compass
  module Installers

    class BareInstaller < Base
      def completed_configuration
        nil
      end

      def init
        directory targetize("")
        directory targetize(Compass.configuration.sass_dir)
      end

      def prepare
      end

      def install
        config_file ||= targetize('config.rb')
        write_file config_file, config_contents
      end

      def config_contents
        project_path, Compass.configuration.project_path = Compass.configuration.project_path, nil
        Compass.configuration.serialize
      ensure
        Compass.configuration.project_path = project_path
      end

      def finalize(options = {})
        puts <<-NEXTSTEPS

*********************************************************************
Congratulations! Your compass project has been created.

You may now add sass stylesheets to the #{Compass.configuration.sass_dir} subdirectory of your project.

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

    end
  end
end
