# This file came from the Blueprint Project
begin
  require 'rubygems'
  gem 'rmagick'
  require 'rvg/rvg'
rescue Exception => e
end

module Compass
  # Uses ImageMagick and RMagick to generate grid.png file
  class GridBuilder
    include Actions

    begin
      include Magick
    rescue Exception => e
    end

    attr_reader :column_width, :gutter_width, :output_path, :able_to_generate, :options

    # ==== Options
    # * <tt>options</tt>
    #   * <tt>:column_width</tt> -- Width (in pixels) of current grid column
    #   * <tt>:gutter_width</tt> -- Width (in pixels) of current grid gutter
    #   * <tt>:output_path</tt> -- Output path of grid.png file
    def initialize(options={})
      @able_to_generate = Magick::Long_version rescue false
      return unless @able_to_generate
      @column_width = options[:column_width]
      @gutter_width = options[:gutter_width]
      @output_path  = options[:output_path]
      @options = options
    end

    def working_path
      options[:working_path]
    end
  
    # generates (overwriting if necessary) grid.png image to be tiled in background
    def generate!
      return false unless self.able_to_generate
      total_width = self.column_width + self.gutter_width
      height = 20
      RVG::dpi = 100

      rvg = RVG.new((total_width.to_f/RVG::dpi).in, (height.to_f/RVG::dpi).in).viewbox(0, 0, total_width, height) do |canvas|
        canvas.background_fill = 'white'

        canvas.g do |column|
          column.rect(self.column_width, height).styles(:fill => "#e8effb")
        end

        canvas.g do |baseline|
          baseline.line(0, (height - 1), total_width, (height- 1)).styles(:fill => "#e9e9e9")
        end
      end

      filename = File.join(self.output_path, "grid.png")
      if File.exists?(filename)
        if options[:force]
          overwrite = true
        else
          msg = "#{filename} already exists. Overwrite with --force."
          raise Compass::FilesystemConflict.new(msg)
        end
      end
      directory self.output_path
      logger.record((overwrite ? :overwrite : :create), basename(filename))
      rvg.draw.write(filename)
    end
  end
end