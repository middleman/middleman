# Require thor since that's what the who CLI is built around
require 'thor'
require 'thor/group'

# CLI Module
module Middleman
  module Cli
    # The base task from which everything else etends
    class Base < Thor
      class << self
        def start(*args)
          # Change flag to a module
          ARGV.unshift('help') if ARGV.delete('--help')

          # Default command is server
          if ARGV[0] != 'help' && (ARGV.length < 1 || ARGV.first.include?('-'))
            ARGV.unshift('server')
          end

          super
        end
      end

      desc 'version', 'Show version'
      def version
        say "Middleman #{Middleman::VERSION}"
      end

      # Override the Thor help method to find help for subtasks
      # @param [Symbol, String, nil] meth
      # @param [Boolean] subcommand
      # @return [void]
      # rubocop:disable UnusedMethodArgument
      def help(meth=nil, subcommand=false)
        if meth && !self.respond_to?(meth)
          klass, task = Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")
          klass.start(['-h', task].compact, shell: shell)
        else
          list = []
          Thor::Util.thor_classes_in(Middleman::Cli).each do |thor_class|
            list += thor_class.printable_tasks(false)
          end
          list.sort! { |a, b| a[0] <=> b[0] }

          shell.say 'Tasks:'
          shell.print_table(list, ident: 2, truncate: true)
          shell.say
        end
      end

      # Intercept missing methods and search subtasks for them
      # @param [Symbol] meth
      def method_missing(meth, *args)
        meth = meth.to_s
        meth = self.class.map[meth] if self.class.map.key?(meth)

        klass, task = Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")

        if klass.nil?
          tasks_dir = File.join(Dir.pwd, 'tasks')

          if File.exist?(tasks_dir)
            Dir[File.join(tasks_dir, '**/*_task.rb')].each { |f| require f }
            klass, task = Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")
          end
        end

        if klass.nil?
          raise Thor::Error, "There's no '#{meth}' command for Middleman. Try 'middleman help' for a list of commands."
        else
          args.unshift(task) if task
          klass.start(args, shell: shell)
        end
      end
    end
  end
end

# Require the Middleman version
require 'middleman-core/version'

# Include the core CLI items
require 'middleman-core/cli/init'
require 'middleman-core/cli/bundler'
require 'middleman-core/cli/extension'
require 'middleman-core/cli/server'
require 'middleman-core/cli/build'
require 'middleman-core/cli/console'
