require 'hamster'
require 'middleman-core/contracts'
require 'middleman-core/core_extensions/data/proxies/array'
require 'middleman-core/core_extensions/data/proxies/hash'
require 'middleman-core/dependencies/vertices/data_collection_path_vertex'

module Middleman
  class DataProxy
    attr_reader :accessed_keys

    def initialize(ctx)
      @ctx = ctx
      @accessed_keys = ::Hamster::Set.new
    end

    def take_ownership_of_proxies(locs)
      take_ownership_of_hash(locs)
    end

    def take_ownership_of_hash(h)
      h.keys.each_with_object({}) do |key, sum|
        v = h[key]
        sum[key] = take_ownership_of_value(v)
      end
    end

    def take_ownership_of_array(a)
      a.map do |v|
        take_ownership_of_value(v)
      end
    end

    def take_ownership_of_value(v)
      if v.is_a?(::Array)
        take_ownership_of_array(v)
      elsif v.is_a?(::Hash)
        take_ownership_of_hash(v)
      elsif v.is_a?(::Middleman::CoreExtensions::Data::Proxies::ArrayProxy)
        v.clone.tap { |p| p._top._replace_parent(self) }
      elsif v.is_a?(::Middleman::CoreExtensions::Data::Proxies::HashProxy)
        v.clone.tap { |p| p._top._replace_parent(self) }
      else
        v
      end
    end

    def log_access(key)
      return if @accessed_keys.include?(key)

      @accessed_keys <<= key

      @ctx.vertices <<= ::Middleman::Dependencies::DataCollectionPathVertex.from_data(
        @ctx.app,
        key
      )
    end

    def method_missing(method, *args, &block)
      if @ctx.internal_data_store.key?(method)
        return @ctx.internal_data_store.proxied_data(method, self)
      end

      super
    end

    # Needed so that method_missing makes sense
    def respond_to?(method, include_private = false)
      super || @ctx.internal_data_store.key?(method)
    end
  end
end
