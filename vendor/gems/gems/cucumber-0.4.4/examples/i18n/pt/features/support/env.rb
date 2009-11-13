# encoding: utf-8
$KCODE='u' unless Cucumber::RUBY_1_9
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculadora'
