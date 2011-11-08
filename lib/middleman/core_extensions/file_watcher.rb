module Middleman::CoreExtensions::FileWatcher
  class << self
    def registered(app)
      app.set :run_after_file_change, []
      app.set :run_after_file_delete, []
      
      app.extend ClassMethods
    end
    alias :included :registered
  end
  
  module ClassMethods
    def file_did_change(path)
      settings.run_after_file_change.each { |block| block.call(path) }
    end
    
    def on_file_change(&block)
      settings.run_after_file_change << block
    end
    
    def file_did_delete(path)
      settings.run_after_file_delete.each { |block| block.call(path) }
    end
    
    def on_file_delete(&block)
      settings.run_after_file_delete << block
    end
  end
end