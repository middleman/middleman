require 'test_helper'
require 'fileutils'

class CommandLineTest < Test::Unit::TestCase
  
  def test_class_crc_table  
    assert_equal 256, Compass::PNG::CRC_TABLE.length 
    {0 => 0, 1 => 1996959894, 22 => 4107580753, 133 => 2647816111, 255 => 755167117}.each do |i, crc| 
      assert_equal crc, Compass::PNG::CRC_TABLE[i]
    end
  end                  

  def test_class_crc
    assert_equal 2666930069, Compass::PNG.crc('foobar')
    assert_equal 2035837995, Compass::PNG.crc('A721dasdN')
  end

  def test_class_chunk
    chunk = Compass::PNG.chunk 'IHDR', [10, 10, 8, 6, 0, 0, 0 ].pack('N2C5')

    header_crc = "\2152\317\275"
    header_data = "\000\000\000\n\000\000\000\n\b\006\000\000\000"
    header_length = "\000\000\000\r"

    header_chunk = "#{header_length}IHDR#{header_data}#{header_crc}"

    assert_equal header_chunk, chunk
  end

  def test_class_chunk_empty
    chunk = Compass::PNG.chunk 'IHDR'
    expected = "#{0.chr * 4}IHDR#{[Compass::PNG.crc("IHDR")].pack 'N'}"
    assert_equal expected, chunk
  end

  def test_to_blob
    png = Compass::PNG.new(5,10, [255,255,255])
    blob = 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAKCAIAAADzWwNnAAAAD0lEQVR4nGP4jwoYBhkfALRylWv4Dj0LAAAAAElFTkSuQmCC'.unpack('m*').first
    assert_equal blob, png.to_blob  
    
    png = Compass::PNG.new(10,5, [32,64,128])
    blob = 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAFCAIAAADzBuo/AAAAEUlEQVR4nGNQcGjAgxgGUBoALT4rwRTA0gkAAAAASUVORK5CYII='.unpack('m*').first
    assert_equal blob, png.to_blob  
  end
  
end