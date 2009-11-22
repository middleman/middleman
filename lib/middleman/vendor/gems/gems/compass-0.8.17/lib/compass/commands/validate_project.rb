require File.join(File.dirname(__FILE__), 'project_base')
require File.join(File.dirname(__FILE__), 'update_project')

module Compass
  module Commands
    class ValidateProject < ProjectBase
      
      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def perform
        require File.join(File.dirname(__FILE__), '..', 'validator')
        UpdateProject.new(working_path, options).perform
        Validator.new(project_css_subdirectory).validate()
      end

    end
  end
end