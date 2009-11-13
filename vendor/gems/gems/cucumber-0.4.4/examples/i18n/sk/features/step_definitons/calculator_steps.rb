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

Given /Zadám číslo (\d+) do kalkulačky/ do |n|
  @calc.push n.to_i
end

When /Stlačím tlačidlo (\w+)/ do |op|
  @result = @calc.send op
end

Then /Výsledok by mal byť (.*)/ do |result|
  @result.should == result.to_f
end
