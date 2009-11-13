# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatter/unicode'
require 'calculator'
$KCODE='u' unless Cucumber::RUBY_1_9