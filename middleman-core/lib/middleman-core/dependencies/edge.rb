require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'

module Middleman
  module Dependencies
    class Edge
      include Contracts

      Contract Vertex
      attr_reader :vertex

      Contract ImmutableSetOf[Vertex]
      attr_accessor :depends_on

      Contract Vertex, ImmutableSetOf[Vertex] => Any
      def initialize(vertex, depends_on)
        @vertex = vertex
        @depends_on = depends_on
      end

      Contract String
      def to_s
        "#<#{self.class} vertex=#{@vertex} edges=#{@edges}>"
      end
    end
  end
end
