module Middleman::CoreExtensions::Builder
  class << self
    def registered(app)
      app.extend ClassMethods
    end
  end
  
  module ClassMethods
    # Add a block/proc to be run after features have been setup
    def after_build(&block)
      @run_after_build ||= []
      @run_after_build << block
    end

    def after_build_callbacks
      @run_after_build ||= []
      @run_after_build
    end
    
    def build_reroute(&block)
      @build_rerouters ||= []
      @build_rerouters << block
    end
    
    def reroute_builder(desination, request_path)
      @build_rerouters ||= []
      
      result = [desination, request_path]
      
      @build_rerouters.each do |block|
        output = block.call(desination, request_path)
        if output
          result = output
          break
        end
      end
      
      result
    end
  end
end