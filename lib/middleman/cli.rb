require 'thor'
require "thor/group"

# CLI Module
module Middleman::Cli
  
  class Base < Thor
    desc "version", "Show version"
    def version
      require 'middleman/version'
      say "Middleman #{Middleman::VERSION}"
    end
    
    def help(meth = nil, subcommand = false)
      if meth && !self.respond_to?(meth)
        klass, task = Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")
        klass.start(["-h", task].compact, :shell => self.shell)
      else
        list = []
        Thor::Util.thor_classes_in(Middleman::Cli).each do |klass|
          list += klass.printable_tasks(false)
        end
        list.sort!{ |a,b| a[0] <=> b[0] }
        
        shell.say "Tasks:"
        shell.print_table(list, :ident => 2, :truncate => true)
        shell.say
      end
    end
    
    def method_missing(meth, *args)
      meth = meth.to_s
      
      if self.class.map.has_key?(meth)
        meth = self.class.map[meth]
      end
      
      klass, task = Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")
      args.unshift(task) if task
      klass.start(args, :shell => self.shell)
    end
  end
end

require "middleman/cli/init"
require "middleman/cli/server"
require "middleman/cli/build"