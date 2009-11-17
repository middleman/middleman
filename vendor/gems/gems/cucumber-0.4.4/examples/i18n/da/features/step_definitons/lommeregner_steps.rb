# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'lommeregner'

Before do
  @calc = Lommeregner.new
end

After do
end

Given /at jeg har indtastet (\d+)/ do |n|
  @calc.push n.to_i
end

When 'jeg lægger sammen' do
  @result = @calc.add
end

Then /skal resultatet være (\d*)/ do |result|
  @result.should == result.to_i
end
