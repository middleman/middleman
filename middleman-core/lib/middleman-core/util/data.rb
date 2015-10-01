require 'yaml'
require 'json'
require 'pathname'
require 'middleman-core/util'
require 'middleman-core/contracts'
require 'backports/2.1.0/array/to_h'

module Middleman::Util::Data
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

    /
      \A(?:[^\r\n]*coding:[^\r\n]*\r?\n)?
      (?<start>---|;;;)[ ]*\r?\n
      (?<frontmatter>.*?)[ ]*\r?\n?
      ^(?<stop>---|\.\.\.|;;;)[ ]*\r?\n?
      \r?\n?
      (?<additional_content>.*)
    /mx =~ content

    unless frontmatter
      case known_type
      when :yaml
        return [parse_yaml(content, full_path), nil]
      when :json
        return [parse_json(content, full_path), nil]
      end
    end

    case [start, stop]
    when %w(--- ---), %w(--- ...)
      [parse_yaml(frontmatter, full_path), additional_content]
    when %w(;;; ;;;)
      [parse_json("{#{frontmatter}}", full_path), additional_content]
    else
      [{}, content]
    end
  end

  # Parse YAML frontmatter out of a string
  # @param [String] content
  # @return [Hash]
  Contract String, Pathname, Bool => Hash
  def parse_yaml(content, full_path)
    symbolize_recursive(YAML.load(content) || {})
  rescue StandardError, Psych::SyntaxError => error
    warn "YAML Exception parsing #{full_path}: #{error.message}"
    {}
  end

  # Parse JSON frontmatter out of a string
  # @param [String] content
  # @return [Hash]
  Contract String, Pathname => Hash
  def parse_json(content, full_path)
    symbolize_recursive(JSON.parse(content) || {})
  rescue StandardError => error
    warn "JSON Exception parsing #{full_path}: #{error.message}"
    {}
  end

  def symbolize_recursive(value)
    case value
    when Hash
      value.map { |k, v| [k.to_sym, symbolize_recursive(v)] }.to_h
    when Array
      value.map { |v| symbolize_recursive(v) }
    else
      value
    end
  end
end
