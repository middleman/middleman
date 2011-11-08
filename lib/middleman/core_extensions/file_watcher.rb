module Middleman::CoreExtensions::FileWatcher
  class << self
    def registered(app)
      app.extend ClassMethods
    end
    alias :included :registered
  end
  
  module ClassMethods
    def file_did_change(path)
      @run_after_file_change ||= []
      @run_after_file_change.each { |block| block.call(path) }
    end
    
    def on_file_change(&block)
      @run_after_file_change ||= []
      @run_after_file_change << block
    end
    
    def file_did_delete(path)
      @run_after_file_delete ||= []
      @run_after_file_delete.each { |block| block.call(path) }
    end
    
    def on_file_delete(&block)
      @run_after_file_delete ||= []
      @run_after_file_delete << block
    end
  end
end