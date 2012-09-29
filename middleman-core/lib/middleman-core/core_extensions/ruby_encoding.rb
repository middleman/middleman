# Simple extension to manage Ruby encodings
module Middleman::CoreExtensions::RubyEncoding

  # Setup extension
  class << self

    # Once registerd
    def registered(app)
      app.send :include, InstanceMethods
    end

    alias :included :registered
  end

  module InstanceMethods
    def initialize
      if Object.const_defined?(:Encoding)
        Encoding.default_internal = encoding
        Encoding.default_external = encoding
      end

      super
    end
  end
end
