require 'forwardable'

module Middleman
  class Pipeline
    extend Forwardable
    attr_reader :filters
    attr_reader :resource

    def_delegators :filters, :<<, :push, :unshift, :insert, :shift, :pop, :first, :clear

    def initialize(resource)
      @resource = resource
      @filters = []
    end

    def render(*args)
      process resource.render *args
    end

    def process(body)
      filters.inject(body){ |body, app| app.call(body) }
    end
  end
end
