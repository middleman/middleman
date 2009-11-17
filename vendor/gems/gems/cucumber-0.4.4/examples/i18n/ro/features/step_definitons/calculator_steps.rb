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

Given /introduc (\d+)/ do |n|
  @calc.push n.to_i
end

When 'apas suma' do
  @result = @calc.add
end

Then /rezultatul trebuie sa fie (\d*)/ do |result|
  @result.should == result.to_i
end
