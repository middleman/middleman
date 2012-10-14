# Simple extension to manage Ruby encodings
module Middleman::CoreExtensions::RubyEncoding

  # Setup extension
  class << self

    # Once registerd
    def registered(app)
      # Default string encoding for templates and output.
      # @return [String]
      app.config.define_setting :encoding,    "utf-8", 'Default string encoding for templates and output'

      app.send :include, InstanceMethods
    end

    alias :included :registered
  end

  module InstanceMethods
    def initialize
      if Object.const_defined?(:Encoding)
        Encoding.default_internal = config[:encoding]
        Encoding.default_external = config[:encoding]
      end

      super
    end
  end
end
