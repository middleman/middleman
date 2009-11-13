require 'fileutils'
require File.join(File.dirname(__FILE__), 'stamp_pattern')
require File.join(File.dirname(__FILE__), 'update_project')

module Compass
  module Commands
    class CreateProject < StampPattern

      def initialize(working_path, options)
        super(working_path, options.merge(:pattern => "project", :pattern_name => nil))
      end

      def is_project_creation?
        true
      end

    end
  end
end