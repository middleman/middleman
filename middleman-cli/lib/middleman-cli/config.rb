# CLI Module
module Middleman::Cli
  # The CLI Config class
  class Config < Thor::Group
    include Thor::Actions

    check_unknown_options!

    class_option :environment,
                 aliases: '-e',
                 default: ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development',
                 desc: 'The environment Middleman will run under'
    def console
      require 'json'
      require 'middleman-core'
      require 'middleman-core/logger'

      opts = {
        environment: options['environment']
      }

      # Don't output info messages
      ::Middleman::Logger.singleton(2, false)

      app = ::Middleman::Application.new do
        config[:mode] = :config
        config[:disable_sitemap] = true
        config[:watcher_disable] = true
        config[:exit_before_ready] = true
        config[:environment] = opts[:environment].to_sym if opts[:environment]
      end

      puts JSON.pretty_generate(app.config.to_h)

      app.shutdown!
    end

    # Add to CLI
    Base.register(self, 'config', 'config [options]', 'Output a Middleman configuration in JSON format')
  end
end
