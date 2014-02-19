class E
  def self.fields
    @fields ||= []
  end

  def self.inherited(subclass)
    subclass.fields.replace fields.dup
  end

  G

  fields << "name"
end
