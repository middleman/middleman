# CLI Module
module Middleman::Cli

  # A thor task for creating new projects
  class Console < Thor
    include Thor::Actions

    check_unknown_options!

    namespace :console
    
    desc "console [options]", "Start an interactive console in the context of your Middleman application"
    method_option :environment,
      :aliases => "-e",
      :default => ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development',
      :desc    => "The environment Middleman will run under"
    method_option :verbose,
      :type    => :boolean,
      :default => false,
      :desc    => 'Print debug messages'
    def console
      require "middleman-core"
      require "irb"

      opts = {
        :environment => options['environment'],
        :debug => options['verbose']
      }

      @app =::Middleman::Application.server.inst do
        if opts[:environment]
          set :environment, opts[:environment].to_sym
        end

        logger(opts[:debug] ? 0 : 1, opts[:instrumenting] || false)
      end

      # TODO: get file watcher / reload! working in console

      IRB.setup nil
      IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context
      require 'irb/ext/multi-irb'
      IRB.irb nil, @app
    end
  end
end
