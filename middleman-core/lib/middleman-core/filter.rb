require 'middleman-core/contracts'

module Middleman
  class Filter
    include Contracts
    include Comparable

    Contract Symbol
    attr_reader :filter_name

    Contract Maybe[Symbol]
    attr_reader :after_filter

    def <=>(other)
      shift = if other.after_filter.nil?
                0
              elsif filter_name == other.after_filter
                1
              else
                -1
              end

      [0, object_id] <=> [shift, other.object_id]
    end

    Contract Symbol, Hash => Any
    def initialize(filter_name, options_hash = ::Middleman::EMPTY_HASH)
      @filter_name = filter_name

      @options = options_hash
      @after_filter = @options.fetch(:after_filter, nil)
    end

    Contract String => String
    def execute_filter(_body)
      raise NotImplementedError
    end
  end

  class ProcFilter < Filter
    Contract Symbol, RespondTo[:call], Hash => Any
    def initialize(filter_name, callable, options_hash = ::Middleman::EMPTY_HASH)
      super(filter_name, options_hash)

      @callable = callable
    end

    Contract String => [String, Maybe[SetOf[String]]]
    def execute_filter(body)
      result = @callable.call(body)
      result.is_a?(Array) ? result : [result, nil]
    end
  end
end
