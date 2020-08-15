# frozen_string_literal: true

# Template and Mime detection
require 'tilt'
require 'rack/mime'
require 'set'

require 'middleman-core/contracts'

KNOWN_NON_STATIC_FILE_EXTENSIONS = Set.new %w[
  css
  js
  mjs
  html
  htm
  php
]

KNOWN_BINARY_FILE_EXTENSIONS = Set.new %w[
  3dm
  3ds
  3g2
  3gp
  7z
  a
  aac
  adp
  ai
  aif
  aiff
  alz
  ape
  apk
  ar
  arj
  asf
  au
  avi
  bak
  baml
  bh
  bin
  bk
  bmp
  btif
  bz2
  bzip2
  cab
  caf
  cgm
  class
  cmx
  cpio
  cr2
  csv
  cur
  dat
  dcm
  deb
  dex
  djvu
  dll
  dmg
  dng
  doc
  docm
  docx
  dot
  dotm
  dra
  DS_Store
  dsk
  dts
  dtshd
  dvb
  dwg
  dxf
  ecelp4800
  ecelp7470
  ecelp9600
  egg
  eol
  eot
  epub
  exe
  f4v
  fbs
  fh
  fla
  flac
  fli
  flv
  fpx
  fst
  fvt
  g3
  gh
  gif
  graffle
  gz
  gzip
  h261
  h263
  h264
  icns
  ico
  ief
  img
  ipa
  iso
  jar
  jpeg
  jpg
  jpgv
  jpm
  jxr
  key
  ktx
  lha
  lib
  lvp
  lz
  lzh
  lzma
  lzo
  m3u
  m4a
  m4v
  mar
  mdi
  mht
  mid
  midi
  mj2
  mka
  mkv
  mmr
  mng
  mobi
  mov
  movie
  mp3
  mp4
  mp4a
  mpeg
  mpg
  mpga
  mxu
  nef
  npx
  numbers
  o
  oga
  ogg
  ogv
  otf
  pages
  pbm
  pcx
  pdb
  pdf
  pea
  pgm
  pic
  png
  pnm
  pot
  potm
  potx
  ppa
  ppam
  ppm
  pps
  ppsm
  ppsx
  ppt
  pptm
  pptx
  psd
  pya
  pyc
  pyo
  pyv
  qt
  rar
  ras
  raw
  resources
  rgb
  rip
  rlc
  rmf
  rmvb
  rtf
  rz
  s3m
  s7z
  scpt
  sgi
  shar
  sil
  sketch
  slk
  smv
  so
  stl
  sub
  svgz
  swf
  tar
  tbz
  tbz2
  tga
  tgz
  thmx
  tif
  tiff
  tlz
  ttc
  ttf
  txz
  udf
  uvh
  uvi
  uvm
  uvp
  uvs
  uvu
  viv
  vob
  war
  wav
  wax
  wbmp
  wdp
  weba
  webm
  webp
  whl
  wim
  wm
  wma
  wmv
  wmx
  woff
  woff2
  wrm
  wvx
  xbm
  xif
  xla
  xlam
  xls
  xlsb
  xlsm
  xlsx
  xlt
  xltm
  xltx
  xm
  xmind
  xpi
  xpm
  xwd
  xz
  z
  zip
  zipx
]

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
        without_dot = ext.sub('.', '')

        # We hardcode detecting of gzipped SVG files
        if KNOWN_BINARY_FILE_EXTENSIONS.include?(without_dot)
          true
        elsif ::Tilt.registered?(without_dot)
          false
        else
          dot_ext = ext.to_s[0] == '.' ? ext.dup : ".#{ext}"

          mime = ::Rack::Mime.mime_type(dot_ext, nil)

          if mime
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

    Contract String, Maybe[HashOf[Symbol, Any]] => Bool
    def static_file?(path, frontmatter_delims)
      path = Pathname(path)
      ext = path.extname
      without_dot = ext.sub('.', '')

      if KNOWN_NON_STATIC_FILE_EXTENSIONS.include?(without_dot) || contains_frontmatter?(path, frontmatter_delims)
        false
      else
        !::Tilt.registered?(without_dot)
      end
    end

    Contract String, Maybe[HashOf[Symbol, Any]] => Bool
    def contains_frontmatter?(path, frontmatter_delims)
      file = ::File.open(path)
      first_line = file.gets

      first_line = file.gets if /\A(?:[^\r\n]*coding:[^\r\n]*\r?\n)/.match?(first_line)

      file.close

      possible_openers = possible_delim_openers(frontmatter_delims)
      !first_line.nil? && !first_line.match(possible_openers).nil?
    rescue EOFError, IOError, ::Errno::ENOENT
      false
    end

    Contract Maybe[HashOf[Symbol, Any]] => Regexp
    def possible_delim_openers(frontmatter_delims)
      all_possible = frontmatter_delims
                     .values
                     .flatten(1)
                     .map(&:first)
                     .uniq

      /\A#{::Regexp.union(all_possible)}/
    end
  end
end
