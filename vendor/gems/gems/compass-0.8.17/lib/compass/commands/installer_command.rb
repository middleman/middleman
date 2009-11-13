require File.join(Compass.lib_directory, 'compass', 'installers')

module Compass
  module Commands
    module InstallerCommand
      include Compass::Installers

      def configure!
        read_project_configuration
        Compass.configuration.set_maybe(options)
        Compass.configuration.default_all(installer.configuration_defaults)
        Compass.configuration.set_defaults!
      end

      def installer
        @installer ||= case options[:project_type]
        when :stand_alone
          StandAloneInstaller.new *installer_args
        when :rails
          RailsInstaller.new *installer_args
        else
          raise "Unknown project type: #{options[:project_type].inspect}"
        end
      end

      def installer_args
        [template_directory(options[:pattern]), project_directory, options]
      end
    end
  end
end