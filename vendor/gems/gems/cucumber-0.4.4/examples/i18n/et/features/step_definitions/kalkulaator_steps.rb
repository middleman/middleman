# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'kalkulaator'

Before do
  @calc = Kalkulaator.new
end

After do
end

Given /olen sisestanud kalkulaatorisse numbri (\d+)/ do |n|
  @calc.push n.to_i
end

When /ma vajutan (\w+)/ do |op|
  @result = @calc.send op
end

Then /vastuseks peab ekraanil kuvatama (.*)/ do |result|
  @result.should == result.to_f
end
