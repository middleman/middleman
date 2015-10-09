require 'yaml'
require 'json'

module Middleman
  module CoreExtensions
    module Data
      # Load data files
      class FileLoader
        # No parser available
        class NoFileLoaderFoundError < StandardError; end

        # Load yaml files
        class YamlFileLoader
          def match?(file)
            %w(.yaml .yml).include? File.extname(file)
          end

          # @param [Pathname] file
          def load(file)
            YAML.load_file(file)
          rescue Psych::SyntaxError, StandardError => e
            $stderr.puts %(Loading data file "#{file}" failed due to an error: #{e.message})
            {}
          end
        end

        # Load json files
        class JsonFileLoader
          def match?(file)
            '.json' == File.extname(file)
          end

          # @param [Pathname] file
          def load(file)
            JSON.parse(file.read)
          rescue => e
            $stderr.puts %(Loading data file "#{file}" failed due to an error: #{e.message})
            {}
          end
        end

        # Default loader
        #
        # Always fails
        class NilFileLoader
          def match?(file)
            raise NoFileLoaderFoundError
          end
        end

        private

        attr_reader :loaders

        public

        def initialize
          @loaders = []
          @loaders << YamlFileLoader.new
          @loaders << JsonFileLoader.new
          @loaders << NilFileLoader.new
        end

        # Load file using loader
        def load(file)
          loaders.find { |l| l.match? file }.load(file)
        end
      end
    end
  end
end
