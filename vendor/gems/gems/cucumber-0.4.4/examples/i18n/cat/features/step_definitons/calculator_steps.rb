# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculadora'

Before do
  @calc = Calculadora.new
end

Donat /que he introduït (\d+) a la calculadora/ do |n|
  @calc.push n.to_i
end

Quan /premo el (\w+)/ do |op|
  @result = @calc.send op
end

Aleshores /el resultat ha de ser (\d+) a la pantalla/ do |result|
  @result.should == result.to_f
end
