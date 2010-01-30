require 'fileutils'
require 'compass/commands/stamp_pattern'

module Compass
  module Commands
    module CreateProjectOptionsParser
      def set_options(opts)

        if $command == "create"
          opts.banner = %Q{
            Usage: compass create path/to/project [options]

            Description:
            Create a new compass project at the path specified.

            Options:
          }.split("\n").map{|l| l.gsub(/^ */,'')}.join("\n")

          opts.on_tail("--bare", "Don't generate any Sass or CSS files.") do
            self.options[:bare] = true
          end
        else
          opts.banner = %Q{
            Usage: compass init project_type path/to/project [options]

            Description:
            Initialize an existing project at the path specified.

            Supported Project Types:
            * rails

            Options:
          }.split("\n").map{|l| l.gsub(/^ */,'')}.join("\n").strip
        end

        opts.on("--using FRAMEWORK", "Framework to use when creating the project.") do |framework|
          framework = framework.split('/', 2)
          self.options[:framework] = framework[0]
          self.options[:pattern] = framework[1]
        end

        super
      end
    end

    class CreateProject < StampPattern

      register :create
      register :init

      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(CreateProjectOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def description(command)
          if command.to_sym == :create
            "Create a new compass project"
          else
            "Initialize an existing project"
          end
        end

        def primary; true; end

        def parse!(arguments)
          parser = option_parser(arguments)
          parse_options!(parser, arguments)
          parse_arguments!(parser, arguments)
          if parser.options[:framework] && parser.options[:bare]
            raise Compass::Error, "A bare project cannot be created when a framework is specified."
          end
          set_default_arguments(parser)
          parser.options
        end

        def parse_init!(arguments)
          parser = option_parser(arguments)
          parse_options!(parser, arguments)
          if arguments.size > 0
            parser.options[:project_type] = arguments.shift.to_sym
          end
          parse_arguments!(parser, arguments)
          set_default_arguments(parser)
          parser.options
        end

        def parse_options!(parser, arguments)
          parser.parse!
          parser
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

        def set_default_arguments(parser)
          parser.options[:framework] ||= :compass
          parser.options[:pattern] ||= "project"
        end
      end

      def is_project_creation?
        true
      end

    end
  end
end
