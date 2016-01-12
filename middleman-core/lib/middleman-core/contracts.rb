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

  VectorOf = ::Contracts::CollectionOf::Factory.new(::Hamster::Vector)
  ResourceList = ::Contracts::ArrayOf[IsA['Middleman::Sitemap::Resource']]
  PATH_MATCHER = Or[String, RespondTo[:match], RespondTo[:call], RespondTo[:to_s]]
end
