# frozen_string_literal: true

if ENV['CONTRACTS'] == 'true' || ENV['TEST'] == 'true'
  require 'contracts'
  require 'hamster'

  module Contracts
    class IsA
      def self.[](val)
        @lookup ||= {}
        @lookup[val] ||= new(val)
      end

      def initialize(val)
        @val = val
      end

      def valid?(val)
        val.is_a? @val.constantize
      end
    end

    VectorOf = Contracts::CollectionOf::Factory.new(::Hamster::Vector)

    class ImmutableHashOf < Contracts::CallableClass
      INVALID_KEY_VALUE_PAIR = 'You should provide only one key-value pair to HashOf contract'

      def initialize(key, value)
        @key   = key
        @value = value
      end

      def valid?(hash)
        return false unless hash.is_a?(::Hamster::Hash)

        keys_match = hash.keys.map { |k| Contract.valid?(k, @key) }.all?
        vals_match = hash.values.map { |v| Contract.valid?(v, @value) }.all?

        [keys_match, vals_match].all?
      end

      def to_s
        "ImmutableHash<#{@key}, #{@value}>"
      end
    end

    ImmutableSetOf = Contracts::CollectionOf::Factory.new(::Hamster::Set)
    OldResourceList = Contracts::ArrayOf[IsA['Middleman::Sitemap::Resource']]
    ResourceList = Contracts::Or[SetOf[IsA['Middleman::Sitemap::Resource']], SetOf[IsA['Middleman::Sitemap::Resource']], Contracts::ArrayOf[IsA['Middleman::Sitemap::Resource']]]
  end
else
  module Contracts
    def self.included(base)
      base.extend self
    end

    # rubocop:disable Naming/MethodName
    def Contract(*); end
    # rubocop:enable Naming/MethodName

    class Callable
      def self.[](*); end
    end

    class Bool
    end

    class Num
    end

    class Pos
    end

    class Neg
    end

    class Any
    end

    class None
    end

    class Or < Callable
    end

    class Xor < Callable
    end

    class And < Callable
    end

    class Not < Callable
    end

    class RespondTo < Callable
    end

    class Send < Callable
    end

    class Exactly < Callable
    end

    class ArrayOf < Callable
    end

    class ResourceList < Callable
    end

    class OldResourceList < Callable
    end

    class Args < Callable
    end

    class HashOf < Callable
    end

    class Bool
    end

    class Maybe < Callable
    end

    class IsA < Callable
    end

    class SetOf < Callable
    end

    class Frozen < Callable
    end

    class VectorOf < Callable
    end

    class ImmutableHashOf < Callable
    end

    class ImmutableSetOf < Callable
    end
  end
end

module Contracts
  PATH_MATCHER = Or[String, RespondTo[:match], RespondTo[:call], RespondTo[:to_s]]
end
