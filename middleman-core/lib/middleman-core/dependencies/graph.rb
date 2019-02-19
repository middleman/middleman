require 'set'
require 'rgl/adjacency'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'
require 'middleman-core/dependencies/edge'

module Middleman
  module Dependencies
    class DirectedAdjacencyGraph < ::RGL::DirectedAdjacencyGraph
      def initialize(*args)
        super

        @vertices_by_key = {}
      end

      def add_vertex(v)
        mv = merged_vertex_or_new(v)

        @vertices_by_key[mv.key] = mv

        super(mv)
      end

      def add_edge(u, v)
        super(merged_vertex_or_new(u), merged_vertex_or_new(v))
      end

      def remove_vertex(vertex)
        each_adjacent(vertex) do |v|
          remove_vertex(v) unless v == vertex
        end

        @vertices_by_key.delete(vertex.key)

        super(vertex)
      end

      def find_vertex_by_key(key)
        @vertices_by_key[key]
      end

      protected

      def merged_vertex_or_new(vertex)
        found_vertex = find_vertex_by_key(vertex.key)

        if found_vertex
          found_vertex.merge!(vertex)
          found_vertex
        else
          vertex
        end
      end
    end

    class Graph
      include Contracts

      Contract DirectedAdjacencyGraph
      attr_reader :graph

      def initialize(_vertices = {})
        @graph = DirectedAdjacencyGraph.new
      end

      def invalidate_vertex!(vertex)
        @graph.remove_vertex(vertex)
      end

      Contract Vertex => Any
      def add_vertex(vertex)
        @graph.add_vertex(vertex)
      end

      Contract Vertex, Vertex => Any
      def add_edge(source, target)
        if source == target
          add_vertex(source)
        else
          @graph.add_edge(source, target)
        end
      end

      Contract Symbol, Symbol => Any
      def add_edge_by_key(source, target)
        a = @graph.find_vertex_by_key(source)
        b = @graph.find_vertex_by_key(target)

        add_edge(a, b)
      end

      Contract Edge => Any
      def add_edge_set(edge)
        return if edge.depends_on.nil?

        edge.depends_on.each do |depended_on|
          add_edge(depended_on, edge.vertex)
        end
      end

      def serialize
        edges = @graph.edges
                      .sort_by { |edge| edge.target.key }
                      .each_with_object({}) do |edge, sum|
          sum[edge.target.key.to_s] ||= []
          sum[edge.target.key.to_s] << edge.source.key.to_s
        end

        # Sort dependencies list
        edges = edges.each { |(k, v)| edges[k] = v.sort }

        vertices = @graph.vertices
                         .sort_by { |v| [v.type_id, v.key] }
                         .each_with_object({}) do |v, sum|
          s = v.serialize
          k = s.delete 'key'
          t = s.delete 'type'
          a = s.delete 'attrs'

          sum[t] ||= {}
          sum[t][k] = a['hash']
        end

        {
          'edges' => edges,
          'vertices' => vertices
        }
      end

      Contract ImmutableSetOf[Vertex]
      def invalidated
        invalidated = @graph.vertices.reject(&:valid?)
        invalidated.each { |v| @graph.remove_vertex(v) }

        ::Hamster::Set.new(invalidated)
      end

      Contract IsA['::Middleman::Sitemap::Resource'] => Bool
      def invalidates_resource?(resource)
        @graph.vertices.none? { |d| d.matches_resource?(resource) }
      end
    end
  end
end
