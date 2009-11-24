require File.join(File.dirname(__FILE__), 'project_base')
require File.join(File.dirname(__FILE__), 'update_project')
require File.join(File.dirname(__FILE__), '..', 'grid_builder')

module Compass
  module Commands
    class GenerateGridBackground < ProjectBase
      include Actions
      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def perform
        column_width, gutter_width = options[:grid_dimensions].split(/\+/).map{|d| d.to_i}
        unless GridBuilder.new(options.merge(:column_width => column_width, :gutter_width => gutter_width, :output_path => projectize(project_images_subdirectory), :working_path => self.working_path)).generate!
          puts "ERROR: Some library dependencies appear to be missing."
          puts "Have you installed rmagick? If not, please run:"
          puts "sudo gem install rmagick"
        end
      end
    end
  end
end