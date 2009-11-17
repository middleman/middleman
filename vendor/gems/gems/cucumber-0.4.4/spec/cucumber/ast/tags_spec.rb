require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/tags'

module Cucumber
  module Ast
    describe Tags do
      describe "#matches" do
        it "should AND tags which are are in a list" do
          Tags.matches?(['@one','@two','@three'], [['@one','@two']]).should == true
          Tags.matches?(['@one','@three'], [['@one','@two']]).should == false
        end

        it "should OR tags in different lists" do
          Tags.matches?(['@one'], [['@one'], ['@two']]).should == true
        end

        it "should AND and OR tags" do
          Tags.matches?(['@one','@two'], [['@one'],['@two','@four']]).should == true
        end

        it "should NOT tags" do
          Tags.matches?(['@one','@three'], [['@one', '~@two']]).should == true
          Tags.matches?(['@one','@three'], [['~@one']]).should == false
        end

      end
    end
  end
end
