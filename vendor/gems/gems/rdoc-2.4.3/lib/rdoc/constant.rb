require 'rdoc/code_object'

##
# A constant

class RDoc::Constant < RDoc::CodeObject

  ##
  # The constant's name

  attr_accessor :name

  ##
  # The constant's value

  attr_accessor :value

  ##
  # Creates a new constant with +name+, +value+ and +comment+

  def initialize(name, value, comment)
    super()
    @name = name
    @value = value
    self.comment = comment
  end

  ##
  # Path to this constant

  def path
    "#{@parent.path}##{@name}"
  end

end

