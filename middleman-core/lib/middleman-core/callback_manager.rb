require 'hamster'
require 'middleman-core/contracts'

# Immutable Callback Management, complete with Contracts validation.
module Middleman
  class CallbackManager
    include Contracts

    Contract Any
    def initialize
      @callbacks = ::Hamster.hash
    end

    Contract RespondTo[:define_singleton_method], ArrayOf[Symbol], Maybe[Proc] => Any
    def install_methods!(install_target, names, &block)
      manager = self

      names.each do |name|
        method_name = block_given? ? block.call(name) : name

        install_target.define_singleton_method(method_name) do |*keys, &b|
          key_set = keys.unshift(name)
          manager.add(key_set.length > 1 ? key_set : key_set.first, &b)
        end
      end

      install_target.define_singleton_method(:execute_callbacks) do |keys, *args|
        manager.execute(keys, args, self)
      end
    end

    Contract Or[Symbol, ArrayOf[Symbol]], Proc => Any
    def add(keys, &block)
      immutable_keys = keys.is_a?(Symbol) ? keys : ::Hamster::Vector.new(keys)

      @callbacks = @callbacks.put(immutable_keys) do |v|
        v.nil? ? ::Hamster.set(block) : v.add(block)
      end
    end

    Contract Or[Symbol, ArrayOf[Symbol]], Maybe[ArrayOf[Any]], Maybe[RespondTo[:instance_exec]] => Any
    def execute(keys, args=[], scope=self)
      immutable_keys = keys.is_a?(Symbol) ? keys : ::Hamster::Vector.new(keys)

      callbacks = @callbacks.get(immutable_keys)
      callbacks && callbacks.each { |b| scope.instance_exec(*args, &b) }
    end
  end
end
