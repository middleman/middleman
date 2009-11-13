# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculador'

Before do
  @calc = Calculador.new
end

Dado /que he introducido (\d+) en la calculadora/ do |n|
  @calc.push n.to_i
end

Cuando /oprimo el (\w+)/ do |op|
  @result = @calc.send op
end

Entonces /el resultado debe ser (.*) en la pantalla/ do |result|
  @result.should == result.to_f
end