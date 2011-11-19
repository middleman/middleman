lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'hooks'

Gem::Specification.new do |s|
  s.name        = "hooks"
  s.version     = Hooks::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nick Sutterer"]
  s.email       = ["apotonick@gmail.com"]
  s.homepage    = "http://nicksda.apotomo.de/tag/hooks"
  s.summary     = %q{Generic hooks with callbacks for Ruby.}
  s.description = %q{Declaratively define hooks, add callbacks and run them with the options you like.}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_development_dependency "shoulda"
  s.add_development_dependency "rake"
end
