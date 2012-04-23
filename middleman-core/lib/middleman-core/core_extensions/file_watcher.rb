require "find"
require "middleman-core/watcher"
require "set"

# API for watching file change events
module Middleman::CoreExtensions::FileWatcher
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      
      # Before parsing config, load the data/ directory
      app.before_configuration do
        data_path = File.join(self.root, self.data_dir)
        self.files.reload_path(data_path) if File.exists?(data_path)
      end
      
      # After config, load everything else
      app.ready do
        self.files.reload_path(self.root)
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
      api = self.class.files
      api.instance ||= self
      api
    end
  end
  
  # Core File Change API class
  class API
    attr_accessor :instance, :known_paths
    
    # Initialize api and internal path cache
    def initialize
      self.known_paths = Set.new
    end
    
    # Add callback to be run on file change
    #
    # @param [nil,Regexp] matcher A Regexp to match the change path against
    # @return [Array<Proc>]
    def changed(matcher=nil, &block)
      @_changed ||= []
      @_changed << [block, matcher] if block_given?
      @_changed
    end
    
    # Add callback to be run on file deletion
    #
    # @param [nil,Regexp] matcher A Regexp to match the deleted path against
    # @return [Array<Proc>]
    def deleted(matcher=nil, &block)
      @_deleted ||= []
      @_deleted << [block, matcher] if block_given?
      @_deleted
    end
  
    # Notify callbacks that a file changed
    #
    # @param [String] path The file that changed
    # @return [void]
    def did_change(path)
      puts "== File Change: #{path}" if instance.logging? && !::Middleman::Watcher.ignore_list.any? { |r| path.match(r) }
      self.known_paths << path
      self.run_callbacks(path, :changed)
    end

    # Notify callbacks that a file was deleted
    #
    # @param [String] path The file that was deleted
    # @return [void]
    def did_delete(path)
      puts "== File Deletion: #{path}" if instance.logging? && !::Middleman::Watcher.ignore_list.any? { |r| path.match(r) }
      self.known_paths.delete(path)
      self.run_callbacks(path, :deleted)
    end
    
    # Manually trigger update events
    #
    # @param [String] path The path to reload
    # @return [void]
    def reload_path(path)
      relative_path = path.sub("#{self.instance.root}/", "")
      subset = self.known_paths.select { |p| p.match(%r{^#{relative_path}}) }
      
      Find.find(path) do |path|
        next if File.directory?(path)
        next if Middleman::Watcher.ignore_list.any? { |r| path.match(r) }
        relative_path = path.sub("#{self.instance.root}/", "")
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
      relative_path = path.sub("#{self.instance.root}/", "")
      subset = self.known_paths.select { |p| p.match(%r{^#{relative_path}}) }
      
      Find.find(path) do |file|
        next if File.directory?(file)
        next if Middleman::Watcher.ignore_list.any? { |r| path.match(r) }
        relative_path = file.sub("#{self.instance.root}/", "")
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
      return if ::Middleman::Watcher.ignore_list.any? { |r| path.match(r) }

      self.send(callbacks_name).each do |callback, matcher|
        next if path.match(%r{^#{self.instance.build_dir}/})
        next unless matcher.nil? || path.match(matcher)
        self.instance.instance_exec(path, &callback)
      end
    end
  end
end
