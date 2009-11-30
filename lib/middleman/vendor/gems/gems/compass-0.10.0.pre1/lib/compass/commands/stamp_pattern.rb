require 'fileutils'
require 'compass/commands/base'
require 'compass/commands/update_project'

module Compass
  module Commands
    module StampPatternOptionsParser
      def set_options(opts)
        opts.banner = %Q{Usage: compass install extension/pattern [path/to/project] [options]

Description:
  Install an extension's pattern into your compass project

Example:
  compass install blueprint/buttons

Options:
}
        super
      end
    end

    class StampPattern < ProjectBase

      register :install

      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(StampPatternOptionsParser)
        end
        def usage
          option_parser([]).to_s
        end
        def description(command)
          "Install an extension's pattern into your compass project"
        end
        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parse_arguments!(parser, arguments)
          parser.options
        end
        def parse_arguments!(parser, arguments)
          if arguments.size == 0
            raise OptionParser::ParseError, "Please specify a pattern."
          end
          pattern = arguments.shift.split('/', 2)
          parser.options[:framework] = pattern[0]
          parser.options[:pattern] = pattern[1]
          if arguments.size > 0
            parser.options[:project_name] = arguments.shift
          end
          if arguments.size > 0
            raise OptionParser::ParseError, "Unexpected trailing arguments: #{arguments.join(" ")}"
          end
        end

      end
      include InstallerCommand

      def initialize(working_path, options)
        super(working_path, options)
      end

      # all commands must implement perform
      def perform
        installer.init
        installer.run(:skip_finalization => true)
        UpdateProject.new(working_path, options).perform if installer.compilation_required?
        installer.finalize(:create => is_project_creation?)
      end

      def is_project_creation?
        false
      end

      def template_directory(pattern)
        File.join(framework.templates_directory, pattern)
      end

    end
  end
end
