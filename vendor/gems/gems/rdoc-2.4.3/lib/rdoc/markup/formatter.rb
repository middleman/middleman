require 'rdoc/markup'

##
# Base class for RDoc markup formatters
#
# Formatters use a visitor pattern to convert content into output.

class RDoc::Markup::Formatter

  ##
  # Creates a new Formatter

  def initialize
    @markup = RDoc::Markup.new
  end

  ##
  # Marks up +content+

  def convert(content)
    @markup.convert content, self
  end

end

