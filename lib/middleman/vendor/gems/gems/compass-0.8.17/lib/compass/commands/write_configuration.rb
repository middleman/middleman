require File.join(File.dirname(__FILE__), 'project_base')

module Compass
  module Commands
    class WriteConfiguration < ProjectBase
      
      include InstallerCommand

      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def perform
        installer.write_configuration_files(options[:configuration_file])
      end

      def installer_args
        [nil, project_directory, options]
      end

      def explicit_config_file_must_be_readable?
        false
      end

    end
  end
end