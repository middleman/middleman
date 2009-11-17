# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calcolatrice'

Before do
  @calc = Calcolatrice.new
end

After do
end

Given /che ho inserito (\d+)/ do |n|
  @calc.push n.to_i
end

When 'premo somma' do
  @result = @calc.add
end

Then /il risultato deve essere (\d*)/ do |result|
  @result.should == result.to_i
end
