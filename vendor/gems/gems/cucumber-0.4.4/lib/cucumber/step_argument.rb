module Cucumber
  class StepArgument
    attr_reader :val, :pos

    def initialize(val, pos)
      @val, @pos = val, pos
    end
  end
end