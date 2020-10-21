# frozen_string_literal: true

require 'hamster'
require 'set'
require 'pathname'
require 'yaml'
require 'fileutils'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/graph'
require 'middleman-core/dependencies/vertices'

module Middleman
  module Dependencies
    include Contracts

    GLOBAL_FILES = ['config.rb', 'lib/**/*.rb', 'helpers/**/*.rb', 'Gemfile.lock'].freeze

    module_function

    Contract IsA['::Middleman::Application'], Graph, String => Any
    def serialize_and_save(app, graph, file_path)
      new_output = serialize(app, graph)

      FileUtils.mkdir_p(File.dirname(file_path))

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
    rescue StandardError, ::Psych::SyntaxError => e
      warn "YAML Exception parsing dependency graph: #{e.message}"
    end

    Contract IsA['::Middleman::Application'], Hash[String, String] => Array[String]
    def invalidated_global(app, known_files)
      known_files.keys.reject do |key|
        p = File.expand_path(key, app.root)
        !(File.exist? p) || known_files[key] == ::Middleman::Util.hash_file(p)
      end
    end

    class DependencyLoadError < RuntimeError
    end

    class MissingDepsYAML < DependencyLoadError
    end

    class InvalidDepsYAML < DependencyLoadError
    end

    class ChangedDepth < DependencyLoadError
    end

    class InvalidatedGlobalFiles < DependencyLoadError
      attr_reader :invalidated

      def initialize(invalidated)
        super()

        @invalidated = invalidated
      end
    end

    Contract IsA['::Middleman::Application'], String => Graph
    def load_and_deserialize(app, file_path)
      raise MissingDepsYAML unless File.exist?(file_path)

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
      vertices.each_value { |v| graph.add_vertex(v) }

      data['edges'].each do |k, deps|
        deps.each do |d|
          graph.add_edge_by_key(d.to_sym, k.to_sym)
        end
      end

      # require 'rgl/dot'
      # graph.graph.write_to_graphic_file('jpg', 'valid')

      graph
    rescue StandardError => e
      new_error = e.is_a?(DependencyLoadError) ? e : InvalidDepsYAML
      raise new_error
    end
  end
end
