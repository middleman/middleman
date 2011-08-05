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
  end
end