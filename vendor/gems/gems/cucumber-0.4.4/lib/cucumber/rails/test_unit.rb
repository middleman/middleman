begin
  require 'test/unit/testresult'
rescue LoadError => e
  e.message << "\nYou must gem install test-unit. For more info see https://rspec.lighthouseapp.com/projects/16211/tickets/292"
  e.message << "\nAlso make sure you have rack 1.0.0 or higher."
  raise e
end
# So that Test::Unit doesn't launch at the end - makes it think it has already been run.
Test::Unit.run = true if Test::Unit.respond_to?(:run=)
