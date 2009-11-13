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

Given "كتابة $n في الآلة الحاسبة" do |n|
  @calc.push n.to_i
end

When /يتم الضغط على (\w+)/ do |op|
  @result = @calc.send op
end

Then /يظهر (.*) على الشاشة/ do |result|
  @result.should == result.to_f
end
