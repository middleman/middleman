require 'rake'
require 'rake/testtask'
require "rake/clean"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sinatra-maruku"
    gem.summary = "An extension providing Maruku templates for Sinatra applications."
    gem.email = "matwb@univ.gda.pl"
    gem.homepage = "http://github.com/wbzyl/sinatra-maruku"
    gem.description = gem.description
    gem.authors = ["Wlodek Bzyl"]
    
    gem.add_runtime_dependency 'sinatra', '>=0.10.1'            
    gem.add_runtime_dependency 'maruku', '>=0.6.0'        
    
    gem.add_development_dependency 'rack', '>=1.0.0'
    gem.add_development_dependency 'rack-test', '>=0.3.0'
    
    # gem is a Gem::Specification
    # refer to http://www.rubygems.org/read/chapter/20 for additional settings  
  end
rescue LoadError
  puts "Jeweler not available."
  puts "Install it with:"
  puts "  sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end
