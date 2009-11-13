# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'kalkulator'

Before do
  @calc = Kalkulator.new
end

After do
end

Given /att jag har knappat in (\d+)/ do |n|
  @calc.push n.to_i
end

When 'jag summerar' do
  @result = @calc.add
end

Then /ska resultatet vara (\d+)/ do |result|
  @result.should == result.to_i
end
