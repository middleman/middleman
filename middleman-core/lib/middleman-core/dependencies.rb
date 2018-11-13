require 'middleman-core/contracts'
require 'set'
require 'pathname'
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
      attr_accessor :dependency_map

      def initialize(hashes = {})
        @hashes = hashes
        @dependency_map = {}
      end
      
      Contract Dependency => Any
      def add_dependency(file)
        @dependency_map[file.file] ||= Set.new
        @dependency_map[file.file] << file.file
        
        return if file.depends_on.nil?

        file.depends_on.each do |dep|
          @dependency_map[dep] ||= Set.new
          @dependency_map[dep] << dep
          @dependency_map[dep] << file.file
        end
      end

      def invalidated
        invalidated_files = @dependency_map.keys.select do |file|
          if !@hashes.key?(file)
            true
          elsif hashes[file] != ::Digest::SHA1.file(file).hexdigest
            true
          else
            false
          end
        end

        invalidated_files.reduce(Set.new) do |sum, file|
          sum << file
          sum |= @dependency_map[file]
        end
      end
    end

    include Contracts

    module_function

    Contract ArrayOf[String]
    def get_ruby_files
      Dir["**/*.rb", "Gemfile.lock"]
    end

    Contract IsA["::Middleman::Application"], String => String
    def relativize(app, file)
      Pathname(File.expand_path(file)).relative_path_from(app.root_path).to_s
    end

    Contract IsA["::Middleman::Application"], String => String
    def fullize(app, file)
      File.expand_path(file, app.root_path)
    end

    Contract IsA["::Middleman::Application"], Graph => String
    def serialize(app, graph)
      ruby_files = get_ruby_files.reduce([]) do |sum, file|
        sum << {
          file: relativize(app, file),
          hash: ::Digest::SHA1.file(file).hexdigest # [0..7]
        }
      end

      source_files = graph.dependency_map.reduce([]) do |sum, (file, depended_on_by)|
        sum << {
          file: relativize(app, file),
          hash: ::Digest::SHA1.file(file).hexdigest, # [0..7]
          depended_on_by: depended_on_by.delete(file).to_a.sort.map { |p| relativize(app, p) }
        }
      end

      ::YAML.dump({
        ruby_files: ruby_files.sort_by { |d| d[:file] },
        source_files: source_files.sort_by { |d| d[:file] }
      })
    end

    DEFAULT_FILE_PATH = 'deps.yml'

    Contract IsA["::Middleman::Application"], Graph, Maybe[String] => Any
    def serialize_and_save(app, graph, file_path = DEFAULT_FILE_PATH)
      File.open(file_path, 'w') do |file|
        file.write serialize(app, graph)
      end
    end

    Contract String => Graph
    def deserialize(file_path)
      ::YAML.load_file(file_path)
    rescue StandardError, ::Psych::SyntaxError => error
      warn "YAML Exception parsing dependency graph: #{error.message}"
    end

    Contract ArrayOf[String]
    def invalidated_ruby_files(known_files)
      known_files.select do |file|
        file[:hash] != ::Digest::SHA1.file(file[:file]).hexdigest
      end
    end

    class InvalidDepsYAML < Exception
    end
    
    class InvalidatedRubyFiles < Exception
      attr_reader :invalidated

      def initialize(invalidated)
        super()

        @invalidated = invalidated
      end
    end

    Contract IsA["::Middleman::Application"], Maybe[String] => Graph
    def load_and_deserialize(app, file_path = DEFAULT_FILE_PATH)
      graph = Graph.new

      return Graph.new unless File.exists?(file_path)

      data = deserialize(file_path)

      ruby_files = data[:ruby_files]

      unless (invalidated = invalidated_ruby_files(ruby_files)).empty?
        raise InvalidatedRubyFiles.new(invalidated)
      end

      source_files = data[:source_files]

      hashes = source_files.reduce({}) do |sum, row|
        sum[row[:file]] = row[:hash]
        sum
      end
      
      graph = Graph.new(hashes)
      
      graph.dependency_map = source_files.reduce({}) do |sum, row|        
        sum[fullize(app, row[:file])] = deps = Set.new(row[:depended_on_by].add(row[:file]).map { |f| fullize(app, f) })
        sum
      end

      graph
    rescue
      raise InvalidDepsYAML.new
    end
  end
end