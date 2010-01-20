module BeApproximatelyTheSameColorAsMatcher
  class BeApproximatelyTheSameColorAs
    def initialize(expected)
      @expected = expected
    end

    def matches?(target)
      @target = target
      @target.rgb.zip(@expected.rgb).all?{|e,t| (e-t).abs <= 1}
    end

    def failure_message
      "expected <#{to_string(@target)}> to " +
      "be approximately the same as <#{to_string(@expected)}>"
    end

    def negative_failure_message
      "expected <#{to_string(@target)}> not to " +
      "be approximately the same as <#{to_string(@expected)}>"
    end

    # Returns string representation of an object.
    def to_string(value)
      # indicate a nil
      if value.nil?
        'nil'
      end

      # join arrays
      if value.class == Array
        return value.join(", ")
      end

      # otherwise return to_s() instead of inspect()
      return value.to_s
    end
  end

  # Actual matcher that is exposed.
  def be_approximately_the_same_color_as(expected)
    BeApproximatelyTheSameColorAs.new(expected)
  end
end