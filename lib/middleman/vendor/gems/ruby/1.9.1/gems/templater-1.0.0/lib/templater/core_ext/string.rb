class String
  
  def realign_indentation
    basis = self.index(/\S/) # find the first non-whitespace character
    return self.to_lines.map { |s| s[basis..-1] }.join
  end

  if "".respond_to?(:lines)
    def to_lines
      lines.to_a
    end
  else
    def to_lines
      to_a
    end
  end
end
