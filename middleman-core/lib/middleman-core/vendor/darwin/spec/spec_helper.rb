require 'rspec'
require 'rb-fsevent'

RSpec.configure do |config|
  config.color_enabled = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  
  config.before(:each) do
    @fixture_path = Pathname.new(File.expand_path('../fixtures/', __FILE__))
  end
  
  config.before(:all) do
    system "cd ext; ruby extconf.rb"
    puts "fsevent_watch compiled"
  end
  
  config.after(:all) do
    gem_root = Pathname.new(File.expand_path('../../', __FILE__))
    system "rm -rf #{gem_root.join('bin')}"
    system "rm #{gem_root.join('ext/Makefile')}"
  end
  
end