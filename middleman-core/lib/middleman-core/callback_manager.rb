require 'hamster'
require 'middleman-core/contracts'

# Immutable Callback Management, complete with Contracts validation.
module Middleman
  class CallbackManager
    include Contracts

    Contract Any
    def initialize
      @callbacks = ::Hamster::Hash.empty
      @subscribers = ::Hamster::Vector.empty
    end

    Contract RespondTo[:define_singleton_method], ArrayOf[Symbol] => Any
    def install_methods!(install_target, names)
      manager = self

      names.each do |method_name|
        install_target.define_singleton_method(method_name) do |*keys, &b|
          key_set = keys.unshift(method_name)
          manager.add(key_set.length > 1 ? key_set : key_set[0], &b)
        end
      end

      install_target.define_singleton_method(:execute_callbacks) do |*args|
        keys = args.shift
        manager.execute(keys, args[0], self)
      end

      install_target.define_singleton_method(:callbacks_for, &method(:callbacks_for))
      install_target.define_singleton_method(:subscribe_to_callbacks, &method(:subscribe))
    end

    Contract Or[Symbol, ArrayOf[Symbol]], Proc => Any
    def add(keys, &block)
      immutable_keys = keys.is_a?(Symbol) ? keys : ::Hamster::Vector.new(keys)

      @callbacks = @callbacks.put(immutable_keys) do |v|
        v.nil? ? ::Hamster::Vector.new([block]) : v.push(block)
      end
    end

    Contract Proc => Any
    def subscribe(&block)
      @subscribers = @subscribers.push(block)
    end

    Contract Or[Symbol, ArrayOf[Symbol]], Maybe[ArrayOf[Any]], Maybe[RespondTo[:instance_exec]] => Any
    def execute(keys, args=[], scope=self)
      callbacks = callbacks_for(keys)
      callbacks_count = callbacks.length + @subscribers.length

      return if callbacks_count < 1

      # ::Middleman::Util.instrument "callbacks.execute", keys: keys, length: callbacks_count do
      callbacks.each { |b| scope.instance_exec(*args, &b) }
      @subscribers.each { |b| scope.instance_exec(keys, args, &b) }
      # end
    end

    Contract Or[Symbol, ArrayOf[Symbol]] => ::Hamster::Vector
    def callbacks_for(keys)
      immutable_keys = keys.is_a?(Symbol) ? keys : ::Hamster::Vector.new(keys)
      @callbacks.get(immutable_keys) || ::Hamster::Vector.empty
    end
  end
end
