require 'compass/installers'

module Compass
  module Commands
    module InstallerCommand
      include Compass::Installers

      def configure!
        if respond_to?(:is_project_creation?) && is_project_creation?
          Compass.add_configuration(options.delete(:project_type) || :stand_alone)
        else
          Compass.add_project_configuration(:project_type => options.delete(:project_type))
        end
        Compass.add_configuration(options, 'command_line')
        if File.exists?(Compass.configuration.extensions_path)
          Compass::Frameworks.discover(Compass.configuration.extensions_path)
        end
        Compass.add_configuration(installer.completed_configuration, 'installer')
      end

      def app
        @app ||= Compass::AppIntegration.lookup(Compass.configuration.project_type)
      end

      def installer
        @installer ||= if options[:bare]
          Compass::Installers::BareInstaller.new(*installer_args)
        else
          app.installer(*installer_args)
        end
      end

      def installer_args
        [template_directory(options[:pattern] || "project"), project_directory, options]
      end
    end
  end
end
