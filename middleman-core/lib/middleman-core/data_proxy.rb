require 'hamster'
require 'middleman-core/contracts'

module Middleman
  class DataAccessProxy
    def initialize(key, data, parent)
      @key = key
      @data = data
      @parent = parent
      @accessed_keys = ::Hamster::Set.new
    end

    def method_missing(name, *args, &block)
      log_access(:__full_access__)

      @data.send(name, *args, &block)
    end

    protected

    def log_access(key)
      access_key = [@key, key].flatten
      access_key_vector = ::Hamster::Vector.new(access_key)

      return if @accessed_keys.include?(access_key_vector)

      @accessed_keys <<= access_key_vector

      @parent.log_access(access_key)
    end

    def wrap_data(key, data)
      if data.is_a? ::Hash
        data = ::Hamster::Hash.new(data)
      elsif data.is_a? ::Array
        data = ::Hamster::Vector.new(data)
      end

      if data.is_a? ::Hamster::Hash
        return HashAccessProxy.new(key, data, self)
      elsif data.is_a? ::Hamster::Vector
        return ArrayAccessProxy.new(key, data, self)
      else
        log_access(key)
        data
      end
    end
  end

  class ArrayAccessProxy < DataAccessProxy
    def initialize(key, array, parent)
      super(key, array, parent)
    end

    def fetch(key, default = Undefined, &block)
      # indifferent_key = _data_key(key)

      # unless indifferent_key.nil?
      #   log_access(indifferent_key)
      # end

      # wrap_data indifferent_key, @data.fetch(indifferent_key || key, default, &block)
    end

    def slice(start_index, length = nil)
      if length.nil?
        wrap_data(start_index, @data.slice(start_index))
      else
        log_access(:__full_access__)
        @data.slice(start_index, length)
      end
    end
    alias [] slice
    alias get slice

    def first
      slice(0)
    end

    def last
      slice(@data.size - 1)
    end
  end

  class HashAccessProxy < DataAccessProxy
    def initialize(key, hash, parent)
      super(key, hash, parent)
    end

    def fetch(key, default = Undefined, &block)
      indifferent_key = _data_key(key)
      wrap_data indifferent_key, @data.fetch(indifferent_key || key, default, &block)
    end

    def get(key)
      indifferent_key = _data_key(key)
      wrap_data indifferent_key, @data.get(indifferent_key || key)
    end
    alias [] get

    # Allows data.key.value style access
    def method_missing(name, *args, &block)
      indifferent_key = _data_key(name)

      return get(name) if indifferent_key

      super
    end

    private

    def _data_key(key)
      if @data.key?(key.to_s)
        key.to_s
      elsif @data.key?(key.to_sym)
        key.to_sym
      end
    end
  end

  class DataProxy
    attr_reader :accessed_keys

    def initialize(ctx)
      @ctx = ctx
      @accessed_keys = ::Hamster::Set.new
    end

    def log_access(key)
      @accessed_keys <<= key
    end

    def make_store(key, data)
      wrap_data(key, data, self)
    end

    def wrap_data(key, data, parent)
      if data.is_a? ::Hash
        data = ::Hamster::Hash.new(data)
      elsif data.is_a? ::Array
        data = ::Hamster::Vector.new(data)
      end

      if data.is_a? ::Hamster::Hash
        return HashAccessProxy.new(key, data, parent)
      elsif data.is_a? ::Hamster::Vector
        return ArrayAccessProxy.new(key, data, parent)
      end
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
