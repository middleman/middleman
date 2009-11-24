require 'fileutils'
require 'pathname'
require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'installer_command')

module Compass
  module Commands
    class ProjectBase < Base
      attr_accessor :project_directory, :project_name, :options

      def initialize(working_path, options = {})
        super(working_path, options)
        self.project_name = determine_project_name(working_path, options)
        Compass.configuration.project_path = determine_project_directory(working_path, options)
      end

      def execute
        configure!
        super
      end

      protected

      def configure!
        read_project_configuration
        Compass.configuration.set_maybe(options)
        Compass.configuration.set_defaults!
      end

      def projectize(path)
        File.join(project_directory, separate(path))
      end

      def project_directory
        Compass.configuration.project_path
      end

      def project_css_subdirectory
        Compass.configuration.css_dir
      end

      def project_src_subdirectory
        Compass.configuration.sass_dir
      end

      def project_images_subdirectory
        Compass.configuration.images_dir
      end

      # Read the configuration file for this project
      def read_project_configuration
        if file = detect_configuration_file
          Compass.configuration.parse(file) if File.readable?(file)
        end
      end

      def explicit_config_file_must_be_readable?
        true
      end

      # TODO: Deprecate the src/config.rb location.
      KNOWN_CONFIG_LOCATIONS = [".compass/config.rb", "config/compass.config", "config.rb", "src/config.rb"]

      # Finds the configuration file, if it exists in a known location.
      def detect_configuration_file
        if options[:configuration_file]
          if explicit_config_file_must_be_readable? && !File.readable?(options[:configuration_file])
            raise Compass::Error, "Configuration file, #{file}, not found or not readable."
          end
          return options[:configuration_file]
        end
        KNOWN_CONFIG_LOCATIONS.map{|f| projectize(f)}.detect{|f| File.exists?(f)}
      end

      def assert_project_directory_exists!
        if File.exists?(project_directory) && !File.directory?(project_directory)
          raise Compass::FilesystemConflict.new("#{project_directory} is not a directory.")
        elsif !File.directory?(project_directory)
          raise Compass::Error.new("#{project_directory} does not exist.")
        end
      end

      private

      def determine_project_name(working_path, options)
        if options[:project_name]
          File.basename(strip_trailing_separator(options[:project_name]))
        else
          File.basename(working_path)
        end
      end

      def determine_project_directory(working_path, options)
        if options[:project_name]
          if absolute_path?(options[:project_name])
            options[:project_name]
          else
            File.join(working_path, options[:project_name])
          end
        else
          working_path
        end
      end

      def absolute_path?(path)
        # This is only going to work on unix, gonna need a better implementation.
        path.index(File::SEPARATOR) == 0
      end

    end
  end
end