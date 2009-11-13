$:.unshift File.dirname(__FILE__)
require "rubygems"
gem "rdoc", ">= 2.4.2"

require "rdoc/rdoc"

module SDoc
end

require "sdoc/generator/shtml"
require "sdoc/c_parser_fix"

unless defined? SDOC_FIXED_RDOC_OPTIONS
  SDOC_FIXED_RDOC_OPTIONS = 1
  class RDoc::Options
    alias_method :rdoc_initialize, :initialize
  
    def initialize
      rdoc_initialize
      @generator = RDoc::Generator::SHtml
    end
  end
end
