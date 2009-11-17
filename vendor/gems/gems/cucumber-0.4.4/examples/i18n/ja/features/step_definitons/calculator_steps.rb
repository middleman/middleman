# encoding: UTF-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given "$n を入力" do |n|
  @calc.push n.to_i
end

When /(\w+) を押した/ do |op|
  @result = @calc.send op
end

Then /(.*) を表示/ do |result|
  @result.should == result.to_f
end
