# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculatrice'

Soit /^une calculatrice$/ do
  @calc = Calculatrice.new
end

Et /^que j'entre (\d+) pour le (.*) nombre/ do |n, x|
  @calc.push n.to_i
end

Lorsque /^je tape sur la touche "="$/ do
  @expected_result = @calc.additionner
end

Alors /le résultat affiché doit être (\d*)/ do |result|
  result.to_i.should == @expected_result
end

Soit /^que je tape sur la touche "\+"$/ do
  # noop
end
