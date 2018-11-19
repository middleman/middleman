require 'set'
require 'middleman-core/contracts'
require 'middleman-core/core_extensions/data/stores/base'

module Middleman
  module CoreExtensions
    module Data
      module Stores
        # JSON and YAML files in the data/ directory
        class LocalFileDataStore < BaseDataStore
          extend Forwardable
          include Contracts

          def_delegators :@local_data, :keys, :key?, :[]

          # Contract IsA['::Middleman::Application'] => Any
          def initialize(app)
            super()

            @app = app
            @local_data = {}
          end

          Contract ArrayOf[IsA['Middleman::SourceFile']], ArrayOf[IsA['Middleman::SourceFile']] => Any
          def update_files(updated_files, removed_files)
            updated_files.each(&method(:touch_file))
            removed_files.each(&method(:remove_file))

            @app.sitemap.rebuild_resource_list!(:touched_data_file)
          end

          YAML_EXTS = Set.new %w[.yaml .yml]
          JSON_EXTS = Set.new %w[.json]
          ALL_EXTS = YAML_EXTS | JSON_EXTS

          # Update the internal cache for a given file path
          #
          # @param [String] file The file to be re-parsed
          # @return [void]
          Contract IsA['Middleman::SourceFile'] => Any
          def touch_file(file)
            data_path = file[:relative_path]
            extension = File.extname(data_path)
            basename  = File.basename(data_path, extension)

            return unless ALL_EXTS.include?(extension)

            if YAML_EXTS.include?(extension)
              data, postscript = ::Middleman::Util::Data.parse(file, @app.config[:frontmatter_delims], :yaml)
              data[:postscript] = postscript if !postscript.nil? && data.is_a?(Hash)
            elsif JSON_EXTS.include?(extension)
              data, _postscript = ::Middleman::Util::Data.parse(file, @app.config[:frontmatter_delims], :json)
            end

            data_branch = @local_data

            path = data_path.to_s.split(File::SEPARATOR)[0..-2]
            path.each do |dir|
              data_branch[dir.to_sym] ||= {}
              data_branch = data_branch[dir.to_sym]
            end

            data_branch[basename.to_sym] = data
          end

          # Remove a given file from the internal cache
          #
          # @param [String] file The file to be cleared
          # @return [void]
          Contract IsA['Middleman::SourceFile'] => Any
          def remove_file(file)
            data_path = file[:relative_path]
            extension = File.extname(data_path)
            basename  = File.basename(data_path, extension)

            data_branch = @local_data

            path = data_path.to_s.split(File::SEPARATOR)[0..-2]
            path.each do |dir|
              data_branch = data_branch[dir.to_sym]
            end

            data_branch.delete(basename.to_sym) if data_branch.key?(basename.to_sym)
          end
        end
      end
    end
  end
end
