# Core Pathname library used for traversal
require 'pathname'

# DbC
require 'middleman-core/contracts'

# Shared util methods
require 'middleman-core/util'

# Parsing YAML data
require 'yaml'

# Parsing JSON data
require 'json'

module Middleman
  module Util
    module Data
      include Contracts

      module_function

      # Get the frontmatter and plain content from a file
      # @param [String] path
      # @return [Array<Hash, String>]
      Contract Pathname, Maybe[Symbol] => [Hash, Maybe[String]]
      def parse(full_path, known_type=nil)
        return [{}, nil] if Middleman::Util.binary?(full_path)

        # Avoid weird race condition when a file is renamed
        begin
          content = File.read(full_path)
        rescue EOFError, IOError, Errno::ENOENT
          return [{}, nil]
        end

        case known_type
        when :yaml
          return [parse_yaml(content, full_path), nil]
        when :json
          return [parse_json(content, full_path), nil]
        end

        /
          (?<start>^[-;]{3})[ ]*\r?\n
          (?<frontmatter>.*?)[ ]*\r?\n
          (?<stop>^[-.;]{3})[ ]*\r?\n?
          (?<additional_content>.*)
        /mx =~ content

        return [{}, content] unless frontmatter

        case [start, stop]
        when %w[--- ---], %w[--- ...]
          [parse_yaml(frontmatter, full_path), additional_content]
        when %w[;;; ;;;]
          [parse_json(frontmatter, full_path), additional_content]
        else
          [{}, content]
        end
      end

      # Parse YAML frontmatter out of a string
      # @param [String] content
      # @return [Array<Hash, String>]
      Contract String, Pathname, Bool => Hash
      def parse_yaml(content, full_path)
        map_value(YAML.load(content))
      rescue StandardError, Psych::SyntaxError => error
        warn "YAML Exception parsing #{full_path}: #{error.message}"
        {}
      end

      # Parse JSON frontmatter out of a string
      # @param [String] content
      # @return [Array<Hash, String>]
      Contract String, Pathname => Hash
      def parse_json(content, full_path)
        map_value(JSON.parse(content))
      rescue StandardError => error
        warn "JSON Exception parsing #{full_path}: #{error.message}"
        {}
      end

      def symbolize_recursive(hash)
        {}.tap do |h|
          hash.each { |key, value| h[key.to_sym] = map_value(value) }
        end
      end

      def map_value(thing)
        case thing
        when Hash
          symbolize_recursive(thing)
        when Array
          thing.map { |v| map_value(v) }
        else
          thing
        end
      end
    end
  end
end
