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

Ha /^beütök a számológépbe egy (\d+)\-(?:es|as|ös|ás)t$/ do |n|
  @calc.push n.to_i
end

Majd /^megnyomom az? (\w+) gombot$/ do |op|
  @result = @calc.send op
end

Akkor /^eredményül (.*)\-(?:e|a|ö|á|)t kell kapnom$/ do |result|
  @result.should == result.to_f
end

