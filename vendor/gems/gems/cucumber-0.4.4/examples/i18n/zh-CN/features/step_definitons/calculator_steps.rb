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

Given /我已经在计算器里输入(\d+)/ do |n|
  @calc.push n.to_i
end

When /我按(.*)按钮/ do |op|
  if op == '相加'
    @result = @calc.send "add"
  end
end

Then /我应该在屏幕上看到的结果是(.*)/ do |result|
  @result.should == result.to_f
end
