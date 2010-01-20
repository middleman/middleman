class String
  unless method_defined?(:blank?)
    # see if string has any content
    def blank?; self.length.zero?; end
  end
end

class NilClass
  unless method_defined?(:blank?)
    def blank?
      true
    end
  end
end
