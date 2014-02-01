lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'hooks/version'

Gem::Specification.new do |s|
  s.name        = "hooks"
  s.version     = Hooks::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nick Sutterer"]
  s.email       = ["apotonick@gmail.com"]
  s.homepage    = "http://nicksda.apotomo.de/2010/09/hooks-and-callbacks-for-ruby-but-simple/"
  s.summary     = %q{Generic hooks with callbacks for Ruby.}
  s.description = %q{Declaratively define hooks, add callbacks and run them with the options you like.}
  s.license = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.license       = 'MIT'

  s.add_development_dependency "minitest", ">= 5.0.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
end
