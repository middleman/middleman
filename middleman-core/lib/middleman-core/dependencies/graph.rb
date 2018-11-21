require 'set'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'
require 'middleman-core/dependencies/edge'

module Middleman
  module Dependencies
    class Graph
      include Contracts

      Contract HashOf[Vertex::VERTEX_KEY, Vertex]
      attr_reader :vertices

      Contract ImmutableHashOf[Vertex, ImmutableSetOf[Vertex]]
      attr_accessor :dependency_map

      def initialize(vertices = {})
        @vertices = vertices
        @dependency_map = ::Hamster::Hash.empty
      end

      Contract Vertex => Vertex
      def merged_vertex_or_new(v)
        if @vertices[v.key]
          @vertices[v.key].merge!(v)
        else
          @vertices[v.key] = v
        end

        @vertices[v.key]
      end

      Contract Edge => Any
      def add_edge(edge)
        deduped_vertex = merged_vertex_or_new edge.vertex

        # FIXME
        # Depending on yourself (<< deduped_vertex)
        # is only useful for files in source/ that can be depended on and also
        # be their own route
        @dependency_map = @dependency_map.put(deduped_vertex) do |v|
          (v || ::Hamster::Set.empty) << deduped_vertex
        end

        return if edge.depends_on.nil?

        edge.depends_on.each do |depended_on|
          deduped_depended_on = merged_vertex_or_new depended_on

          @dependency_map = @dependency_map.put(deduped_depended_on) do |v|
            (v || ::Hamster::Set.empty) << deduped_depended_on << deduped_vertex
          end
        end
      end

      Contract String => Bool
      def exists?(file_path)
        @dependency_map.key?(file_path)
      end

      Contract ImmutableSetOf[Vertex]
      def invalidated
        @_invalidated_cache ||= begin
          invalidated_vertices = @dependency_map.keys.select do |vertex|
            # Either "Missing from known vertices"
            # Or invalided by the class
            !@vertices.key?(vertex.key) || !vertex.valid?
          end

          invalidated_vertices.reduce(::Hamster::Set.empty) do |sum, vertex|
            sum | invalidated_with_parents(vertex)
          end
        end
      end

      Contract Vertex => ImmutableSetOf[Vertex]
      def invalidated_with_parents(vertex)
        # TODO, recurse more?
        @dependency_map[vertex] << vertex
      end

      Contract IsA['::Middleman::Sitemap::Resource'] => Bool
      def invalidates_resource?(resource)
        invalidated.any? { |d| d.invalidates_resource?(resource) }
      end
    end
  end
end
