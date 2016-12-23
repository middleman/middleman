# Template and Mime detection
require 'tilt'
require 'rack/mime'

require 'middleman-core/contracts'

module Middleman
  module Util
    include Contracts

    module_function

    # Whether the source file is binary.
    #
    # @param [String] filename The file to check.
    # @return [Boolean]
    Contract Or[String, Pathname] => Bool
    def binary?(filename)
      @binary_cache ||= {}

      return @binary_cache[filename] if @binary_cache.key?(filename)

      @binary_cache[filename] = begin
        path = Pathname(filename)
        ext = path.extname

        # We hardcode detecting of gzipped SVG files
        if ext == '.svgz'
          true
        elsif ::Tilt.registered?(ext.sub('.', ''))
          false
        else
          dot_ext = ext.to_s[0] == '.' ? ext.dup : ".#{ext}"

          if mime = ::Rack::Mime.mime_type(dot_ext, nil)
            !nonbinary_mime?(mime)
          else
            file_contents_include_binary_bytes?(path.to_s)
          end
        end
      end
    end

    # Is mime type known to be non-binary?
    #
    # @param [String] mime The mimetype to check.
    # @return [Boolean]
    Contract String => Bool
    def nonbinary_mime?(mime)
      if mime.start_with?('text/')
        true
      elsif mime.include?('xml') && !mime.include?('officedocument')
        true
      elsif mime.include?('json')
        true
      elsif mime.include?('javascript')
        true
      else
        false
      end
    end

    # Read a few bytes from the file and see if they are binary.
    #
    # @param [String] filename The file to check.
    # @return [Boolean]
    Contract String => Bool
    def file_contents_include_binary_bytes?(filename)
      binary_bytes = [0, 1, 2, 3, 4, 5, 6, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 31]
      s = ::File.read(filename, 4096) || ''
      s.each_byte do |c|
        return true if binary_bytes.include?(c)
      end

      false
    end
  end
end
