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

      YAML_ERRORS = [StandardError]

      # https://github.com/tenderlove/psych/issues/23
      if defined?(Psych) && defined?(Psych::SyntaxError)
        YAML_ERRORS << Psych::SyntaxError
      end

      # Get the frontmatter and plain content from a file
      # @param [String] path
      # @return [Array<Hash, String>]
      Contract Pathname, Maybe[Symbol] => [Hash, Maybe[String]]
      def parse(full_path, known_type=nil)
        data = {}

        return [data, nil] if ::Middleman::Util.binary?(full_path)

        # Avoid weird race condition when a file is renamed.
        content = begin
          File.read(full_path)
        rescue ::EOFError
        rescue ::IOError
        rescue ::Errno::ENOENT
          ''
        end

        begin
          if content =~ /\A.*coding:/
            lines = content.split(/\n/)
            lines.shift
            content = lines.join("\n")
          end

          if known_type
            if known_type == :yaml
              result = parse_yaml(content, full_path, true)
            elsif known_type == :json
              result = parse_json(content, full_path)
            end
          else
            result = parse_yaml(content, full_path, false)
          end

          return result if result
        rescue
          # Probably a binary file, move on
        end

        [data, content]
      end

      # Parse YAML frontmatter out of a string
      # @param [String] content
      # @return [Array<Hash, String>]
      Contract String, Pathname, Bool => Maybe[[Hash, String]]
      def parse_yaml(content, full_path, require_yaml=false)
        total_delims = content.scan(/^(?:---|\.\.\.)\s*(?:\n|$)/).length
        has_first_line_delim = !content.match(/\A(---\s*(?:\n|$))/).nil?
        # has_closing_delim = (total_delims > 1 && has_first_line_delim) || (!has_first_line_delim && total_delims == 1)

        parts = content.split(/^(?:---|\.\.\.)\s*(?:\n|$)/)
        parts.shift if parts[0].empty?

        yaml_string = nil
        additional_content = nil

        if require_yaml
          yaml_string = parts[0]
          additional_content = parts[1]
        else
          if total_delims > 1
            if has_first_line_delim
              yaml_string = parts[0]
              additional_content = parts[1]
            else
              additional_content = content
            end
          else
            additional_content = parts[0]
          end
        end

        return [{}, additional_content] if yaml_string.nil?

        begin
          data = map_value(::YAML.load(yaml_string) || {})
        rescue *YAML_ERRORS => e
          $stderr.puts "YAML Exception parsing #{full_path}: #{e.message}"
          return nil
        end

        [data, additional_content]
      rescue
        [{}, additional_content]
      end

      # Parse JSON frontmatter out of a string
      # @param [String] content
      # @return [Array<Hash, String>]
      Contract String, Pathname => Maybe[[Hash, String]]
      def parse_json(content, full_path)
        begin
          data = map_value(::JSON.parse(content))
        rescue => e
          $stderr.puts "JSON Exception parsing #{full_path}: #{e.message}"
          return nil
        end

        [data, nil]
      rescue
        [{}, nil]
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
