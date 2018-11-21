require 'pathname'
require 'middleman-core/contracts'

module Middleman
  module Dependencies
    class Vertex
      include Contracts

      VERTEX_KEY = Symbol
      VERTEX_ATTRS = HashOf[Symbol, Or[String, Num]]
      SERIALIZED_VERTEX = {
        key: Any, # Weird inheritance bug
        type: Symbol,
        attributes: VERTEX_ATTRS
      }.freeze

      Contract VERTEX_KEY
      attr_reader :key

      Contract VERTEX_ATTRS
      attr_reader :attributes

      Contract VERTEX_KEY, VERTEX_ATTRS => Any
      def initialize(key, attributes)
        @key = key
        @attributes = attributes
      end

      Contract Vertex => Bool
      def ==(other)
        key == other.key
      end

      Contract Bool
      def valid?
        raise NotImplementedError
      end

      Contract Vertex => Vertex
      def merge!(other)
        @attributes.merge!(other.attributes)
      end

      Contract IsA['Middleman::Sitemap::Resource'] => Bool
      def invalidates_resource?(_resource)
        false
      end

      Contract Maybe[VERTEX_ATTRS] => SERIALIZED_VERTEX
      def serialize(attributes = {})
        {
          key: @key,
          type: type_id,
          attributes: @attributes.merge(attributes)
        }
      end

      Contract String
      def to_s
        "<Vertex type=#{type_id} key=#{key}>"
      end

      protected

      Contract Symbol
      def type_id
        self.class.const_get :TYPE_ID
      end

      Contract Pathname, String => String
      def relative_path(root, file)
        Pathname(File.expand_path(file)).relative_path_from(root).to_s
      end

      Contract Pathname, String => String
      def full_path(root, file)
        File.expand_path(file, root)
      end
    end
  end
end
