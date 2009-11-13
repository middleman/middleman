require File.join(File.dirname(__FILE__), 'project_base')
require File.join(Compass.lib_directory, 'compass', 'compiler')

module Compass
  module Commands
    class UpdateProject < ProjectBase
      
      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def perform
        compiler = new_compiler_instance
        if compiler.sass_files.empty?
          message = "Nothing to compile. If you're trying to start a new project, you have left off the directory argument.\n"
          message << "Run \"compass -h\" to get help."
          raise Compass::Error, message
        else
          compiler.run
        end
      end

      def new_compiler_instance(additional_options = {})
        Compass::Compiler.new(working_path,
          projectize(Compass.configuration.sass_dir),
          projectize(Compass.configuration.css_dir),
          Compass.sass_engine_options.merge(:quiet => options[:quiet],
                                            :force => options[:force]).merge(additional_options))
      end

    end
  end
end