# DO NOT MODIFY THIS FILE
module Bundler
 file = File.expand_path(__FILE__)
 dir = File.dirname(file)

  ENV["PATH"]     = "#{dir}/../../bin:#{ENV["PATH"]}"
  ENV["RUBYOPT"]  = "-r#{file} #{ENV["RUBYOPT"]}"

  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rdoc-2.4.3/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rdoc-2.4.3/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/configuration-1.1.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/configuration-1.1.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/builder-2.1.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/builder-2.1.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/daemons-1.0.10/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/daemons-1.0.10/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/extlib-0.9.13/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/extlib-0.9.13/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/json-1.2.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/json-1.2.0/ext/json/ext")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/json-1.2.0/ext")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/json-1.2.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/eventmachine-0.12.10/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/eventmachine-0.12.10/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.0.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.0.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/shotgun-0.4/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/shotgun-0.4/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-test-0.5.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-test-0.5.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-0.9.4/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-0.9.4/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/thin-1.2.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/thin-1.2.5/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sdoc-0.2.14.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sdoc-0.2.14.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/yui-compressor-0.9.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/yui-compressor-0.9.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/polyglot-0.2.9/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/polyglot-0.2.9/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/treetop-1.4.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/treetop-1.4.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rake-0.8.7/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rake-0.8.7/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/launchy-0.3.3/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/launchy-0.3.3/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sprockets-1.0.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sprockets-1.0.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/haml-2.2.13/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/haml-2.2.13/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/diff-lcs-1.1.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/diff-lcs-1.1.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rspec-1.2.9/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rspec-1.2.9/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/highline-1.5.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/highline-1.5.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/templater-1.0.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/templater-1.0.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/term-ansicolor-1.0.4/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/term-ansicolor-1.0.4/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/cucumber-0.4.4/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/cucumber-0.4.4/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-content-for-0.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-content-for-0.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/compass-0.8.17/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/compass-0.8.17/lib")

  @gemfile = "#{dir}/../../Gemfile"


  def self.require_env(env = nil)
    context = Class.new do
      def initialize(env) @env = env && env.to_s ; end
      def method_missing(*) ; yield if block_given? ; end
      def only(*env)
        old, @only = @only, _combine_only(env.flatten)
        yield
        @only = old
      end
      def except(*env)
        old, @except = @except, _combine_except(env.flatten)
        yield
        @except = old
      end
      def gem(name, *args)
        opt = args.last.is_a?(Hash) ? args.pop : {}
        only = _combine_only(opt[:only] || opt["only"])
        except = _combine_except(opt[:except] || opt["except"])
        files = opt[:require_as] || opt["require_as"] || name
        files = [files] unless files.respond_to?(:each)

        return unless !only || only.any? {|e| e == @env }
        return if except && except.any? {|e| e == @env }

        if files = opt[:require_as] || opt["require_as"]
          files = Array(files)
          files.each { |f| require f }
        else
          begin
            require name
          rescue LoadError
            # Do nothing
          end
        end
        yield if block_given?
        true
      end
      private
      def _combine_only(only)
        return @only unless only
        only = [only].flatten.compact.uniq.map { |o| o.to_s }
        only &= @only if @only
        only
      end
      def _combine_except(except)
        return @except unless except
        except = [except].flatten.compact.uniq.map { |o| o.to_s }
        except |= @except if @except
        except
      end
    end
    context.new(env && env.to_s).instance_eval(File.read(@gemfile), @gemfile, 1)
  end
end

$" << "rubygems.rb"

module Kernel
  def gem(*)
    # Silently ignore calls to gem, since, in theory, everything
    # is activated correctly already.
  end
end

# Define all the Gem errors for gems that reference them.
module Gem
  def self.ruby ; "/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby" ; end
  class LoadError < ::LoadError; end
  class Exception < RuntimeError; end
  class CommandLineError < Exception; end
  class DependencyError < Exception; end
  class DependencyRemovalException < Exception; end
  class GemNotInHomeException < Exception ; end
  class DocumentError < Exception; end
  class EndOfYAMLException < Exception; end
  class FilePermissionError < Exception; end
  class FormatException < Exception; end
  class GemNotFoundException < Exception; end
  class InstallError < Exception; end
  class InvalidSpecificationException < Exception; end
  class OperationNotSupportedError < Exception; end
  class RemoteError < Exception; end
  class RemoteInstallationCancelled < Exception; end
  class RemoteInstallationSkipped < Exception; end
  class RemoteSourceException < Exception; end
  class VerificationError < Exception; end
  class SystemExitException < SystemExit; end
end
