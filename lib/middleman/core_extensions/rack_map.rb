module Middleman::CoreExtensions::RackMap
  class << self
    def registered(app)
      app.extend ClassMethods
    end
    alias :included :registered
  end
  
  module ClassMethods
    def map(path, &block)
      @maps ||= []
      @maps << [path, block]
    end
  
    def maps
      @maps || []
    end
  
    # Creates a Rack::Builder instance with all the middleware set up and
    # an instance of this class as end point.
    def build_new(inst=false)
      builder = Rack::Builder.new
      setup_default_middleware builder
      setup_middleware builder
      
      maps.each { |p,b| builder.map(p, &b) }
      app = self
      builder.map "/" do
        run (inst || app.new!)
      end
      
      builder
    end
  end
end