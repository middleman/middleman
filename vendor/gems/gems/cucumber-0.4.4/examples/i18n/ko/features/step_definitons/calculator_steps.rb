# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given /^계산기에 (.*)을 입력했음$/ do |n|
  @calc.push n.to_i
end

When /^내가 (.*)를 누르면$/ do |op|
  @result = @calc.send op
end

Then /^화면에 출력된 결과는 (.*)이다$/ do |result|
  @result.should == result.to_f
end
