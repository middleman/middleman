require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/markup_app/app')

describe "NumberHelpers" do
  include Padrino::Helpers::NumberHelpers

  def kilobytes(number)
    number * 1024
  end

  def megabytes(number)
    kilobytes(number) * 1024
  end

  def gigabytes(number)
    megabytes(number) * 1024
  end

  def terabytes(number)
    gigabytes(number) * 1024
  end

  context 'for number helpers functionality' do

    should 'display number_to_currency' do
      assert_equal "$1,234,567,890.50",        number_to_currency(1234567890.50)
      assert_equal "$1,234,567,890.51",        number_to_currency(1234567890.506)
      assert_equal "$1,234,567,892",           number_to_currency(1234567891.50, {:precision => 0})
      assert_equal "$1,234,567,890.5",         number_to_currency(1234567890.50, {:precision => 1})
      assert_equal "&pound;1234567890,50",     number_to_currency(1234567890.50, {:unit => "&pound;", :separator => ",", :delimiter => ""})
      assert_equal "$1,234,567,890.50",        number_to_currency("1234567890.50")
      assert_equal "1,234,567,890.50 K&#269;", number_to_currency("1234567890.50", {:unit => "K&#269;", :format => "%n %u"})
      assert_equal "$x",                       number_to_currency("x")

      assert_nil number_to_currency(nil)
    end

    should 'display  number_to_percentage' do
      assert_equal "100.000%",   number_to_percentage(100)
      assert_equal "100%",       number_to_percentage(100, {:precision => 0})
      assert_equal "302.06%",    number_to_percentage(302.0574, {:precision => 2})
      assert_equal "100.000%",   number_to_percentage("100")
      assert_equal "1000.000%",  number_to_percentage("1000")
      assert_equal "x%",         number_to_percentage("x")
      assert_equal "1.000,000%", number_to_percentage(1000, :delimiter => '.', :separator => ',')

      assert_nil number_to_percentage(nil)
    end

    should 'display  number_with_delimiter' do
      assert_equal "12,345,678",        number_with_delimiter(12345678)
      assert_equal "0",                 number_with_delimiter(0)
      assert_equal "123",               number_with_delimiter(123)
      assert_equal "123,456",           number_with_delimiter(123456)
      assert_equal "123,456.78",        number_with_delimiter(123456.78)
      assert_equal "123,456.789",       number_with_delimiter(123456.789)
      assert_equal "123,456.78901",     number_with_delimiter(123456.78901)
      assert_equal "123,456,789.78901", number_with_delimiter(123456789.78901)
      assert_equal "0.78901",           number_with_delimiter(0.78901)
      assert_equal "123,456.78",        number_with_delimiter("123456.78")
      assert_equal "x",                 number_with_delimiter("x")

      assert_nil number_with_delimiter(nil)
    end

    should 'display number_with_delimiter with options' do
      assert_equal '12 345 678',    number_with_delimiter(12345678, :delimiter => ' ')
      assert_equal '12,345,678-05', number_with_delimiter(12345678.05, :separator => '-')
      assert_equal '12.345.678,05', number_with_delimiter(12345678.05, :separator => ',', :delimiter => '.')
      assert_equal '12.345.678,05', number_with_delimiter(12345678.05, :delimiter => '.', :separator => ',')
    end

    should 'display number_with_precision' do
      assert_equal "111.235",    number_with_precision(111.2346)
      assert_equal "31.83",      number_with_precision(31.825, :precision => 2)
      assert_equal "111.23",     number_with_precision(111.2346, :precision => 2)
      assert_equal "111.00",     number_with_precision(111, :precision => 2)
      assert_equal "111.235",    number_with_precision("111.2346")
      assert_equal "31.83",      number_with_precision("31.825", :precision => 2)
      assert_equal "3268",       number_with_precision((32.6751 * 100.00), :precision => 0)
      assert_equal "112",        number_with_precision(111.50, :precision => 0)
      assert_equal "1234567892", number_with_precision(1234567891.50, :precision => 0)

      # Return non-numeric params unchanged.
      assert_equal "x", number_with_precision("x")
      assert_nil number_with_precision(nil)
    end

    should 'display number_with_precision with custom delimiter and separator' do
      assert_equal '31,83',     number_with_precision(31.825, :precision => 2, :separator => ',')
      assert_equal '1.231,83',  number_with_precision(1231.825, :precision => 2, :separator => ',', :delimiter => '.')
    end

    should 'display number_to_human_size' do
      assert_equal '0 Bytes',   number_to_human_size(0)
      assert_equal '1 Byte',    number_to_human_size(1)
      assert_equal '3 Bytes',   number_to_human_size(3.14159265)
      assert_equal '123 Bytes', number_to_human_size(123.0)
      assert_equal '123 Bytes', number_to_human_size(123)
      assert_equal '1.2 KB',    number_to_human_size(1234)
      assert_equal '12.1 KB',   number_to_human_size(12345)
      assert_equal '1.2 MB',    number_to_human_size(1234567)
      assert_equal '1.1 GB',    number_to_human_size(1234567890)
      assert_equal '1.1 TB',    number_to_human_size(1234567890123)
      assert_equal '1025 TB',   number_to_human_size(terabytes(1025))
      assert_equal '444 KB',    number_to_human_size(kilobytes(444))
      assert_equal '1023 MB',   number_to_human_size(megabytes(1023))
      assert_equal '3 TB',      number_to_human_size(terabytes(3))
      assert_equal '1.18 MB',   number_to_human_size(1234567, :precision => 2)
      assert_equal '3 Bytes',   number_to_human_size(3.14159265, :precision => 4)
      assert_equal '123 Bytes', number_to_human_size("123")
      assert_equal '1.01 KB',   number_to_human_size(kilobytes(1.0123), :precision => 2)
      assert_equal '1.01 KB',   number_to_human_size(kilobytes(1.0100), :precision => 4)
      assert_equal '10 KB',     number_to_human_size(kilobytes(10.000), :precision => 4)
      assert_equal '1 Byte',    number_to_human_size(1.1)
      assert_equal '10 Bytes',  number_to_human_size(10)

      assert_nil number_to_human_size(nil)
    end

    should 'display number_to_human_size with options' do
      assert_equal '1.18 MB', number_to_human_size(1234567, :precision => 2)
      assert_equal '3 Bytes', number_to_human_size(3.14159265, :precision => 4)
      assert_equal '1.01 KB', number_to_human_size(kilobytes(1.0123), :precision => 2)
      assert_equal '1.01 KB', number_to_human_size(kilobytes(1.0100), :precision => 4)
      assert_equal '10 KB',   number_to_human_size(kilobytes(10.000), :precision => 4)
      assert_equal '1 TB',    number_to_human_size(1234567890123, :precision => 0)
      assert_equal '500 MB',  number_to_human_size(524288000, :precision => 0)
      assert_equal '40 KB',   number_to_human_size(41010, :precision => 0)
      assert_equal '40 KB',   number_to_human_size(41100, :precision => 0)
    end

    should 'display number_to_human_size with custom delimiter and separator' do
      assert_equal '1,01 KB',     number_to_human_size(kilobytes(1.0123), :precision => 2, :separator => ',')
      assert_equal '1,01 KB',     number_to_human_size(kilobytes(1.0100), :precision => 4, :separator => ',')
      assert_equal '1.000,1 TB',  number_to_human_size(terabytes(1000.1), :delimiter => '.', :separator => ',')
    end
  end
end
