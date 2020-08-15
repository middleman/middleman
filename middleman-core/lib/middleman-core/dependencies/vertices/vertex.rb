# frozen_string_literal: true

require 'pathname'
require 'middleman-core/contracts'

module Middleman
  module Dependencies
    class Vertex
      include Contracts

      VERTEX_KEY = Symbol
      VERTEX_ATTRS = HashOf[Symbol, String]
      SERIALIZED_VERTEX_ATTRS = HashOf[String, String]
      SERIALIZED_VERTEX = {
        'key' => Any, # Weird type inheritance bug
        'type' => String,
        'attrs' => SERIALIZED_VERTEX_ATTRS
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

      Contract Vertex => Any
      def merge!(other)
        @attributes.merge!(other.attributes)
      end

      Contract IsA['Middleman::Sitemap::Resource'] => Bool
      def matches_resource?(_resource)
        false
      end

      Contract Maybe[VERTEX_ATTRS] => SERIALIZED_VERTEX
      def serialize(attributes = {})
        {
          'key' => @key.to_s,
          'type' => type_id.to_s,
          'attrs' => @attributes.merge(attributes).stringify_keys
        }
      end

      Contract String
      def to_s
        "<Vertex type=#{type_id} key=#{key}>"
      end

      Contract Symbol
      def type_id
        self.class.const_get :TYPE_ID
      end

      protected

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
