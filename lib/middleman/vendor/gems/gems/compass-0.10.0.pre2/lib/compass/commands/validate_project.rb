require 'compass/commands/project_base'
require 'compass/commands/update_project'

module Compass
  module Commands
    module ValidationOptionsParser
      def set_options(opts)
        opts.banner = %Q{
          Usage: compass validate [path/to/project] [options]

          Description:
            Compile project at the path specified or the current
            directory if not specified and then validate the 
            generated CSS.

          Options:
        }.strip.split("\n").map{|l| l.gsub(/^ {0,10}/,'')}.join("\n")

        super
      end
    end
    class ValidateProject < ProjectBase

      register :validate

      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def perform
        require 'compass/validator'
        UpdateProject.new(working_path, options).perform
        Dir.chdir Compass.configuration.project_path do
          Validator.new(project_css_subdirectory).validate()
        end
      end

      class << self

        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(ValidationOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def description(command)
          "Validate your generated css."
        end

        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parse_arguments!(parser, arguments)
          parser.options
        end

        def parse_arguments!(parser, arguments)
          if arguments.size == 1
            parser.options[:project_name] = arguments.shift
          elsif arguments.size == 0
            # default to the current directory.
          else
            raise Compass::Error, "Too many arguments were specified."
          end
        end

      end

    end
  end
end
