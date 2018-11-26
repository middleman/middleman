require 'middleman-core/contracts'
require 'middleman-core/core_extensions/data/controller'

module Middleman
  module CoreExtensions
    module Data
      # The data extension parses YAML and JSON files in the `data/` directory
      # and makes them available to `config.rb`, templates and extensions
      class DataExtension < Extension
        attr_reader :data_store

        define_setting :data_dir, ENV['MM_DATA_DIR'] || 'data', 'The directory data files are stored in'
        define_setting :track_data_access, false, 'If we should track data accesses'

        # Make the internal `data_store` method available as `app.data`
        expose_to_application data: :data_store

        # Exposes `internal_data_store` to templates, to be wrapped by `data` in the context
        expose_to_template internal_data_store: :data_store

        # The regex which tells Middleman which files are for data
        DATA_FILE_MATCHER = /^(.*?)[\w-]+\.(yml|yaml|json)$/.freeze

        Contract IsA['::Middleman::Application'], Hash => Any
        def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
          super

          @data_store = DataStoreController.new(app, app.config[:track_data_access])

          start_watching(app.config[:data_dir])
        end

        Contract String => Any
        def start_watching(dir)
          @original_data_dir = dir

          # Tell the file watcher to observe the :data_dir
          @watcher = app.files.watch :data,
                                     path: File.expand_path(dir, app.root),
                                     only: DATA_FILE_MATCHER

          # Setup data files before anything else so they are available when
          # parsing config.rb
          app.files.on_change(:data, &@data_store.method(:update_files))
        end

        Contract Any
        def after_configuration
          return unless @original_data_dir != app.config[:data_dir]

          @watcher.update_path(app.config[:data_dir])
        end
      end
    end
  end
end
