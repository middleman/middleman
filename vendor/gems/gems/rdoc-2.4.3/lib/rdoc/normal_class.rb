require 'rdoc/class_module'

##
# A normal class, neither singleton nor anonymous

class RDoc::NormalClass < RDoc::ClassModule

  def inspect # :nodoc:
    superclass = @superclass ? " < #{@superclass}" : nil
    "<%s:0x%x class %s%s includes: %p attributes: %p methods: %p aliases: %p>" % [
      self.class, object_id,
      full_name, superclass, @includes, @attributes, @method_list, @aliases
    ]
  end

end


