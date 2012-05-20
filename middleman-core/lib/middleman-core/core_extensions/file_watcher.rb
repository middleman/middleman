require "find"
require "set"

# API for watching file change events
module Middleman
  module CoreExtensions
    module FileWatcher
  
      IGNORE_LIST = [
        /^\.sass-cache\//,
        /^\.git\//,
        /^\.gitignore$/,
        /^\.DS_Store$/,
        /^build\//,
        /^\.rbenv-.*$/,
        /^Gemfile$/,
        /^Gemfile\.lock$/,
        /~$/
      ]

      # Setup extension
      class << self
    
        # Once registered
        def registered(app)
          app.extend ClassMethods
          app.send :include, InstanceMethods
      
          # Before parsing config, load the data/ directory
          app.before_configuration do
            data_path = File.join(root, data_dir)
            files.reload_path(data_path) if File.exists?(data_path)
          end
      
          # After config, load everything else
          app.ready do
            files.reload_path(root)
          end
        end
        alias :included :registered
      end
  
      # Class methods
      module ClassMethods
    
        # Access the file api
        # @return [Middleman::CoreExtensions::FileWatcher::API]
        def files
          @_files_api ||= API.new
        end
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
        # @param [String] path The file that changed
        # @return [void]
        def did_change(path)
          return if IGNORE_LIST.any? { |r| path.match(r) }
          puts "== File Change: #{path}" if @app.logging?
          @known_paths << path
          self.run_callbacks(path, :changed)
        end

        # Notify callbacks that a file was deleted
        #
        # @param [String] path The file that was deleted
        # @return [void]
        def did_delete(path)
          return if IGNORE_LIST.any? { |r| path.match(r) }
          puts "== File Deletion: #{path}" if @app.logging?
          @known_paths.delete(path)
          self.run_callbacks(path, :deleted)
        end
    
        # Manually trigger update events
        #
        # @param [String] path The path to reload
        # @return [void]
        def reload_path(path)
          relative_path = path.sub("#{@app.root}/", "")
          subset = @known_paths.select { |p| p.match(%r{^#{relative_path}}) }
      
          Find.find(path) do |path|
            next if File.directory?(path)
            relative_path = path.sub("#{@app.root}/", "")
            subset.delete(relative_path)
            self.did_change(relative_path)
          end if File.exists?(path)
      
          subset.each do |removed_path|
            self.did_delete(removed_path)
          end
        end

        # Like reload_path, but only triggers events on new files
        #
        # @param [String] path The path to reload
        # @return [void]
        def find_new_files(path)
          relative_path = path.sub("#{@app.root}/", "")
          subset = @known_paths.select { |p| p.match(%r{^#{relative_path}}) }
      
          Find.find(path) do |file|
            next if File.directory?(file)
            relative_path = file.sub("#{@app.root}/", "")
            self.did_change(relative_path) unless subset.include?(relative_path)
          end if File.exists?(path)
        end
    
      protected
        # Notify callbacks for a file given an array of callbacks
        #
        # @param [String] path The file that was changed
        # @param [Symbol] callbacks_name The name of the callbacks method
        # @return [void]
        def run_callbacks(path, callbacks_name)
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
