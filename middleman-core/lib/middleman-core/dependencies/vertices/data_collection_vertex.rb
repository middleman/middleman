require 'hamster'
require 'digest/sha1'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'

module Middleman
  module Dependencies
    class DataCollectionVertex < Vertex
      include Contracts

      TYPE_ID = :data_collection

      Contract Maybe[Or[Hash, Array]]
      attr_accessor :data

      Contract IsA['::Middleman::Application'], Symbol, Vertex::VERTEX_ATTRS => DataCollectionVertex
      def self.deserialize(_app, key, attributes)
        DataCollectionVertex.new(key, attributes)
      end

      Contract Symbol, Or[Hash, Array] => DataCollectionVertex
      def self.from_data(key, data)
        DataCollectionVertex.new(key, {}, data)
      end

      Contract Symbol, Vertex::VERTEX_ATTRS, Maybe[Or[Hash, Array]] => Any
      def initialize(key, attributes, data = nil)
        super(key, attributes)

        @data = data
      end

      Contract Bool
      def valid?
        current_hash == previous_hash
      end

      Contract DataCollectionVertex => DataCollectionVertex
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

      private

      Contract Maybe[Num]
      def current_hash
        return nil if @data.nil?

        @current_hash ||= ::Digest::SHA1.hexdigest(@data.to_s)
      end

      Contract Maybe[String]
      def previous_hash
        @attributes[:hash]
      end
    end
  end
end
