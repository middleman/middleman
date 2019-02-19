require 'hamster'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'
require 'middleman-core/core_extensions/data/controller'

module Middleman
  module Dependencies
    class DataCollectionPathVertex < Vertex
      include Contracts

      TYPE_ID = :data_path

      DATA_TYPE = Or[Num, String, Symbol, Hash, Array]

      Contract IsA['::Middleman::Application'], Symbol, Vertex::SERIALIZED_VERTEX_ATTRS => DataCollectionPathVertex
      def self.deserialize(app, key, attributes)
        DataCollectionPathVertex.new(key, attributes.symbolize_keys, app.data)
      end

      Contract IsA['::Middleman::Application'], ArrayOf[Or[Symbol, Num]] => DataCollectionPathVertex
      def self.from_data(app, path)
        DataCollectionPathVertex.new(path.map(&:to_s).join('.').to_sym, {}, app.data)
      end

      Contract Symbol, Vertex::VERTEX_ATTRS, ::Middleman::CoreExtensions::Data::DataStoreController => Any
      def initialize(key, attributes, controller = nil)
        super(key, attributes)

        @controller = controller
      end

      Contract Bool
      def valid?
        current_hash == previous_hash
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
        @current_hash ||= begin
          data = lookup_path(key_to_path)
          ::Middleman::Util.hash_string(data.to_s)
        end
      end

      Contract Maybe[String]
      def previous_hash
        @attributes[:hash]
      end

      Contract ArrayOf[Or[Symbol, Num]] => Maybe[DataCollectionPathVertex::DATA_TYPE]
      def lookup_path(path)
        path.reduce(@controller) do |sum, part|
          part == :__full_access__ ? sum : sum[part]
        end
      end

      Contract ArrayOf[Or[Symbol, Num]]
      def key_to_path
        @key.to_s.split('.').map do |part|
          begin
            Integer(part)
          rescue StandardError
            part.to_sym
          end
        end
      end
    end
  end
end
