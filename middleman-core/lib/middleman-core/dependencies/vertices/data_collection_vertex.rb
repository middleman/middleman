require 'hamster'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'

module Middleman
  module Dependencies
    class DataCollectionVertex < Vertex
      include Contracts

      TYPE_ID = :data_collection

      Contract IsA['::Middleman::Application'], String, Vertex::VERTEX_ATTRS => DataCollectionVertex
      def self.deserialize(_app, key, attributes)
        DataCollectionVertex.new(key, attributes)
      end

      Contract Symbol, Or[Hash, Array] => DataCollectionVertex
      def self.from_data(key, data)
        DataCollectionVertex.new(key, {}, data)
      end

      Contract Symbol, Vertex::VERTEX_ATTRS, Or[Hash, Array] => Any
      def initialize(key, attributes, data)
        super(key, attributes)
      end

      Contract Bool
      def valid?
        @current_hash.nil? || @current_hash == previous_hash
      end

      Contract Vertex::SERIALIZED_VERTEX
      def serialize
        super({
          hash: @current_hash
        })
      end

      private

      Contract Bool
      def current_hash
        return nil if @data.nil?

        @current_hash ||= if data.is_a?(Array)
          ::Hamster::Vector.new(data).hash
        elsif data.is_a?(Hash)
          ::Hamster::Hash.new(data).hash
        else
          raise "Invalid data type"
        end
      end

      Contract Maybe[String]
      def previous_hash
        @attributes[:hash]
      end
    end
  end
end
