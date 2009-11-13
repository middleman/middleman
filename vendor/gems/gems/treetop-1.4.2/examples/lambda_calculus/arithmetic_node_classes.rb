module Arithmetic
  class BinaryOperation < Treetop::Runtime::SyntaxNode
    def eval(env={})
      operator.apply(operand_1.eval(env), operand_2.eval(env))      
    end
  end
end