# frozen_string_literal: true

require 'yaml'
require 'json'
require 'pathname'
require 'hashie'
require 'memoist'

require 'middleman-core/util/binary'
require 'middleman-core/contracts'

module Middleman
  module Util
    include Contracts

    module_function

    class EnhancedHash < ::Hashie::Mash
      # include ::Hashie::Extensions::MergeInitializer
      # include ::Hashie::Extensions::MethodReader
      # include ::Hashie::Extensions::IndifferentAccess
    end

    # Recursively convert a normal Hash into a EnhancedHash
    #
    # @private
    # @param [Hash] data Normal hash
    # @return [Hash]
    Contract Hash => IsA['::Middleman::Util::EnhancedHash']
    def recursively_enhance(obj)
      case obj
      when ::Array
        obj.map { |e| recursively_enhance(e) }
      when ::Hash
        EnhancedHash.new(obj)
      else
        obj
      end
    end

    module Data
      extend Memoist
      include Contracts

      module_function

      # Get the frontmatter and plain content from a file
      # @param [String] path
      # @return [Array<Hash, String>]
      Contract IsA['Middleman::SourceFile'], Maybe[Symbol] => [Hash, Maybe[String]]
      def parse(source_file, frontmatter_delims, known_type = nil)
        full_path = source_file[:full_path]

        return [{}, nil] if ::Middleman::Util.binary?(full_path) || source_file[:types].include?(:binary)

        # Avoid weird race condition when a file is renamed
        begin
          content = source_file.read
        rescue EOFError, IOError, ::Errno::ENOENT
          return [{}, nil]
        end

        match = build_regexes(frontmatter_delims)
                .lazy
                .map { |r| r.match(content) }
                .reject(&:nil?)
                .first || {}

        unless match[:frontmatter]
          case known_type
          when :yaml
            return [parse_yaml(content, full_path), nil]
          when :json
            return [parse_json(content, full_path), nil]
          end
        end

        case [match[:start], match[:stop]]
        when *frontmatter_delims[:yaml]
          [
            parse_yaml(match[:frontmatter], full_path),
            match[:additional_content]
          ]
        when *frontmatter_delims[:json]
          [
            parse_json("{#{match[:frontmatter]}}", full_path),
            match[:additional_content]
          ]
        else
          [
            {},
            content
          ]
        end
      end

      def build_regexes(frontmatter_delims)
        frontmatter_delims
          .values
          .flatten(1)
          .map do |start, stop|
          /
            \A(?:[^\r\n]*coding:[^\r\n]*\r?\n)?
            (?<start>#{Regexp.escape(start)})[ ]*\r?\n
            (?<frontmatter>.*?)[ ]*\r?\n?
            ^(?<stop>#{Regexp.escape(stop)})[ ]*\r?\n?
            \r?\n?
            (?<additional_content>.*)
          /mx
        end
      end
      memoize :build_regexes

      # Parse YAML frontmatter out of a string
      # @param [String] content
      # @return [Hash]
      Contract String, Pathname => Hash
      def parse_yaml(content, full_path)
        c = begin
          ::Middleman::Util.instrument 'parse.yaml' do
            ::YAML.load(content)
          end
        rescue StandardError, ::Psych::SyntaxError => e
          warn "YAML Exception parsing #{full_path}: #{e.message}"
          {}
        end

        c ? symbolize_recursive(c) : {}
      end
      memoize :parse_yaml

      # Parse JSON frontmatter out of a string
      # @param [String] content
      # @return [Hash]
      Contract String, Pathname => Hash
      def parse_json(content, full_path)
        c = begin
          ::Middleman::Util.instrument 'parse.json' do
            ::JSON.parse(content)
          end
        rescue StandardError => e
          warn "JSON Exception parsing #{full_path}: #{e.message}"
          {}
        end

        c ? symbolize_recursive(c) : {}
      end
      memoize :parse_json

      def symbolize_recursive(value)
        case value
        when Hash
          value.map do |k, v|
            key = k.is_a?(String) ? k.to_sym : k
            [key, symbolize_recursive(v)]
          end.to_h
        when Array
          value.map { |v| symbolize_recursive(v) }
        else
          value
        end
      end
    end
  end
end
