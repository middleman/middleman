# CLI Module
module Middleman::Cli

  # Server thor task
  class Server < Thor
    check_unknown_options!

    namespace :server

    desc "server [options]", "Start the preview server"
    method_option :environment,
      :aliases => "-e",
      :default => ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development',
      :desc    => "The environment Middleman will run under"
    method_option :host,
      :type    => :string,
      :aliases => "-h",
      :default => "0.0.0.0",
      :desc    => "Bind to HOST address"
    method_option :port,
      :aliases => "-p",
      :default => "4567",
      :desc    => "The port Middleman will listen on"
    method_option :verbose,
      :type    => :boolean,
      :default => false,
      :desc    => 'Print debug messages'
    method_option :instrument,
      :type    => :string,
      :default => false,
      :desc    => 'Print instrument messages'
    method_option :disable_watcher,
      :type    => :boolean,
      :default => false,
      :desc    => 'Disable the file change and delete watcher process'
    method_option :profile,
      :type    => :boolean,
      :default => false,
      :desc    => 'Generate profiling report for server startup'
    method_option :reload_paths,
      :type    => :string,
      :default => false,
      :desc    => 'Additional paths to auto-reload when files change'
    method_option :force_polling,
      :type    => :boolean,
      :default => false,
      :desc    => 'Force file watcher into polling mode'

    # Start the server
    def server
      require "middleman-core"
      require "middleman-core/preview_server"

      if !ENV["MM_ROOT"]
        puts "== Could not find a Middleman project config.rb"
        puts "== Treating directory as a static site to be served"
        ENV["MM_ROOT"] = Dir.pwd
        ENV["MM_SOURCE"] = ""
      end

      params = {
        :port              => options["port"],
        :host              => options["host"],
        :environment       => options["environment"],
        :debug             => options["verbose"],
        :instrumenting     => options["instrument"],
        :disable_watcher   => options["disable_watcher"],
        :reload_paths      => options["reload_paths"],
        :force_polling     => options["force_polling"]
      }

      puts "== The Middleman is loading"
      ::Middleman::PreviewServer.start(params)
    end
  end

  def self.exit_on_failure?
    true
  end

  # Map "s" to "server"
  Base.map({ "s" => "server" })
end
