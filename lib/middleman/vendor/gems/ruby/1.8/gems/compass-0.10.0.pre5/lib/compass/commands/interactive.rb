
require 'compass/commands/project_base'
require 'compass/commands/update_project'

module Compass
  module Commands
    module InteractiveOptionsParser
      def set_options(opts)
        opts.banner = %Q{
          Usage: compass interactive [path/to/project] [options]

          Description:
            Interactively evaluate SassScript

          Options:
        }.strip.split("\n").map{|l| l.gsub(/^ {0,10}/,'')}.join("\n")

        super
      end
    end
    class Interactive < ProjectBase

      register :interactive

      def initialize(working_path, options)
        super
      end

      def perform
        require 'sass/repl'
        Sass::Repl.new.run
      end

      class << self

        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(InteractiveOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def description(command)
          "Interactively evaluate SassScript"
        end

        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parser.options
        end

      end

    end
  end
end
