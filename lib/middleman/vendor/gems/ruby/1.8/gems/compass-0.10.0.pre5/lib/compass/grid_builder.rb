require 'zlib'

module Compass

  # A simple class to represent and create a PNG-File
  # No drawing features given
  # Just subclass and write [R,G,B]-Byte-Values into the <tt>@data</tt> matrix
  # Build for compactness, so not much error checking!
  #
  # Code based on seattlerb's png, see http://seattlerb.rubyforge.org/png/
  class PNG
    CRC_TABLE = (0..255).map do |n|
      (0...8).inject(n){|x,i| x = ((x & 1) == 1) ? 0xedb88320 ^ (x >> 1) : x >> 1}
    end

    class << self
      def crc(chunkdata='')
        chunkdata.unpack('C*').inject(0xffffffff){|crc, byte| CRC_TABLE[(crc ^ byte)  & 0xff] ^ (crc >> 8) } ^  0xffffffff
      end

      def chunk(type, data="")
        [data.size, type, data, crc(type + data)].pack("Na*a*N")
      end
    end

    # Initiates a new PNG-Object
    # * <tt>width</tt>: Width of the image in pixels
    # * <tt>height</tt>: Height of the image in pixels
    # * <tt>background</tt>: Background-color represented as [R,G,B]-Byte-Array
    def initialize(width, height, background = [255,255,255])
      @height = height
      @width = width
      @data = Array.new(@height) { |x| Array.new(@width, background) }
    end

    BITS    = 8
    RGB     = 2 # Color Types ( RGBA = 6)
    NONE    = 0 # Filter

    # binary representation of the PNG, write to file with binary mode
    def to_blob
      blob = []
      blob <<  [137, 80, 78, 71, 13, 10, 26, 10].pack("C*")
      blob << PNG.chunk('IHDR', [@width, @height, BITS, RGB, NONE, NONE, NONE].pack("N2C5"))
      blob << PNG.chunk('IDAT', Zlib::Deflate.deflate(self.png_join))
      blob << PNG.chunk('IEND', '')
      blob.join
    end

    def png_join
      @data.map { |row| "\0" + row.map { |p| "%c%c%c" % p}.join }.join
    end
  end

  class GridBuilder < PNG
    include Actions

    attr_reader :column_width, :gutter_width, :filename, :able_to_generate, :options

    # ==== Options
    # * <tt>options</tt>
    #   * <tt>:column_width</tt> -- Width (in pixels) of current grid column
    #   * <tt>:gutter_width</tt> -- Width (in pixels) of current grid gutter
    #   * <tt>:height</tt> -- Height (in pixels) of a row
    #   * <tt>:filename</tt> -- Output path of grid.png file
    def initialize(options={})
      @column_width = options[:column_width] || 0
      gutter_width = options[:gutter_width] || 0

      height = options[:height] || 20
      width = @column_width + gutter_width
      width = 10 if width == 0

      @filename = options[:filename]
      @options = options

      super(width, height, [0xe9,0xe9,0xe9])
    end

    def working_path
      options[:working_path]
    end

    # generates (overwriting if necessary) grid.png image to be tiled in background
    def generate!
      (0...@height-1).each do |line|
        @data[line] = Array.new(@width){|x| x < @column_width ? [0xe8, 0xef, 0xfb] : [0xff,0xff,0xff] }
      end

      if File.exists?(filename)
        if options[:force]
          overwrite = true
        else
          msg = "#{filename} already exists. Overwrite with --force."
          raise Compass::FilesystemConflict.new(msg)
        end
      end
      directory File.dirname(filename)
      write_file(filename, self.to_blob, options, true)
    end
  end
end
