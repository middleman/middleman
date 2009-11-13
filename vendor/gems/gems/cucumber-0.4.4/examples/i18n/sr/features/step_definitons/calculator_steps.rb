# encoding: utf-8
# require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Задати /унесен број (\d+) у калкулатор/ do |n|
  @calc.push n.to_i
end

Када /притиснем (\w+)/ do |op|
  @result = @calc.send op
end

Онда /би требало да буде (.*) прикаѕано на екрану/ do |result|
  @result.to_f == result.to_f
end
