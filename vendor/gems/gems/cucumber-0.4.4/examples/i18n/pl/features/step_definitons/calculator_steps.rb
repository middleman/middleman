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

Zakładając /wprowadzenie do kalkulatora liczby (\d+)/ do |n|
  @calc.push n.to_i
end

Jeżeli /nacisnę (\w+)/ do |op|
  @result = @calc.send op
end

Wtedy /rezultat (.*) wyświetli się na ekranie/ do |result|
  @result.should == result.to_f
end
