require "find"

# API for watching file change events
module Middleman::CoreExtensions::FileWatcher
  # Setup extension
  class << self
    # @private
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      
      app.delegate :file_changed, :file_deleted, :to => :"self.class"
      
      # Before parsing config, load the data/ directory
      app.before_configuration do
        data_path = File.join(root, data_dir)
        Find.find(data_path) do |path|
          next if File.directory?(path)
          file_did_change(path.sub("#{root}/", ""))
        end if File.exists?(data_path)
      end
      
      # After config, load everything else
      app.ready do
        Find.find(root) do |path|
          next if File.directory?(path)
          file_did_change(path.sub("#{root}/", ""))
        end
      end
    end
    alias :included :registered
  end
  
  # Class methods
  module ClassMethods
    # Add callback to be run on file change
    #
    # @param [nil,Regexp] matcher A Regexp to match the change path against
    # @return [Array<Proc>]
    def file_changed(matcher=nil, &block)
      @_file_changed ||= []
      @_file_changed << [block, matcher] if block_given?
      @_file_changed
    end
    
    # Add callback to be run on file deletion
    #
    # @param [nil,Regexp] matcher A Regexp to match the deleted path against
    # @return [Array<Proc>]
    def file_deleted(matcher=nil, &block)
      @_file_deleted ||= []
      @_file_deleted << [block, matcher] if block_given?
      @_file_deleted
    end
  end
  
  # Instance methods
  module InstanceMethods
    # Notify callbacks that a file changed
    #
    # @param [String] path The file that changed
    # @return [void]
    def file_did_change(path)
      file_changed.each do |callback, matcher|
        next if path.match(%r{^#{build_dir}/})
        next if !matcher.nil? && !path.match(matcher)
        instance_exec(path, &callback)
      end
    end

    # Notify callbacks that a file was deleted
    #
    # @param [String] path The file that was deleted
    # @return [void]
    def file_did_delete(path)
      file_deleted.each do |callback, matcher|
        next if path.match(%r{^#{build_dir}/})
        next unless matcher.nil? || path.match(matcher)
        instance_exec(path, &callback)
      end
    end
  end
end