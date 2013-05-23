#!/usr/bin/env gem build
# encoding: utf-8

require File.expand_path("../lib/padrino-core/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = "padrino-core"
  s.rubyforge_project = "padrino-core"
  s.authors = ["Padrino Team", "Nathan Esquenazi", "Davide D'Agostino", "Arthur Chiu"]
  s.email = "padrinorb@gmail.com"
  s.summary = "The required Padrino core gem"
  s.homepage = "http://www.padrinorb.com"
  s.description = "The Padrino core gem required for use of this framework"
  s.required_rubygems_version = ">= 1.3.6"
  s.version = Padrino.version
  s.date = Time.now.strftime("%Y-%m-%d")

  s.extra_rdoc_files = Dir["*.rdoc"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rdoc_options  = ["--charset=UTF-8"]

  # TODO remove after a couple versions
  # s.post_install_message = "\e[32m" + ("*" * 20)
  # s.post_install_message << "\n UPGRADE NOTES\n\n\e[31m When upgrading, please 'enable :sessions' for each application"
  # s.post_install_message << " as shown here:\e[0m http://bit.ly/kODKMx\n"
  # s.post_install_message << "\e[31m When upgrading, please 'register Padrino::Rendering' for each application"
  # s.post_install_message << " as shown here:\e[0m https://gist.github.com/1d36a35794dbbd664ea4"
  # s.post_install_message << "\n\e[32m" + ("*" * 20) + "\n\e[0m"

  s.add_dependency("tilt", "~> 1.3.0")
  s.add_dependency("sinatra", "~> 1.3.1")
  s.add_dependency("http_router", "~> 0.10.2")
  s.add_dependency("thor", "~> 0.15.2")
  s.add_dependency("activesupport", "~> 3.2.0")
end
