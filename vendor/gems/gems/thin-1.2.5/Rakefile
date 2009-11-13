RUBY_1_9 = RUBY_VERSION =~ /^1\.9/
WIN      = (RUBY_PLATFORM =~ /mswin|cygwin/)
SUDO     = (WIN ? "" : "sudo")

require 'rake'
require 'rake/clean'
require 'rake/extensiontask' # from rake-compiler gem

$: << File.join(File.dirname(__FILE__), 'lib')
require 'thin'

# Load tasks in tasks/
Dir['tasks/**/*.rake'].each { |rake| load rake }

task :default => :spec

Rake::ExtensionTask.new('thin_parser', Thin::GemSpec) do |ext|
  ext.cross_compile = true                # enable cross compilation (requires cross compile toolchain)
  ext.cross_platform = 'i386-mswin32'     # forces the Windows platform instead of the default one
                                          # configure options only for cross compile
end

CLEAN.include %w(**/*.{o,bundle,jar,so,obj,pdb,lib,def,exp,log} ext/*/Makefile ext/*/conftest.dSYM)

desc "Compile the Ragel state machines"
task :ragel do
  Dir.chdir 'ext/thin_parser' do
    target = "parser.c"
    File.unlink target if File.exist? target
    sh "ragel parser.rl | rlgen-cd -G2 -o #{target}"
    raise "Failed to compile Ragel state machine" unless File.exist? target
  end
end

desc "Release version #{Thin::VERSION::STRING} gems to rubyforge"
task :release => [:clean, :cross, :native, :gem, :tag, "gem:upload"]