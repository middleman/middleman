require 'fileutils'
require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'update_project')

module Compass
  module Commands
    class StampPattern < ProjectBase

      include InstallerCommand

      def initialize(working_path, options)
        super(working_path, options)
      end

      # all commands must implement perform
      def perform
        installer.init
        installer.run(:skip_finalization => true)
        UpdateProject.new(working_path, options).perform if installer.compilation_required?
        installer.finalize(:create => is_project_creation?)
      end

      def is_project_creation?
        false
      end

      def template_directory(pattern)
        File.join(framework.templates_directory, pattern)
      end

    end
  end
end