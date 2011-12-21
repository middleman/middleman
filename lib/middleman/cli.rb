require 'thor'
require "thor/group"

# CLI Module
module Middleman::Cli
  
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
    
    def method_missing(meth, *args)
      meth = meth.to_s
      
      if self.class.map.has_key?(meth)
        meth = self.class.map[meth]
      end
      
      # initialize_thorfiles(meth)
      klass, task = Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")
      args.unshift(task) if task
      klass.start(args, :shell => self.shell)
    end
    
  private

    def help_check
      help self.class.send(:retrieve_task_name, ARGV.dup)
      exit 0
    end
  end
end

require "middleman/cli/init"
require "middleman/cli/server"
require "middleman/cli/build"