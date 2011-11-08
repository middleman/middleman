module Middleman::CoreExtensions::FileWatcher
  class << self
    def registered(app)
      app.define_hook :file_changed
      app.define_hook :file_deleted
      
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def file_did_change(path)
      run_hook :file_changed, path
    end
    
    def file_did_delete(path)
      run_hook :file_deleted, path
    end
  end
end