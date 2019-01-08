require 'hamster'
require 'set'
require 'pathname'
require 'yaml'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/graph'
require 'middleman-core/dependencies/vertices'

module Middleman
  module Dependencies
    include Contracts

    DEFAULT_FILE_PATH = 'deps.yml'.freeze
    RUBY_FILES = ['config.rb', 'lib/**/*.rb', 'helpers/**/*.rb', 'Gemfile.lock'].freeze

    module_function

    Contract IsA['::Middleman::Application'], Graph, Maybe[String] => Any
    def serialize_and_save(app, graph, file_path = DEFAULT_FILE_PATH)
      new_output = serialize(app, graph)

      File.open(file_path, 'w') do |file|
        file.write new_output
      end
    end

    Contract IsA['::Middleman::Application'], Graph => Any
    def visualize_graph(_app, graph)
      require 'rgl/dot'
      graph.graph.write_to_graphic_file('jpg', 'graph')
    end

    Contract IsA['::Middleman::Application'], Graph => String
    def serialize(app, graph)
      serialized = graph.serialize

      ruby_files = Dir.glob(RUBY_FILES).reduce([]) do |sum, file|
        sum << {
          file: Pathname(File.expand_path(file)).relative_path_from(app.root_path).to_s,
          hash: ::Middleman::Util.hash_file(file)
        }
      end

      ::YAML.dump(
        {
          ruby_files: ruby_files.sort_by { |d| d[:file] }
        }.merge(serialized)
      )
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
        file[:hash] == ::Middleman::Util.hash_file(file[:file])
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

      # Pre-existing vertices (from config.rb)
      preexisting_vertices = app.data.vertices.each_with_object({}) do |vertex, sum|
        sum[vertex.key] = vertex
      end

      vertices = data[:vertices].each_with_object(preexisting_vertices) do |row, sum|
        vertex_class = VERTICES_BY_TYPE[row[:type]]
        vertex = vertex_class.deserialize(app, row[:key], row[:attributes])
        if sum[vertex.key]
          sum[vertex.key].merge!(vertex)
        else
          sum[vertex.key] = vertex
        end
      end

      graph = Graph.new
      vertices.values.each { |v| graph.add_vertex(v) }

      data[:edges].each do |e|
        graph.add_edge_by_key(e[:depends_on], e[:key])
      end

      graph.invalidate_changes!

      # require 'rgl/dot'
      # graph.graph.write_to_graphic_file('jpg', 'valid')

      graph
    rescue StandardError
      raise InvalidDepsYAML
    end
  end
end
