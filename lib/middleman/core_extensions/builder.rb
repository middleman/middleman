module Middleman::CoreExtensions::Builder
  class << self
    def registered(app)
      app.define_hook :after_build
      app.extend ClassMethods
      app.send :include, InstanceMethods
    end
  end
  
  module ClassMethods
    def build_reroute(&block)
      @build_rerouters ||= []
      @build_rerouters << block if block_given?
      @build_rerouters
    end
  end
  
  module InstanceMethods
    def build_reroute(&block)
      self.class.build_reroute(&block)
    end
    
    def reroute_builder(destination, request_path)
      result = [destination, request_path]
      
      build_reroute.each do |block|
        output = instance_exec(destination, request_path, &block)
        if output
          result = output
          break
        end
      end
      
      result
    end
  end
end
