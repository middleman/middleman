require 'compass/commands/project_base'
require 'compass/compiler'

module Compass
  module Commands
    module CompileProjectOptionsParser
      def set_options(opts)
        opts.banner = %Q{
          Usage: compass compile [path/to/project] [path/to/project/src/file.sass ...] [options]

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
                                            :force => options[:force],
                                            :sass_files => explicit_sass_files).merge(additional_options))
      end

      def explicit_sass_files
        return unless options[:sass_files]
        options[:sass_files].map do |sass_file|
          if absolute_path? sass_file
            sass_file
          else
            File.join(Dir.pwd, sass_file)
          end
        end
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
          if arguments.size > 0
            parser.options[:project_name] = arguments.shift if File.directory?(arguments.first)
            unless arguments.empty?
              parser.options[:sass_files] = arguments.dup
              parser.options[:force] = true
            end
          end
        end
      end
    end
  end
end
