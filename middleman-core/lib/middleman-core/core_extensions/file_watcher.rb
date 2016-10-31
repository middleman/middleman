require 'middleman-core/contracts'
require 'middleman-core/sources'

module Middleman
  module CoreExtensions
    # API for watching file change events
    class FileWatcher < Extension
      # All defined sources.
      Contract IsA['Middleman::Sources']
      attr_reader :sources

      # Make the internal `sources` method available as `app.files`
      expose_to_application files: :sources

      # Make the internal `sources` method available in config as `files`
      expose_to_config files: :sources

      # The default list of ignores.
      IGNORES = {
        emacs_files: /(^|\/)\.?#/,
        tilde_files: /~$/,
        ds_store: /\.DS_Store$/,
        git: /(^|\/)\.git(ignore|modules|\/)/
      }.freeze

      # Setup the extension.
      def initialize(app, config={}, &block)
        super

        # Setup source collection.
        @sources = ::Middleman::Sources.new(app)

        # Add default ignores.
        IGNORES.each do |key, value|
          @sources.ignore key, :all, value
        end

        # Watch current source.
        start_watching(app.config[:source])
      end

      # Before we config, find initial files.
      #
      # @return [void]
      Contract Any
      def before_configuration
        @sources.poll_once!
      end

      # After we config, find new files since config can change paths.
      #
      # @return [void]
      Contract Any
      def after_configuration
        @watcher.update_config(
          disable_watcher: app.config[:watcher_disable],
          force_polling: app.config[:watcher_force_polling],
          latency: app.config[:watcher_latency],
          wait_for_delay: app.config[:watcher_wait_for_delay]
        )

        if @original_source_dir != app.config[:source]
          @watcher.update_path(app.config[:source])
        end

        @sources.start!
        @sources.poll_once!
      end

      protected

      # Watch the source directory.
      #
      # @return [void]
      Contract String => Any
      def start_watching(dir)
        @original_source_dir = dir
        @watcher = @sources.watch :source, path: File.join(app.root, dir)
      end
    end
  end
end
