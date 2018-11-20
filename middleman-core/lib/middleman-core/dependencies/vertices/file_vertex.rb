require 'pathname'
require 'digest/sha1'
require 'middleman-core/contracts'
require 'middleman-core/dependencies/vertices/vertex'

module Middleman
  module Dependencies
    class FileVertex < Vertex
      include Contracts

      TYPE_ID = :file

      Contract IsA['::Middleman::Application'], String, Vertex::VERTEX_ATTRS => FileVertex
      def self.deserialize(app, key, attributes)
        FileVertex.new(app.root_path, key, attributes)
      end

      Contract IsA['Middleman::Sitemap::Resource'] => FileVertex
      def self.from_resource(resource)
        from_source_file(resource.app, resource.file_descriptor)
      end

      Contract IsA['::Middleman::Application'], IsA['::Middleman::SourceFile'] => FileVertex
      def self.from_source_file(app, source_file)
        FileVertex.new(app.root_path, source_file[:full_path].to_s)
      end

      Contract Or[String, Pathname], String, Maybe[VERTEX_ATTRS] => Any
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

      Contract Vertex::SERIALIZED_VERTEX
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
  end
end
