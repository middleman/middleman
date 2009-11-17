require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Ast
    describe StepCollection do
      it "should convert And to Given in snippets" do
        s1 = Step.new(1, 'Given', 'cukes')
        s2 = Step.new(2, 'And', 'turnips')
        s1.stub!(:language).and_return(Parser::NaturalLanguage.get(nil, 'en'))
        s2.stub!(:language).and_return(Parser::NaturalLanguage.get(nil, 'en'))
        c = StepCollection.new([s1, s2])
        actual_keywords = c.step_invocations.map{|i| i.actual_keyword}
        actual_keywords.should == %w{Given Given}
      end
    end
  end
end
