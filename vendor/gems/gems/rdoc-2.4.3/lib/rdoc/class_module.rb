require 'rdoc/context'

##
# ClassModule is the base class for objects representing either a class or a
# module.

class RDoc::ClassModule < RDoc::Context

  attr_accessor :diagram

  ##
  # Creates a new ClassModule with +name+ with optional +superclass+

  def initialize(name, superclass = 'Object')
    @diagram    = nil
    @full_name  = nil
    @name       = name
    @superclass = superclass
    super()
  end

  ##
  # Finds a class or module with +name+ in this namespace or its descendents

  def find_class_named(name)
    return self if full_name == name
    @classes.each_value {|c| return c if c.find_class_named(name) }
    nil
  end

  ##
  # Return the fully qualified name of this class or module

  def full_name
    @full_name ||= if RDoc::ClassModule === @parent then
                     "#{@parent.full_name}::#{@name}"
                   else
                     @name
                   end
  end

  ##
  # 'module' or 'class'

  def type
    module? ? 'module' : 'class'
  end

  ##
  # Does this object represent a module?

  def module?
    false
  end

  ##
  # Path to this class or module

  def path
    http_url RDoc::RDoc.current.generator.class_dir
  end

  ##
  # Get the superclass of this class.  Attempts to retrieve the superclass
  # object, returns the name if it is not known.

  def superclass
    raise NoMethodError, "#{full_name} is a module" if module?

    RDoc::TopLevel.find_class_named(@superclass) || @superclass
  end

  ##
  # Set the superclass of this class to +superclass+

  def superclass=(superclass)
    raise NoMethodError, "#{full_name} is a module" if module?

    @superclass = superclass if @superclass.nil? or @superclass == 'Object'
  end

  def to_s # :nodoc:
    "#{self.class}: #{full_name} #{@comment} #{super}"
  end

end

