require 'rdoc/class_module'

##
# A normal module, like NormalClass

class RDoc::NormalModule < RDoc::ClassModule

  ##
  # Appends +comment+ to the current comment, but separated by a rule

  def comment=(comment)
    return if comment.empty?
    comment = @comment << "\n# ---\n" << comment unless @comment.empty?

    super
  end

  def inspect # :nodoc:
    "#<%s:0x%x module %s includes: %p attributes: %p methods: %p aliases: %p>" % [
      self.class, object_id,
      full_name, @includes, @attributes, @method_list, @aliases
    ]
  end

  ##
  # This is a module, returns true

  def module?
    true
  end

end


