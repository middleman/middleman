# Convenience methods to allow config.rb to talk to the Builder
module Middleman::CoreExtensions::Builder
  
  # Extension registered
  class << self
    # @private
    def registered(app)
      app.define_hook :after_build
    end
    alias :included :registered
  end
end
