class Pathname
  class << self
    def for(path)
      path.is_a?(Pathname) ? path : new(path)
    end
  end
  
  # before overwriting chop_basename:
  #   %total - 29.50%
  #   %self - 20.50%
  # after overwriting chop_basename:
  #   %total - 24.36%
  #   %self - 15.47%
  CHOP_PAT = /\A#{SEPARATOR_PAT}?\z/
  def chop_basename(path)
    base = File.basename(path)
    # the original version of this method recalculates this regexp
    # each run, despite the pattern never changing.
    if CHOP_PAT =~ base
      return nil
    else
      return path[0, path.rindex(base)], base
    end
  end
  
  def segments
    prefix, names = split_names(@path)
    names.unshift(prefix) unless prefix.empty?
    names.shift if names[0] == '.'
    names
  end
  
  def names
    prefix, names = split_names(@path)
    names
  end
end
