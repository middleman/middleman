module Middleman::Renderers::Haml
  class << self
    def registered(app)
      require "haml"
      app.send :include, ::Haml::Helpers
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def initialize
      super
      init_haml_helpers
    end
  end
end