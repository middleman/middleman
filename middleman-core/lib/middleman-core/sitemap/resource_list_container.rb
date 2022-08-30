# frozen_string_literal: true

require 'set'
require 'middleman-core/contracts'
require 'middleman-core/sitemap/resource'

module Middleman
  module Sitemap
    class ResourceListContainer
      extend Forwardable
      include Contracts

      def_delegators :without_ignored, :each, :each_with_index, :find, :select, :reject, :map

      Contract Maybe[ArrayOf[Resource]] => Any
      def initialize(initial = nil)
        reset!(initial)
      end

      Contract Maybe[ArrayOf[Resource]] => Any
      def reset!(initial = nil)
        @_set = Set.new
        @_lookup_by_binary = Set.new
        @_lookup_by_non_binary = Set.new
        @_lookup_by_ignored = Set.new

        @_lookup_by_path = {}
        @_lookup_by_destination_path = {}
        @_lookup_by_source_extension = {}
        @_lookup_by_destination_extension = {}
        @_lookup_by_page_id = {}

        add!(*initial.sort_by(&:priority)) unless initial.nil?
      end

      Contract Args[Resource] => Any
      def add!(*resources)
        resources.each(&method(:add_one!))
      end

      Contract Resource => Any
      def add_one!(resource)
        @_set.add(resource)

        add_cache resource
      end

      Contract Symbol, Maybe[Symbol] => Bool
      def should_run?(key, only = nil)
        return true if only.nil?

        key == only
      end

      Contract Resource, Maybe[Symbol] => Any
      def add_cache(resource, only = nil)
        @_lookup_by_path[::Middleman::Util.normalize_path(resource.path)] = resource if should_run? :path, only

        @_lookup_by_destination_path[::Middleman::Util.normalize_path(resource.destination_path)] = resource if should_run? :destination_path, only

        if should_run? :binary, only
          if resource.binary?
            @_lookup_by_binary.add(resource)
          else
            @_lookup_by_non_binary.add(resource)
          end
        end

        if should_run? :source_extension, only
          source_ext = resource.file_descriptor && resource.file_descriptor[:full_path] && ::File.extname(resource.file_descriptor[:full_path])
          if source_ext
            @_lookup_by_source_extension[source_ext] ||= Set.new
            @_lookup_by_source_extension[source_ext].add(resource)
          end
        end

        if should_run? :destination_extension, only
          dest_ext = ::File.extname(resource.destination_path)

          v = @_lookup_by_destination_extension[dest_ext] ||= Set.new
          v.add(resource)
        end

        @_lookup_by_page_id[resource.page_id.to_s.to_sym] = resource if should_run? :page_id, only

        @_lookup_by_ignored.add(resource) if should_run?(:ignored, only) && resource.ignored?
      end

      Contract Resource => Any
      def remove!(resource)
        @_set.delete resource

        remove_cache resource
      end

      Contract Resource, Maybe[Symbol] => Any
      def remove_cache(resource, only = nil)
        if should_run? :path, only
          @_lookup_by_path.delete(
            ::Middleman::Util.normalize_path(resource.path)
          )
        end

        if should_run? :destination_path, only
          @_lookup_by_destination_path.delete(
            ::Middleman::Util.normalize_path(resource.destination_path)
          )
        end

        if should_run? :binary, only
          if resource.binary?
            @_lookup_by_binary.delete(resource)
          else
            @_lookup_by_non_binary.delete(resource)
          end
        end

        if should_run? :source_extension, only
          source_ext = resource.file_descriptor && resource.file_descriptor[:full_path] && ::File.extname(resource.file_descriptor[:full_path])
          @_lookup_by_source_extension[source_ext]&.delete(resource) if source_ext
        end

        if should_run? :destination_extension, only
          dest_ext = ::File.extname(resource.destination_path)

          @_lookup_by_destination_extension[dest_ext]&.delete(resource)
        end

        if should_run? :page_id, only
          @_lookup_by_page_id.delete(
            resource.page_id.to_s.to_sym
          )
        end

        @_lookup_by_ignored.delete(resource) if should_run? :ignored, only
      end

      Contract Resource, Maybe[Symbol], Proc => Any
      def update!(resource, only = nil)
        remove_cache(resource, only)

        yield

        add_cache(resource, only)
      end

      # Find resources given its source extension
      Contract String => ResourceList
      def by_source_extension(extension)
        @_lookup_by_source_extension[extension] || Set.new
      end

      # Find resources given a set of source extensions
      Contract Or[ArrayOf[String], SetOf[String]] => ResourceList
      def by_source_extensions(extensions)
        extensions.reduce(Set.new) do |sum, ext|
          sum | by_source_extension(ext)
        end
      end

      # Find resources given its destination extension
      Contract String => ResourceList
      def by_extension(extension)
        @_lookup_by_destination_extension[extension] || Set.new
      end

      # Find resources given a set of destination extensions
      Contract Or[ArrayOf[String], SetOf[String]] => ResourceList
      def by_extensions(extensions)
        extensions.reduce(Set.new) do |sum, ext|
          sum | by_extension(ext)
        end
      end

      # Find a resource given its original path
      Contract String => Maybe[Resource]
      def by_path(request_path)
        request_path = ::Middleman::Util.normalize_path(request_path)
        @_lookup_by_path[request_path]
      end

      # Find a resource given its destination path
      Contract String => Maybe[Resource]
      def by_destination_path(request_path)
        request_path = ::Middleman::Util.normalize_path(request_path)
        @_lookup_by_destination_path[request_path]
      end

      # Find a resource given its page id
      Contract Or[String, Symbol] => Maybe[Resource]
      def by_page_id(page_id)
        @_lookup_by_page_id[page_id.to_s.to_sym]
      end

      # Find a resource given its page id
      Contract Bool => ResourceList
      def by_binary(is_binary)
        if is_binary
          @_lookup_by_binary
        else
          @_lookup_by_non_binary
        end
      end

      # All resources
      Contract ResourceList
      def with_ignored
        @_set
      end

      # All resources without ignored
      Contract ResourceList
      def without_ignored
        @_set - @_lookup_by_ignored
      end

      Contract ArrayOf[Resource]
      def by_priority
        without_ignored.sort
      end

      Contract ArrayOf[Resource]
      def to_a
        @_set.to_a
      end
    end
  end
end
