require 'spec'

if Spec::Ruby.version.to_f >= 1.9
  gem 'test-unit','= 1.2.3'
end

require 'test/unit'

if Spec::Ruby.version.to_f >= 1.9
  require 'test/unit/version'
  if Test::Unit::VERSION > '1.2.3'
    raise <<-MESSAGE
#{'*' * 50}
Required: test-unit-1.2.3
Loaded:   test-unit-#{Test::Unit::VERSION}

With ruby-1.9, rspec-#{Spec::VERSION::STRING} requires test-unit-1.2.3, and
tries to force it with "gem 'test-unit', '= 1.2.3'" in:

  #{__FILE__}
  
Unfortunately, test-unit-#{Test::Unit::VERSION} was loaded anyway. While we are
aware of this bug we have not been able to track down its source.
Until we do, you have two alternatives:

* uninstall test-unit-2.0.3
* use 'script/spec' instead of 'rake spec'
#{'*' * 50}
MESSAGE
  end
end


require 'test/unit/testresult'

require 'spec/interop/test/unit/testcase'
require 'spec/interop/test/unit/testsuite_adapter'
require 'spec/interop/test/unit/autorunner'
require 'spec/interop/test/unit/testresult'
require 'spec/interop/test/unit/ui/console/testrunner'

Spec::Example::ExampleGroupFactory.default(Test::Unit::TestCase)

Test::Unit.run = true
