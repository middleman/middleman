# encoding: utf-8
$KCODE='u' unless Cucumber::RUBY_1_9
require 'cucumber/formatter/unicode'
require 'spec/expectations'

$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'basket'
require 'belly'
