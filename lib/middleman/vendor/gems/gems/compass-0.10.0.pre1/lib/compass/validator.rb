begin
  require 'rubygems'
  require 'compass-validator'
rescue LoadError
  raise Compass::MissingDependency, %Q{The Compass CSS Validator could not be loaded. Please install it:

sudo gem install chriseppstein-compass-validator --source http://gems.github.com/
}
end
