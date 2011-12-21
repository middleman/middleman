require 'thor'
require "thor/group"

# CLI Module
module Middleman::CLI
  
  class Base < Thor
    include Thor::Actions

    class_option "help", 
      :type    => :boolean, 
      :default => false, 
      :aliases => "-h"
    def initialize(*)
      super
      help_check if options[:help]
    end

    desc "version", "Show version"
    def version
      require 'middleman/version'
      say "Middleman #{Middleman::VERSION}"
    end
    
  private

    def help_check
      help self.class.send(:retrieve_task_name, ARGV.dup)
      exit 0
    end
  end
end

require "middleman/cli/templates"
require "middleman/cli/server"
require "middleman/cli/build"