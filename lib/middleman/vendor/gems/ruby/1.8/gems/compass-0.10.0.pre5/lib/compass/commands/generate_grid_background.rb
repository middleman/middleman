require 'compass/commands/project_base'
require 'compass/commands/update_project'
require 'compass/grid_builder'

module Compass
  module Commands
    module GridBackgroundOptionsParser
      def set_options(opts)
        banner = %Q{Usage: compass grid-img W+GxH [path/to/grid.png]

Description:
  Generates a background image that can be used to check grid alignment.

  Height is optional and defaults to 20px

  By default, the image generated will be named "grid.png"
  and be found in the images directory.

  This command requires that you have both ImageMagick and RMagick installed.

Examples:

  compass grid-img 40+10 # 40px column, 10px gutter, 20px height
  compass grid-img 40+20x28 # 40px column, 20px gutter, 28px height
  compass grid-img 60+20x28 images/wide_grid.png

Options:
}
        opts.banner = banner

        super
      end
    end
    class GenerateGridBackground < ProjectBase

      include Actions

      register :"grid-img"

      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(GridBackgroundOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def description(command)
          "Generates a grid background image."
        end

        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          if arguments.size == 0
            raise OptionParser::ParseError, "Please specify the grid dimensions."
          end
          parser.options[:grid_dimensions] = arguments.shift
          parser.options[:grid_filename] = arguments.shift
          parser.options
        end
      end
      def initialize(working_path, options)
        super
        assert_project_directory_exists!
        Compass.add_configuration(options, 'command_line')
      end

      def perform
        unless options[:grid_dimensions] =~ /^(\d+)\+(\d+)(?:x(\d+))?$/
          puts "ERROR: '#{options[:grid_dimensions]}' is not valid."
          puts "Dimensions should be specified like: 30+10x20"
          puts "where 30 is the column width, 10 is the gutter width, and 20 is the (optional) height."
          return
        end
        column_width = $1.to_i
        gutter_width = $2.to_i
        height = $3.to_i if $3
        filename = options[:grid_filename] || projectize("#{project_images_subdirectory}/grid.png")
        GridBuilder.new(options.merge(:column_width => column_width, :gutter_width => gutter_width, :height => height, :filename => filename, :working_path => self.working_path)).generate!
      end
    end
  end
end
