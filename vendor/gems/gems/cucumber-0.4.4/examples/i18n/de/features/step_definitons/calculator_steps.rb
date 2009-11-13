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

Given /ich habe (\d+) in den Taschenrechner eingegeben/ do |n|
  @calc.push n.to_i
end

When /ich (\w+) drücke/ do |op|
  @result = @calc.send op
end

Then /sollte das Ergebniss auf dem Bildschirm (.*) sein/ do |result|
  @result.should == result.to_f
end
