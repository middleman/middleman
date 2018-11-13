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
            # $stderr.puts "#{file} missing hash"
            true
          else
            # $stderr.puts "#{file} invalid hash"
            hashes[file] != ::Digest::SHA1.file(file).hexdigest
          end
        end

        invalidated_files.reduce(Set.new) do |sum, file|
          sum << file
          sum | @dependency_map[file]
        end
      end
    end

    include Contracts

    module_function

    Contract ArrayOf[String]
    def ruby_files_paths
      Dir['**/*.rb', 'Gemfile.lock']
    end

    Contract IsA['::Middleman::Application'], String => String
    def relativize(app, file)
      Pathname(File.expand_path(file)).relative_path_from(app.root_path).to_s
    end

    Contract IsA['::Middleman::Application'], String => String
    def fullize(app, file)
      File.expand_path(file, app.root_path)
    end

    Contract IsA['::Middleman::Application'], Graph => String
    def serialize(app, graph)
      ruby_files = ruby_files_paths.reduce([]) do |sum, file|
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

      ::YAML.dump(
        ruby_files: ruby_files.sort_by { |d| d[:file] },
        source_files: source_files.sort_by { |d| d[:file] }
      )
    end

    DEFAULT_FILE_PATH = 'deps.yml'.freeze

    Contract IsA['::Middleman::Application'], Graph, Maybe[String] => Any
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

      data = deserialize(file_path)

      ruby_files = data[:ruby_files]

      unless (invalidated = invalidated_ruby_files(ruby_files)).empty?
        raise InvalidatedRubyFiles, invalidated
      end

      source_files = data[:source_files]

      hashes = source_files.each_with_object({}) do |row, sum|
        sum[fullize(app, row[:file])] = row[:hash]
      end

      graph = Graph.new(hashes)

      graph.dependency_map = source_files.each_with_object({}) do |row, sum|
        sum[fullize(app, row[:file])] = Set.new((row[:depended_on_by] + [row[:file]]).map { |f| fullize(app, f) })
      end

      graph
    rescue StandardError
      raise InvalidDepsYAML
    end
  end
end
