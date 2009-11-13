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
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-test-0.5.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-test-0.5.1/lib")
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

  require "rubygems"

  @bundled_specs = {}
  @bundled_specs["rdoc"] = eval(File.read("#{dir}/specifications/rdoc-2.4.3.gemspec"))
  @bundled_specs["rdoc"].loaded_from = "#{dir}/specifications/rdoc-2.4.3.gemspec"
  @bundled_specs["configuration"] = eval(File.read("#{dir}/specifications/configuration-1.1.0.gemspec"))
  @bundled_specs["configuration"].loaded_from = "#{dir}/specifications/configuration-1.1.0.gemspec"
  @bundled_specs["builder"] = eval(File.read("#{dir}/specifications/builder-2.1.2.gemspec"))
  @bundled_specs["builder"].loaded_from = "#{dir}/specifications/builder-2.1.2.gemspec"
  @bundled_specs["daemons"] = eval(File.read("#{dir}/specifications/daemons-1.0.10.gemspec"))
  @bundled_specs["daemons"].loaded_from = "#{dir}/specifications/daemons-1.0.10.gemspec"
  @bundled_specs["extlib"] = eval(File.read("#{dir}/specifications/extlib-0.9.13.gemspec"))
  @bundled_specs["extlib"].loaded_from = "#{dir}/specifications/extlib-0.9.13.gemspec"
  @bundled_specs["json"] = eval(File.read("#{dir}/specifications/json-1.2.0.gemspec"))
  @bundled_specs["json"].loaded_from = "#{dir}/specifications/json-1.2.0.gemspec"
  @bundled_specs["eventmachine"] = eval(File.read("#{dir}/specifications/eventmachine-0.12.10.gemspec"))
  @bundled_specs["eventmachine"].loaded_from = "#{dir}/specifications/eventmachine-0.12.10.gemspec"
  @bundled_specs["rack"] = eval(File.read("#{dir}/specifications/rack-1.0.1.gemspec"))
  @bundled_specs["rack"].loaded_from = "#{dir}/specifications/rack-1.0.1.gemspec"
  @bundled_specs["shotgun"] = eval(File.read("#{dir}/specifications/shotgun-0.4.gemspec"))
  @bundled_specs["shotgun"].loaded_from = "#{dir}/specifications/shotgun-0.4.gemspec"
  @bundled_specs["rack-test"] = eval(File.read("#{dir}/specifications/rack-test-0.5.1.gemspec"))
  @bundled_specs["rack-test"].loaded_from = "#{dir}/specifications/rack-test-0.5.1.gemspec"
  @bundled_specs["sinatra"] = eval(File.read("#{dir}/specifications/sinatra-0.9.4.gemspec"))
  @bundled_specs["sinatra"].loaded_from = "#{dir}/specifications/sinatra-0.9.4.gemspec"
  @bundled_specs["thin"] = eval(File.read("#{dir}/specifications/thin-1.2.5.gemspec"))
  @bundled_specs["thin"].loaded_from = "#{dir}/specifications/thin-1.2.5.gemspec"
  @bundled_specs["sdoc"] = eval(File.read("#{dir}/specifications/sdoc-0.2.14.1.gemspec"))
  @bundled_specs["sdoc"].loaded_from = "#{dir}/specifications/sdoc-0.2.14.1.gemspec"
  @bundled_specs["yui-compressor"] = eval(File.read("#{dir}/specifications/yui-compressor-0.9.1.gemspec"))
  @bundled_specs["yui-compressor"].loaded_from = "#{dir}/specifications/yui-compressor-0.9.1.gemspec"
  @bundled_specs["polyglot"] = eval(File.read("#{dir}/specifications/polyglot-0.2.9.gemspec"))
  @bundled_specs["polyglot"].loaded_from = "#{dir}/specifications/polyglot-0.2.9.gemspec"
  @bundled_specs["treetop"] = eval(File.read("#{dir}/specifications/treetop-1.4.2.gemspec"))
  @bundled_specs["treetop"].loaded_from = "#{dir}/specifications/treetop-1.4.2.gemspec"
  @bundled_specs["rake"] = eval(File.read("#{dir}/specifications/rake-0.8.7.gemspec"))
  @bundled_specs["rake"].loaded_from = "#{dir}/specifications/rake-0.8.7.gemspec"
  @bundled_specs["launchy"] = eval(File.read("#{dir}/specifications/launchy-0.3.3.gemspec"))
  @bundled_specs["launchy"].loaded_from = "#{dir}/specifications/launchy-0.3.3.gemspec"
  @bundled_specs["sprockets"] = eval(File.read("#{dir}/specifications/sprockets-1.0.2.gemspec"))
  @bundled_specs["sprockets"].loaded_from = "#{dir}/specifications/sprockets-1.0.2.gemspec"
  @bundled_specs["haml"] = eval(File.read("#{dir}/specifications/haml-2.2.13.gemspec"))
  @bundled_specs["haml"].loaded_from = "#{dir}/specifications/haml-2.2.13.gemspec"
  @bundled_specs["diff-lcs"] = eval(File.read("#{dir}/specifications/diff-lcs-1.1.2.gemspec"))
  @bundled_specs["diff-lcs"].loaded_from = "#{dir}/specifications/diff-lcs-1.1.2.gemspec"
  @bundled_specs["rspec"] = eval(File.read("#{dir}/specifications/rspec-1.2.9.gemspec"))
  @bundled_specs["rspec"].loaded_from = "#{dir}/specifications/rspec-1.2.9.gemspec"
  @bundled_specs["highline"] = eval(File.read("#{dir}/specifications/highline-1.5.1.gemspec"))
  @bundled_specs["highline"].loaded_from = "#{dir}/specifications/highline-1.5.1.gemspec"
  @bundled_specs["templater"] = eval(File.read("#{dir}/specifications/templater-1.0.0.gemspec"))
  @bundled_specs["templater"].loaded_from = "#{dir}/specifications/templater-1.0.0.gemspec"
  @bundled_specs["term-ansicolor"] = eval(File.read("#{dir}/specifications/term-ansicolor-1.0.4.gemspec"))
  @bundled_specs["term-ansicolor"].loaded_from = "#{dir}/specifications/term-ansicolor-1.0.4.gemspec"
  @bundled_specs["cucumber"] = eval(File.read("#{dir}/specifications/cucumber-0.4.4.gemspec"))
  @bundled_specs["cucumber"].loaded_from = "#{dir}/specifications/cucumber-0.4.4.gemspec"
  @bundled_specs["sinatra-content-for"] = eval(File.read("#{dir}/specifications/sinatra-content-for-0.2.gemspec"))
  @bundled_specs["sinatra-content-for"].loaded_from = "#{dir}/specifications/sinatra-content-for-0.2.gemspec"
  @bundled_specs["compass"] = eval(File.read("#{dir}/specifications/compass-0.8.17.gemspec"))
  @bundled_specs["compass"].loaded_from = "#{dir}/specifications/compass-0.8.17.gemspec"

  def self.add_specs_to_loaded_specs
    Gem.loaded_specs.merge! @bundled_specs
  end

  def self.add_specs_to_index
    @bundled_specs.each do |name, spec|
      Gem.source_index.add_spec spec
    end
  end

  add_specs_to_loaded_specs
  add_specs_to_index

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

module Gem
  @loaded_stacks = Hash.new { |h,k| h[k] = [] }

  def source_index.refresh!
    super
    Bundler.add_specs_to_index
  end
end
