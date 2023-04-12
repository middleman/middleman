require 'yaml'
require 'json'
require 'toml'
require 'pathname'
require 'backports/2.1.0/array/to_h'
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
    Contract Any => Maybe[Or[Array, EnhancedHash]]
    def recursively_enhance(obj)
      if obj.is_a? ::Array
        obj.map { |e| recursively_enhance(e) }
      elsif obj.is_a? ::Hash
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
      def parse(file, frontmatter_delims, known_type=nil)
        full_path = file[:full_path]
        return [{}, nil] if ::Middleman::Util.binary?(full_path) || file[:types].include?(:binary)

        # Avoid weird race condition when a file is renamed
        begin
          content = file.read
        rescue EOFError, IOError, ::Errno::ENOENT
          return [{}, nil]
        end

        match = build_regex(frontmatter_delims).match(content) || {}

        unless match[:frontmatter]
          case known_type
          when :yaml
            return [parse_yaml(content, full_path), nil]
          when :json
            return [parse_json(content, full_path), nil]
          when :toml
            return [parse_toml(content, full_path), nil]
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
        when *frontmatter_delims[:toml]
          [
            parse_toml(match[:frontmatter], full_path),
            match[:additional_content]
          ]
        else
          [
            {},
            content
          ]
        end
      end

      def build_regex(frontmatter_delims)
        start_delims, stop_delims = frontmatter_delims
                                    .values
                                    .flatten(1)
                                    .transpose
                                    .map(&::Regexp.method(:union))

        /
          \A(?:[^\r\n]*coding:[^\r\n]*\r?\n)?
          (?<start>#{start_delims})[ ]*\r?\n
          (?<frontmatter>.*?)[ ]*\r?\n?
          ^(?<stop>#{stop_delims})[ ]*\r?\n?
          \r?\n?
          (?<additional_content>.*)
        /mx
      end
      memoize :build_regex

      # Parse YAML frontmatter out of a string
      # @param [String] content
      # @return [Hash]
      Contract String, Pathname => Hash
      def parse_yaml(content, full_path)
        permitted_classes = [Date, Symbol]
        c = begin
          ::Middleman::Util.instrument 'parse.yaml' do
            allowed_parameters = ::YAML.method(:safe_load).parameters
            if allowed_parameters.include? [:key, :permitted_classes]
              ::YAML.safe_load(content, permitted_classes: permitted_classes)
            elsif allowed_parameters.include? [:key, :whitelist_classes]
              ::YAML.safe_load(content, whitelist_classes: permitted_classes)
            else
              ::YAML.safe_load(content, permitted_classes)
            end
          end
        rescue StandardError, ::Psych::SyntaxError => error
          warn "YAML Exception parsing #{full_path}: #{error.message}"
          {}
        end
      
        c ? symbolize_recursive(c) : {}
      end
      memoize :parse_yaml
      
      # Parse TOML frontmatter out of a string
      # @param [String] content
      # @return [Hash]
      Contract String, Pathname => Hash
      def parse_toml(content, full_path)
        c = begin
          ::Middleman::Util.instrument 'parse.toml' do
            ::TOML.load(content)
          end
        rescue StandardError
          # TOML parser swallows useful error, so we can't warn about it.
          # https://github.com/jm/toml/issues/47
          warn "TOML Exception parsing #{full_path}"
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
        rescue StandardError => error
          warn "JSON Exception parsing #{full_path}: #{error.message}"
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
