require 'middleman-core/contracts'
require 'set'
require 'yaml'

module Middleman
  module Dependencies
    class Dependency
      include Contracts

      Contract String
      attr_reader :file

      Contract Maybe[SetOf[String]]
      attr_accessor :depends_on

      Contract String, Maybe[SetOf[String]] => Any
      def initialize(file, depends_on = nil)
        @file = file
        @depends_on = nil
        @depends_on = Set.new(depends_on) unless depends_on.nil?
      end

      Contract String
      def to_s
        "#<#{self.class} file=#{@file} depends_on=#{@depends_on}>"
      end
    end

    class Graph
      include Contracts

      Contract HashOf[String, String]
      attr_reader :hashes

      Contract HashOf[String, SetOf[String]]
      attr_reader :dependency_map

      def initialize(hashes = {})
        @hashes = hashes
        @dependency_map = {}
      end
      
      Contract Dependency => Any
      def add_dependency(file)
        return if file.depends_on.nil?

        file.depends_on.each do |dep|
          @dependency_map[dep] ||= Set.new
          @dependency_map[dep] << dep
          @dependency_map[dep] << file.file
        end
      end

      def invalidated
        invalidated_files = @dependency_map.keys.select do |file|
          !@hashes.key?(file) || hashes[file] != ::Digest::SHA1.file(file).hexdigest
        end

        invalidated_files.reduce(Set.new) do |sum, file|
          sum << file
          sum |= @dependency_map[file]
        end
      end
    end

    include Contracts

    module_function

    Contract Graph => String
    def serialize(graph)
      deps = graph.dependency_map.reduce([]) do |sum, (file, depends_on)|
        sum << {
          file: file,
          hash: ::Digest::SHA1.file(file).hexdigest, # [0..7]
          depends_on: depends_on.delete(file).to_a.sort
        }
      end

      ::YAML.dump(deps.sort_by { |d| d[:file] })
    end

    DEFAULT_FILE_PATH = 'deps.yml'

    Contract Graph, Maybe[String] => Any
    def serialize_and_save(graph, file_path = DEFAULT_FILE_PATH)
      File.open(file_path, 'w') do |file|
        file.write serialize(graph)
      end
    end

    Contract String => Graph
    def deserialize(file_path)
      ::YAML.load_file(file_path)
    rescue StandardError, ::Psych::SyntaxError => error
      warn "YAML Exception parsing dependency graph: #{error.message}"
    end

    Contract Maybe[String] => Graph
    def load_and_deserialize(file_path = DEFAULT_FILE_PATH)
      graph = Graph.new

      return Graph.new unless File.exists?(file_path)

      data = deserialize(file_path)

      hashes = data.reduce({}) do |sum, row|
        sum[row[:file]] = row[:hash]
        sum
      end
      
      graph = Graph.new(hashes)

      data.each do |row|
        deps = Set.new(row[:depends_on])
        graph.add_dependency Dependency.new(row[:file], deps.add(row[:file]))
      end
      
      graph
    end
  end
end