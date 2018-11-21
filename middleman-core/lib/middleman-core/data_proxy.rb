require 'middleman-core/contracts'

module Middleman
  class DataProxy
    def initialize(ctx)
      @ctx = ctx
    end

    def method_missing(method, *args, &block)
      if @ctx.internal_data_store.key?(method)
        @ctx.vertices |= @ctx.internal_data_store.vertices_for_key(method)
        return @ctx.internal_data_store.enhanced_key(method)
      end

      super
    end

    # Needed so that method_missing makes sense
    def respond_to?(method, include_private = false)
      super || @ctx.internal_data_store.key?(method)
    end
  end
end