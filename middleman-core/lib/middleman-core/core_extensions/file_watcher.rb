require "pathname"
require "set"

# API for watching file change events
module Middleman
  module CoreExtensions
    module FileWatcher
  
      IGNORE_LIST = [
        /^\.bundle\//,
        /^\.sass-cache\//,
        /^\.git\//,
        /^\.gitignore$/,
        /^\.DS_Store$/,
        /^build\//,
        /^\.rbenv-.*$/,
        /^Gemfile$/,
        /^Gemfile\.lock$/,
        /~$/,
        /(^|\/)\.?#/
      ]

      # Setup extension
      class << self
    
        # Once registered
        def registered(app)
          app.send :include, InstanceMethods
      
          # Before parsing config, load the data/ directory
          app.before_configuration do
            files.reload_path(root_path + data_dir)
          end
      
          # After config, load everything else
          app.ready do
            files.reload_path(root_path)
          end
        end
        alias :included :registered
      end
  
      # Instance methods
      module InstanceMethods
    
        # Access the file api
        # @return [Middleman::CoreExtensions::FileWatcher::API]
        def files
          @_files_api ||= API.new(self)
        end
      end
  
      # Core File Change API class
      class API
        
        attr_reader :app
        delegate :logger, :to => :app
        
        # Initialize api and internal path cache
        def initialize(app)
          @app = app
          @known_paths = Set.new
          
          @_changed = []
          @_deleted = []
        end
    
        # Add callback to be run on file change
        #
        # @param [nil,Regexp] matcher A Regexp to match the change path against
        # @return [Array<Proc>]
        def changed(matcher=nil, &block)
          @_changed << [block, matcher] if block_given?
          @_changed
        end
    
        # Add callback to be run on file deletion
        #
        # @param [nil,Regexp] matcher A Regexp to match the deleted path against
        # @return [Array<Proc>]
        def deleted(matcher=nil, &block)
          @_deleted << [block, matcher] if block_given?
          @_deleted
        end
  
        # Notify callbacks that a file changed
        #
        # @param [Pathname] path The file that changed
        # @return [void]
        def did_change(path)
          return if ignored?(path)
          logger.debug "== File Change: #{path.relative_path_from(@app.root_path)}"
          @known_paths << path
          self.run_callbacks(path, :changed)
        end

        # Notify callbacks that a file was deleted
        #
        # @param [Pathname] path The file that was deleted
        # @return [void]
        def did_delete(path)
          return if ignored?(path)
          logger.debug "== File Deletion: #{path.relative_path_from(@app.root_path)}"
          @known_paths.delete(path)
          self.run_callbacks(path, :deleted)
        end
    
        # Manually trigger update events
        #
        # @param [Pathname] path The path to reload
        # @param [Boolean] only_new Whether we only look for new files
        # @return [void]
        def reload_path(path, only_new=false)
          return unless path.exist?
          
          glob = "#{path}**/*"
          subset = @known_paths.select { |p| p.fnmatch(glob) }
          
          ::Middleman::Util.all_files_under(path).each do |filepath|
            full_path = path + filepath
            
            if only_new
              next if subset.include?(full_path)
            else
              subset.delete(full_path)
            end
            
            self.did_change(full_path)
          end
          
          subset.each(&method(:did_delete)) unless only_new
        end

        # Like reload_path, but only triggers events on new files
        #
        # @param [Pathname] path The path to reload
        # @return [void]
        def find_new_files(path)
          reload_path(path, true)
        end
    
      protected
        # Whether this path is ignored
        # @param [Pathname] path
        # @return [Boolean]
        def ignored?(path)
          path = path.relative_path_from(@app.root_path).to_s if path.is_a? Pathname
          IGNORE_LIST.any? { |r| path.to_s.match(r) }
        end
      
        # Notify callbacks for a file given an array of callbacks
        #
        # @param [Pathname] path The file that was changed
        # @param [Symbol] callbacks_name The name of the callbacks method
        # @return [void]
        def run_callbacks(path, callbacks_name)
          path = path.relative_path_from(@app.root_path).to_s if path.is_a? Pathname
          self.send(callbacks_name).each do |callback, matcher|
            next if path.match(%r{^#{@app.build_dir}/})
            next unless matcher.nil? || path.match(matcher)
            @app.instance_exec(path, &callback)
          end
        end
      end
    end
  end
end
