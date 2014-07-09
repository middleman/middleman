if ENV['TEST'] || ENV['CONTRACTS'] == 'true'
  require 'contracts'

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

  ResourceList = Contracts::ArrayOf[IsA['Middleman::Sitemap::Resource']]
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
  end
end
