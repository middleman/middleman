if ENV['TEST'] || ENV['CONTRACTS'] == 'true'
  require 'contracts'

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

    class Frozen < CallableClass
      def initialize(contract)
        @contract = contract
      end

      def valid?(val)
        (val.frozen? || val.nil? || [::TrueClass, ::FalseClass, ::Fixnum].include?(val.class)) && Contract.valid?(val, @contract)
      end
    end

    class ArrayOf
      def initialize(contract)
        @contract = contract.is_a?(String) ? IsA[contract] : contract
      end
    end

    class SetOf < CallableClass
      def initialize(contract)
        @contract = contract.is_a?(String) ? IsA[contract] : contract
      end

      def valid?(vals)
        return false unless vals.is_a?(Set)
        vals.all? do |val|
          res, _ = Contract.valid?(val, @contract)
          res
        end
      end

      def to_s
        "a set of #{@contract}"
      end

      def testable?
        Testable.testable? @contract
      end

      def test_data
        Set.new([], [Testable.test_data(@contract)], [Testable.test_data(@contract), Testable.test_data(@contract)])
      end
    end

    # class MethodDefined
    #   def self.[](val)
    #     @lookup ||= {}
    #     @lookup[val] ||= new(val)
    #   end

    #   def initialize(val)
    #     @val = val
    #   end

    #   def valid?(val)
    #     val.method_defined? @val
    #   end
    # end

    ResourceList = Contracts::ArrayOf[IsA['Middleman::Sitemap::Resource']]
  end
else
  module Contracts
    def self.included(base)
      base.extend self
    end

    # rubocop:disable MethodName
    def Contract(*)
    end

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

    # class MethodDefined < Callable
    # end
  end
end

module Contracts
  PATH_MATCHER = Or[String, RespondTo[:match], RespondTo[:call], RespondTo[:to_s]]
end
