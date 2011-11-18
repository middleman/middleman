module Middleman::CoreExtensions::Builder
  class << self
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
    end
  end
  
  module ClassMethods
    # Add a block/proc to be run after features have been setup
    def after_build(&block)
      ::Middleman::Builder.after_build(&block)
    end
    
    def build_reroute(&block)
      @build_rerouters ||= []
      @build_rerouters << block if block_given?
      @build_rerouters
    end
  end
  
  module InstanceMethods
    def after_build(&block)
      self.class.after_build(&block)
    end
    
    def build_reroute(&block)
      self.class.build_reroute(&block)
    end
    
    def reroute_builder(desination, request_path)
      result = [desination, request_path]
      
      build_reroute.each do |block|
        output = instance_exec(desination, request_path, &block)
        if output
          result = output
          break
        end
      end
      
      result
    end
  end
end