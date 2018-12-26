require 'hamster'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'

module Middleman
  module Dependencies
    class DataCollectionVertex < Vertex
      include Contracts

      TYPE_ID = :data_collection

      DATA_TYPE = Or[Hash, Array]

      Contract Maybe[DATA_TYPE]
      attr_accessor :data

      Contract IsA['::Middleman::Application'], Symbol, Vertex::VERTEX_ATTRS => DataCollectionVertex
      def self.deserialize(_app, key, attributes)
        DataCollectionVertex.new(key, attributes)
      end

      Contract Symbol, DATA_TYPE => DataCollectionVertex
      def self.from_data(key, data)
        DataCollectionVertex.new(key, {}, data)
      end

      Contract Symbol, Vertex::VERTEX_ATTRS, Maybe[DATA_TYPE] => Any
      def initialize(key, attributes, data = nil)
        super(key, attributes)

        @data = data
      end

      Contract Bool
      def valid?
        current_hash == previous_hash
      end

      Contract DataCollectionVertex => Any
      def merge!(other)
        super
        @data = other.data if @data.nil?
      end

      Contract Vertex::SERIALIZED_VERTEX
      def serialize
        super({
          hash: current_hash || previous_hash
        })
      end

      protected

      Contract Maybe[String]
      def current_hash
        return nil if @data.nil?

        @current_hash ||= ::Middleman::Util.hash_string(@data.to_s)
      end

      Contract Maybe[String]
      def previous_hash
        @attributes[:hash]
      end
    end
  end
end
