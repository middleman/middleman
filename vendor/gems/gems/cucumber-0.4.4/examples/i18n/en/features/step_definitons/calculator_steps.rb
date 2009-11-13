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

Given /I have entered (\d+) into the calculator/ do |n|
  @calc.push n.to_i
end

When /I press (\w+)/ do |op|
  @result = @calc.send op
end

Then /the result should be (.*) on the screen/ do |result|
  @result.should == result.to_f
end
