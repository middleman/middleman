require 'compass/commands/project_base'
require 'compass/compiler'

module Compass
  module Commands
    module CompileProjectOptionsParser
      def set_options(opts)
        opts.banner = %Q{
          Usage: compass compile [path/to/project] [options]

          Description:
          compile project at the path specified or the current director if not specified.

          Options:
        }.split("\n").map{|l| l.gsub(/^ */,'')}.join("\n")

        super
      end
    end

    class UpdateProject < ProjectBase

      register :compile

      def initialize(working_path, options)
        super
        assert_project_directory_exists! unless dry_run?
      end

      def perform
        compiler = new_compiler_instance
        if compiler.sass_files.empty? && !dry_run?
          message = "Nothing to compile. If you're trying to start a new project, you have left off the directory argument.\n"
          message << "Run \"compass -h\" to get help."
          raise Compass::Error, message
        else
          compiler.run
        end
      end

      def dry_run?
        options[:dry_run]
      end

      def new_compiler_instance(additional_options = {})
        Compass::Compiler.new(working_path,
          projectize(Compass.configuration.sass_dir),
          projectize(Compass.configuration.css_dir),
          Compass.sass_engine_options.merge(:quiet => options[:quiet],
                                            :force => options[:force]).merge(additional_options))
      end

      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(CompileProjectOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def primary; true; end

        def description(command)
          "Compile Sass stylesheets to CSS"
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
          elsif arguments.size > 1
            raise Compass::Error, "Too many arguments were specified."
          end
        end
      end
    end
  end
end
