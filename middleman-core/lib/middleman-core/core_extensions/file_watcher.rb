require 'pathname'
require 'set'
require 'middleman-core/contracts'

module Middleman
  module CoreExtensions
    # API for watching file change events
    class FileWatcher < Extension
      attr_reader :api

      def initialize(app, config={}, &block)
        super
      end

      # Before parsing config, load the data/ directory
      Contract None => Any
      def before_configuration
        @api = API.new(app)
        app.add_to_instance :files, &method(:api)
        app.add_to_config_context :files, &method(:api)
      end

      Contract None => Any
      def after_configuration
        @api.reload_path('.')
        @api.is_ready = true
      end

      # Core File Change API class
      class API
        extend Forwardable
        include Contracts

        attr_reader :app
        attr_reader :known_paths
        attr_accessor :is_ready

        def_delegator :@app, :logger

        # Initialize api and internal path cache
        def initialize(app)
          @app = app
          @known_paths = Set.new
          @is_ready = false

          @watchers = {
            source: proc { |path, _| path.match(/^#{app.config[:source]}\//) },
            library: /^(lib|helpers)\/.*\.rb$/
          }

          @ignores = {
            emacs_files: /(^|\/)\.?#/,
            tilde_files: /~$/,
            ds_store: /\.DS_Store\//,
            git: /(^|\/)\.git(ignore|modules|\/)/
          }

          @on_change_callbacks = Set.new
          @on_delete_callbacks = Set.new
        end

        # Add a proc to watch paths
        Contract Symbol, Or[Regexp, Proc] => Any
        def watch(name, regex=nil, &block)
          @watchers[name] = block_given? ? block : regex

          reload_path('.') if @is_ready
        end

        # Add a proc to ignore paths
        Contract Symbol, Or[Regexp, Proc] => Any
        def ignore(name, regex=nil, &block)
          @ignores[name] = block_given? ? block : regex

          reload_path('.') if @is_ready
        end

        CallbackDescriptor = Struct.new(:proc, :matcher)

        # Add callback to be run on file change
        #
        # @param [nil,Regexp] matcher A Regexp to match the change path against
        # @return [Array<Proc>]
        Contract Or[Regexp, Proc] => SetOf['Middleman::CoreExtensions::FileWatcher::API::CallbackDescriptor']
        def changed(matcher=nil, &block)
          @on_change_callbacks << CallbackDescriptor.new(block, matcher) if block_given?
          @on_change_callbacks
        end

        # Add callback to be run on file deletion
        #
        # @param [nil,Regexp] matcher A Regexp to match the deleted path against
        # @return [Array<Proc>]
        Contract Or[Regexp, Proc] => SetOf['Middleman::CoreExtensions::FileWatcher::API::CallbackDescriptor']
        def deleted(matcher=nil, &block)
          @on_delete_callbacks << CallbackDescriptor.new(block, matcher) if block_given?
          @on_delete_callbacks
        end

        # Notify callbacks that a file changed
        #
        # @param [Pathname] path The file that changed
        # @return [void]
        Contract Or[Pathname, String] => Any
        def did_change(path)
          path = Pathname(path)
          logger.debug "== File Change: #{path}"
          @known_paths << path
          run_callbacks(path, :changed)
        end

        # Notify callbacks that a file was deleted
        #
        # @param [Pathname] path The file that was deleted
        # @return [void]
        Contract Or[Pathname, String] => Any
        def did_delete(path)
          path = Pathname(path)
          logger.debug "== File Deletion: #{path}"
          @known_paths.delete(path)
          run_callbacks(path, :deleted)
        end

        # Manually trigger update events
        #
        # @param [Pathname] path The path to reload
        # @param [Boolean] only_new Whether we only look for new files
        # @return [void]
        Contract Or[String, Pathname], Maybe[Bool] => Any
        def reload_path(path, only_new=false)
          # chdir into the root directory so Pathname can work with relative paths
          Dir.chdir @app.root_path do
            path = Pathname(path)
            return unless path.exist?

            glob = (path + '**').to_s
            subset = @known_paths.select { |p| p.fnmatch(glob) }

            ::Middleman::Util.all_files_under(path, &method(:ignored?)).each do |filepath|
              next if only_new && subset.include?(filepath)

              subset.delete(filepath)
              did_change(filepath)
            end

            subset.each(&method(:did_delete)) unless only_new
          end
        end

        # Like reload_path, but only triggers events on new files
        #
        # @param [Pathname] path The path to reload
        # @return [void]
        Contract Pathname => Any
        def find_new_files(path)
          reload_path(path, true)
        end

        Contract String => Bool
        def exists?(path)
          p = Pathname(path)
          p = p.relative_path_from(Pathname(@app.root)) unless p.relative?
          @known_paths.include?(p)
        end

        # Whether this path is ignored
        # @param [Pathname] path
        # @return [Boolean]
        Contract Or[String, Pathname] => Bool
        def ignored?(path)
          path = path.to_s

          watched = @watchers.values.any? { |validator| matches?(validator, path) }
          not_ignored = @ignores.values.none? { |validator| matches?(validator, path) }

          !(watched && not_ignored)
        end

        Contract Or[Regexp, RespondTo[:call]], String => Bool
        def matches?(validator, path)
          if validator.is_a? Regexp
            !!validator.match(path)
          else
            !!validator.call(path, @app)
          end
        end

        protected

        # Notify callbacks for a file given an array of callbacks
        #
        # @param [Pathname] path The file that was changed
        # @param [Symbol] callbacks_name The name of the callbacks method
        # @return [void]
        Contract Or[Pathname, String], Symbol => Any
        def run_callbacks(path, callbacks_name)
          path = path.to_s
          send(callbacks_name).each do |callback|
            next unless callback[:matcher].nil? || path.match(callback[:matcher])
            @app.instance_exec(path, &callback[:proc])
          end
        end
      end
    end
  end
end
