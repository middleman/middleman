# Convenience methods to allow config.rb to talk to the Builder
module Middleman::CoreExtensions::Builder
  
  # Extension registered
  class << self
    # @private
    def registered(app)
      app.define_hook :after_build
      app.extend ClassMethods
      app.send :include, InstanceMethods
      app.delegate :build_reroute, :to => :"self.class"
    end
    alias :included :registered
  end
  
  # Build Class Methods
  module ClassMethods
    # Get a list of callbacks which can modify a files build path
    # Each callback takes a destination path and a request path and
    # returns a new destination path, or false if it doesn't want to reroute.
    # @return [Array<Proc>]
    def build_reroute(&block)
      @build_rerouters ||= []
      @build_rerouters << block if block_given?
      @build_rerouters
    end
  end
  
  # Build Instance Methods
  module InstanceMethods
    # Run through callbacks and get the new values
    #
    # @param [String] destination The current destination path of the built file
    # @param [String] request_path The request path of the file
    # @return [String] The new destination path
    def reroute_builder(destination, request_path)
      result = [destination, request_path]
      
      build_reroute.each do |block|
        output = block.call(destination, request_path)
        if output
          result = output
          break
        end
      end
      
      result
    end
  end
end
