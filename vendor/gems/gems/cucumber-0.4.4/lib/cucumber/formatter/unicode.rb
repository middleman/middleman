# Require this file if you need Unicode support.
require 'cucumber/platform'
require 'cucumber/formatter/ansicolor'

$KCODE='u' unless Cucumber::RUBY_1_9

if Cucumber::WINDOWS_MRI && `chcp` =~ /(\d+)/
  codepage = $1.to_i
  codepages = (1251..1252)

  if codepages.include?(codepage)
    Cucumber::CODEPAGE = "cp#{codepage}"
  
    require 'iconv'
    module Kernel #:nodoc:
      alias cucumber_print print
      def print(*a)
        begin
          cucumber_print(*Iconv.iconv(Cucumber::CODEPAGE, "UTF-8", *a))
        rescue Iconv::IllegalSequence
          cucumber_print(*a)
        end
      end

      alias cucumber_puts puts
      def puts(*a)
        begin
          cucumber_puts(*Iconv.iconv(Cucumber::CODEPAGE, "UTF-8", *a))
        rescue Iconv::IllegalSequence
          cucumber_puts(*a)
        end
      end
    end
  end
end