if ENV['CONTRACTS'] != 'false'
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
    ResourceList = Contracts::ArrayOf[IsA['Middleman::Sitemap::Resource']]
  end
else
  module Contracts
    def self.included(base)
      base.extend self
    end

    # rubocop:disable MethodName
    def Contract(*); end

    class Callable
      def self.[](*)
      end
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
  end
end

module Contracts
  PATH_MATCHER = Or[String, RespondTo[:match], RespondTo[:call], RespondTo[:to_s]]
end
