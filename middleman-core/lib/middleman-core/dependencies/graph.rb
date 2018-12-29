require 'set'
require 'rgl/adjacency'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'
require 'middleman-core/dependencies/edge'

module Middleman
  module Dependencies
    class DirectedAdjacencyGraph < ::RGL::DirectedAdjacencyGraph

      def add_edge(u, v)
        super(merged_vertex_or_new(u), merged_vertex_or_new(v))
      end

      def remove_vertex(vertex)
        super(vertex)

        @vertices_dict.each do |k, v|
          if v.empty? && @vertices_dict.values.none? { |adj| adj.include?(k) }
            @vertices_dict.delete(k)
          end
        end
      end

      def find_vertex_by_key(key)
        vertices.find { |v| v.key == key }
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

      def initialize(vertices = {})
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
        @graph.add_edge(source, target)
      end

      Contract Symbol, Symbol => Any
      def add_edge_by_key(source, target)
        a = @graph.find_vertex_by_key(source)
        b = @graph.find_vertex_by_key(target)
        
        @graph.add_edge(a, b)
      end

      Contract Edge => Any
      def add_edge_set(edge)
        return if edge.depends_on.nil?

        edge.depends_on.each do |depended_on|
          add_edge(depended_on, edge.vertex)
        end
      end

      def serialize
        edges = @graph.edges.map do |edge|
          {
            key: edge.target.key,
            depends_on: edge.source.key
          }
        end
  
        vertices = @graph.vertices.map(&:serialize)

        {
          edges: edges.sort_by { |d| [d[:key], d[:depends_on]] },
          vertices: vertices.sort_by { |d| d[:key] }
        }
      end

      Contract ImmutableSetOf[Vertex]
      def invalidated
        binding.pry
        # @_invalidated_cache ||= begin
        #   invalidated_vertices = @dependency_map.keys.select do |vertex|
        #     # Either "Missing from known vertices"
        #     # Or invalided by the class
        #     !@vertices.key?(vertex.key) || !vertex.valid?
        #   end

        #   invalidated_vertices.reduce(::Hamster::Set.empty) do |sum, vertex|
        #     sum | invalidated_with_parents(vertex)
        #   end
        # end
        ::Hamster::Set.empty
      end

      Contract IsA['::Middleman::Sitemap::Resource'] => Bool
      def invalidates_resource?(resource)
        invalidated.any? { |d| d.invalidates_resource?(resource) }
      end
    end
  end
end
