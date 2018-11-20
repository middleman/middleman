require 'middleman-core/contracts'
require 'set'
require 'pathname'
require 'yaml'

module Middleman
  module Dependencies
    class BaseDependency
      include Contracts

      DEPENDENCY_KEY = Or[String, Symbol]
      DEPENDENCY_ATTRS = HashOf[Symbol, String]
      SERIALIZED_DEPENDENCY = {
        key: Any, # Weird inheritance bug
        type: Symbol,
        attributes: DEPENDENCY_ATTRS
      }.freeze

      Contract DEPENDENCY_KEY
      attr_reader :key

      Contract DEPENDENCY_ATTRS
      attr_reader :attributes

      Contract DEPENDENCY_KEY, DEPENDENCY_ATTRS => Any
      def initialize(key, attributes)
        @key = key
        @attributes = attributes
      end

      Contract BaseDependency => Bool
      def ==(other)
        key == other.key
      end

      Contract Bool
      def valid?
        raise NotImplementedError
      end

      Contract IsA['Middleman::Sitemap::Resource'] => Bool
      def invalidates_resource?(_resource)
        raise NotImplementedError
      end

      Contract Maybe[DEPENDENCY_ATTRS] => SERIALIZED_DEPENDENCY
      def serialize(attributes = {})
        {
          key: @key,
          type: type_id,
          attributes: @attributes.merge(attributes)
        }
      end

      protected

      Contract Symbol
      def type_id
        self.class.const_get :TYPE_ID
      end

      Contract Pathname, String => String
      def relative_path(root, file)
        Pathname(File.expand_path(file)).relative_path_from(root).to_s
      end

      Contract Pathname, String => String
      def full_path(root, file)
        File.expand_path(file, root)
      end
    end

    class FileDependency < BaseDependency
      include Contracts

      TYPE_ID = :file

      Contract IsA['::Middleman::Application'], String, BaseDependency::DEPENDENCY_ATTRS => FileDependency
      def self.deserialize(app, key, attributes)
        FileDependency.new(app.root_path, key, attributes)
      end

      Contract IsA['Middleman::Sitemap::Resource'] => FileDependency
      def self.from_resource(resource)
        from_source_file(resource.app, resource.file_descriptor)
      end

      Contract IsA['::Middleman::Application'], IsA['::Middleman::SourceFile'] => FileDependency
      def self.from_source_file(app, source_file)
        FileDependency.new(app.root_path, source_file[:full_path].to_s)
      end

      Contract Or[String, Pathname], String, Maybe[DEPENDENCY_ATTRS] => Any
      def initialize(root, key, attributes = {})
        @root = Pathname(root)
        @full_path = full_path(@root, key)
        super(relative_path(@root, key), attributes)
      end

      Contract Bool
      def valid?
        @is_valid = (previous_hash.nil? || hash_file == previous_hash) if @is_valid.nil?
        @is_valid
      end

      Contract IsA['Middleman::Sitemap::Resource'] => Bool
      def invalidates_resource?(resource)
        resource.file_descriptor[:full_path].to_s == @full_path
      end

      Contract BaseDependency::SERIALIZED_DEPENDENCY
      def serialize
        super({
          hash: valid? && !previous_hash.nil? ? previous_hash : hash_file
        })
      end

      private

      Contract Maybe[String]
      def previous_hash
        @attributes[:hash]
      end

      Contract String
      def hash_file
        ::Digest::SHA1.file(@full_path).hexdigest
      end
    end

    DEPENDENCY_CLASSES_BY_TYPE = {
      FileDependency::TYPE_ID => FileDependency
    }.freeze

    class DependencyLink
      include Contracts

      Contract BaseDependency
      attr_reader :dependency

      Contract Maybe[SetOf[BaseDependency]]
      attr_accessor :depends_on

      Contract BaseDependency, Maybe[SetOf[BaseDependency]] => Any
      def initialize(dependency, depends_on = nil)
        @dependency = dependency
        @depends_on = nil
        @depends_on = Set.new(depends_on) unless depends_on.nil?
      end

      Contract String
      def to_s
        "#<#{self.class} file=#{@dependency} depends_on=#{@depends_on}>"
      end
    end

    class Graph
      include Contracts

      Contract HashOf[BaseDependency::DEPENDENCY_KEY, BaseDependency]
      attr_reader :dependencies

      Contract HashOf[BaseDependency, SetOf[BaseDependency]]
      attr_accessor :dependency_map

      def initialize(dependencies = {})
        @dependencies = dependencies
        @dependency_map = {}
      end

      Contract BaseDependency => BaseDependency
      def known_dependency_or_new(dep)
        @dependencies[dep.key] ||= dep
      end

      Contract DependencyLink => Any
      def add_dependency(link)
        deduped_depender = known_dependency_or_new link.dependency

        @dependency_map[deduped_depender] ||= Set.new
        @dependency_map[deduped_depender] << deduped_depender

        return if link.depends_on.nil?

        link.depends_on.each do |depended_on|
          deduped_depended_on = known_dependency_or_new depended_on

          @dependency_map[deduped_depended_on] ||= Set.new
          @dependency_map[deduped_depended_on] << deduped_depended_on
          @dependency_map[deduped_depended_on] << deduped_depender
        end
      end

      Contract String => Bool
      def exists?(file_path)
        @dependency_map.key?(file_path)
      end

      Contract SetOf[BaseDependency]
      def invalidated
        @_invalidated_cache ||= begin
          invalidated_dependencies = @dependency_map.keys.select do |dependency|
            # Either "Missing from known dependencies"
            # Or invalided by the class
            !@dependencies.key?(dependency.key) || !dependency.valid?
          end

          invalidated_dependencies.reduce(Set.new) do |sum, dependency|
            sum | invalidated_with_parents(dependency)
          end
        end
      end

      Contract BaseDependency => SetOf[BaseDependency]
      def invalidated_with_parents(dependency)
        # TODO, recurse more?
        (Set.new + (@dependency_map[dependency])) << dependency
      end

      Contract IsA['::Middleman::Sitemap::Resource'] => Bool
      def invalidates_resource?(resource)
        invalidated.any? { |d| d.invalidates_resource?(resource) }
      end
    end

    include Contracts

    module_function

    Contract IsA['::Middleman::Application'], Graph => String
    def serialize(app, graph)
      ruby_files = Dir['**/*.rb', 'Gemfile.lock'].reduce([]) do |sum, file|
        sum << {
          file: Pathname(File.expand_path(file)).relative_path_from(app.root_path).to_s,
          hash: ::Digest::SHA1.file(file).hexdigest
        }
      end

      dependency_links = graph.dependency_map.reduce([]) do |sum, (dependency, depended_on_by)|
        sum << {
          key: dependency.key,
          depended_on_by: depended_on_by.delete(dependency).to_a.map(&:key).sort
        }
      end

      dependencies = graph.dependency_map.reduce([]) do |sum, (dependency, _depended_on_by)|
        sum << dependency.serialize
      end

      ::YAML.dump(
        ruby_files: ruby_files.sort_by { |d| d[:file] },
        dependency_links: dependency_links.sort_by { |d| d[:file] },
        dependencies: dependencies.sort_by { |d| d[:key] }
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

      dependencies = data[:dependencies].each_with_object({}) do |row, sum|
        dep_class = DEPENDENCY_CLASSES_BY_TYPE[row[:type]]
        dep = dep_class.deserialize(app, row[:key], row[:attributes])
        sum[dep.key] = dep
      end

      graph = Graph.new(dependencies)

      dependency_links = data[:dependency_links]
      graph.dependency_map = dependency_links.each_with_object({}) do |row, sum|
        dependency = graph.dependencies[row[:key]]
        depended_on_by = row[:depended_on_by].map { |k| graph.dependencies[k] }
        sum[dependency] = Set.new(depended_on_by) << dependency
      end

      graph
    rescue StandardError
      raise InvalidDepsYAML
    end
  end
end
