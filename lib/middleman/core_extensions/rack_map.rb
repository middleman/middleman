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
    def build(*args, &bk)
      builder = ::Rack::Builder.new
      builder.use ::Sinatra::ShowExceptions       if show_exceptions?
      builder.use ::Rack::CommonLogger   if logging?
      builder.use ::Rack::Head
      middleware.each { |c,a,b| builder.use(c, *a, &b) }
      maps.each { |p,b| builder.map(p, &b) }
      app = self
      builder.map "/" do
        run app.new!(*args, &bk)
      end
      builder
    end
  end
end