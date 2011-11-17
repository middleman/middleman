module Middleman::CoreExtensions::FileWatcher
  class << self
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module ClassMethods
    def file_changed(matcher=nil, &block)
      @_file_changed ||= []
      @_file_changed << [block, matcher] if block_given?
      @_file_changed
    end
    
    def file_deleted(matcher=nil, &block)
      @_file_deleted ||= []
      @_file_deleted << [block, matcher] if block_given?
      @_file_deleted
    end
  end
  
  module InstanceMethods
    def file_did_change(path)
      settings.file_changed.each do |callback, matcher|
        next unless matcher.nil? || path.match(matcher)
        settings.instance_exec(path, &callback)
      end
    end
    
    def file_did_delete(path)
      settings.file_deleted.each do |callback, matcher|
        next unless matcher.nil? || path.match(matcher)
        settings.instance_exec(path, &callback)
      end
    end
  end
end