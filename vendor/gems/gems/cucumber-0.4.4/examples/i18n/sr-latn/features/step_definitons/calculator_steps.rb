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

Zadato /Unesen (\d+) broj u kalkulator/ do |n|
  @calc.push n.to_i
end

Kada /pritisnem (\w+)/ do |op|
  @result = @calc.send op
end

Onda /bi trebalo da bude (.*) prikazano na ekranu/ do |result|
  @result.to_f == result.to_f
end
