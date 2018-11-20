require 'set'
require 'pathname'
require 'digest/sha1'
require 'yaml'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/graph'
require 'middleman-core/dependencies/vertices'

module Middleman
  module Dependencies
    include Contracts

    DEFAULT_FILE_PATH = 'deps.yml'.freeze
    RUBY_FILES = ['**/*.rb', 'Gemfile.lock'].freeze

    module_function

    Contract IsA['::Middleman::Application'], Graph => String
    def serialize(app, graph)
      ruby_files = Dir.glob(RUBY_FILES).reduce([]) do |sum, file|
        sum << {
          file: Pathname(File.expand_path(file)).relative_path_from(app.root_path).to_s,
          hash: ::Digest::SHA1.file(file).hexdigest
        }
      end

      edges = graph.dependency_map.reduce([]) do |sum, (vertex, depended_on_by)|
        sum << {
          key: vertex.key,
          depended_on_by: depended_on_by.delete(vertex).to_a.map(&:key).sort
        }
      end

      vertices = graph.dependency_map.reduce([]) do |sum, (vertex, _depended_on_by)|
        sum << vertex.serialize
      end

      ::YAML.dump(
        ruby_files: ruby_files.sort_by { |d| d[:file] },
        edges: edges.sort_by { |d| d[:file] },
        vertices: vertices.sort_by { |d| d[:key] }
      )
    end

    Contract IsA['::Middleman::Application'], Graph, Maybe[String] => Any
    def serialize_and_save(app, graph, file_path = DEFAULT_FILE_PATH)
      File.open(file_path, 'w') do |file|
        file.write serialize(app, graph)
      end
    end

    Contract String => Graph
    def parse_yaml(file_path)
      ::YAML.load_file(file_path)
    rescue StandardError, ::Psych::SyntaxError => error
      warn "YAML Exception parsing dependency graph: #{error.message}"
    end

    Contract ArrayOf[String]
    def invalidated_ruby_files(known_files)
      known_files.reject do |file|
        file[:hash] == ::Digest::SHA1.file(file[:file]).hexdigest
      end
    end

    class InvalidDepsYAML < RuntimeError
    end

    class InvalidatedRubyFiles < RuntimeError
      attr_reader :invalidated

      def initialize(invalidated)
        super()

        @invalidated = invalidated
      end
    end

    Contract IsA['::Middleman::Application'], Maybe[String] => Graph
    def load_and_deserialize(app, file_path = DEFAULT_FILE_PATH)
      return Graph.new unless File.exist?(file_path)

      data = parse_yaml(file_path)

      ruby_files = data[:ruby_files]

      unless (invalidated = invalidated_ruby_files(ruby_files)).empty?
        raise InvalidatedRubyFiles, invalidated
      end

      vertices = data[:vertices].each_with_object({}) do |row, sum|
        vertex_class = VERTICES_BY_TYPE[row[:type]]
        vertex = vertex_class.deserialize(app, row[:key], row[:attributes])
        sum[vertex.key] = vertex
      end

      graph = Graph.new(vertices)

      edges = data[:edges]
      graph.dependency_map = edges.each_with_object({}) do |row, sum|
        vertex = graph.vertices[row[:key]]
        depended_on_by = row[:depended_on_by].map { |k| graph.vertices[k] }
        sum[vertex] = ::Hamster::Set.new(depended_on_by) << vertex
      end

      graph
    rescue StandardError
      raise InvalidDepsYAML
    end
  end
end
