require 'rdoc/code_object'

##
# A Module include in a class with \#include

class RDoc::Include < RDoc::CodeObject

  ##
  # Name of included module

  attr_accessor :name

  ##
  # Creates a new Include for +name+ with +comment+

  def initialize(name, comment)
    super()
    @name = name
    self.comment = comment
  end

  def inspect # :nodoc:
    "#<%s:0x%x %s.include %s>" % [
      self.class,
      object_id,
      parent_name, @name,
    ]
  end

  ##
  # Attempts to locate the included module object.  Returns the name if not
  # known.

  def module
    RDoc::TopLevel.find_module_named(@name) || @name
  end

end

