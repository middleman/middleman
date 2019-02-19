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
    GLOBAL_FILES = ['config.rb', 'lib/**/*.rb', 'helpers/**/*.rb', 'Gemfile.lock'].freeze

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

      global = Dir.glob(GLOBAL_FILES)
                  .sort
                  .each_with_object({}) do |file, sum|
        p = Pathname(File.expand_path(file)).relative_path_from(app.root_path).to_s
        sum[p] = ::Middleman::Util.hash_file(file)
      end

      ::YAML.dump(
        {
          'data_depth' => app.config[:data_collection_depth],
          'global' => global
        }.merge(serialized)
      )
    end

    Contract String => Graph
    def parse_yaml(file_path)
      ::YAML.load_file(file_path)
    rescue StandardError, ::Psych::SyntaxError => error
      warn "YAML Exception parsing dependency graph: #{error.message}"
    end

    Contract IsA['::Middleman::Application'], Hash[String, String] => Array[String]
    def invalidated_global(app, known_files)
      known_files.keys.reject do |key|
        p = File.expand_path(key, app.root)
        !(File.exist? p) || known_files[key] == ::Middleman::Util.hash_file(p)
      end
    end

    class InvalidDepsYAML < RuntimeError
    end

    class ChangedDepth < RuntimeError
    end

    class InvalidatedGlobalFiles < RuntimeError
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

      global = data['global']

      raise ChangedDepth if data['data_depth'] != app.config[:data_collection_depth]

      unless (invalidated = invalidated_global(app, global)).empty?
        raise InvalidatedGlobalFiles, invalidated
      end

      # Pre-existing vertices (from config.rb)
      preexisting_vertices = app.data.vertices.each_with_object({}) do |vertex, sum|
        sum[vertex.key] = vertex
      end

      vertices = data['vertices'].each_with_object(preexisting_vertices) do |(type, verts), sum|
        verts.each do |(k, h)|
          vertex_class = VERTICES_BY_TYPE[type.to_sym]
          vertex = vertex_class.deserialize(app, k.to_sym, 'hash' => h)
          if sum[vertex.key.to_sym]
            sum[vertex.key.to_sym].merge!(vertex)
          else
            sum[vertex.key.to_sym] = vertex
          end
        end
      end

      graph = Graph.new
      vertices.values.each { |v| graph.add_vertex(v) }

      data['edges'].each do |k, deps|
        deps.each do |d|
          graph.add_edge_by_key(d.to_sym, k.to_sym)
        end
      end

      # require 'rgl/dot'
      # graph.graph.write_to_graphic_file('jpg', 'valid')

      graph
    rescue StandardError
      raise InvalidDepsYAML
    end
  end
end
