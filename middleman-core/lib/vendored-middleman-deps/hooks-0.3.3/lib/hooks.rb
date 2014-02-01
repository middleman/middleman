require File.join(File.dirname(__FILE__), "hooks/inheritable_attribute")
require File.join(File.dirname(__FILE__), "hooks/hook")

# Almost like ActiveSupport::Callbacks but 76,6% less complex.
#
# Example:
#
#   class CatWidget < Apotomo::Widget
#     define_hooks :before_dinner, :after_dinner
#
# Now you can add callbacks to your hook declaratively in your class.
#
#     before_dinner :wash_paws
#     after_dinner { puts "Ice cream!" }
#     after_dinner :have_a_desert   # => refers to CatWidget#have_a_desert
#
# Running the callbacks happens on instances. It will run the block and #have_a_desert from above.
#
#   cat.run_hook :after_dinner
module Hooks
  def self.included(base)
    base.class_eval do
      extend InheritableAttribute
      extend ClassMethods
      inheritable_attr :_hooks
      self._hooks= HookSet.new
    end
  end

  module ClassMethods
    def define_hooks(*names)
      options = extract_options!(names)

      names.each do |name|
        setup_hook(name, options)
      end
    end
    alias_method :define_hook, :define_hooks

    # Like Hooks#run_hook but for the class. Note that +:callbacks+ must be class methods.
    #
    # Example:
    #
    # class Cat
    #   after_eight :grab_a_beer
    #
    #   def self.grab_a_beer(*) # and so on...
    #
    # where <tt>Cat.run_hook :after_eight</tt> will call the class method +grab_a_beer+.
    def run_hook(name, *args)
      run_hook_for(name, self, *args)
    end

    def run_hook_for(name, scope, *args)
      _hooks[name].run(scope, *args)
    end

    # Returns the callbacks for +name+. Handy if you want to run the callbacks yourself, say when
    # they should be executed in another context.
    #
    # Example:
    #
    #   def initialize
    #     self.class.callbacks_for_hook(:after_eight).each do |callback|
    #       instance_exec(self, &callback)
    #     end
    #
    # would run callbacks in the object _instance_ context, passing +self+ as block parameter.
    def callbacks_for_hook(name)
      _hooks[name]
    end

  private
    def setup_hook(name, options)
      _hooks[name] = Hook.new(options)
      define_hook_writer(name)
    end

    def define_hook_writer(name)
      self.send(:define_method, name.to_sym) do |&block|
        if self.class.respond_to?(name)
          self.class.send(name.to_sym, &block)
        end
      end
      instance_eval *hook_writer_args(name)
    end

    def hook_writer_args(name)
      # DISCUSS: isn't there a simpler way to define a dynamic method? should the internal logic be handled by HooksSet instead?
      str = <<-RUBY_EVAL
        def #{name}(method=nil, &block)
          _hooks[:#{name}] << (block || method)
        end
      RUBY_EVAL

      [str, __FILE__, __LINE__ + 1]
    end

    def extract_options!(args)
      args.last.is_a?(Hash) ? args.pop : {}
    end
  end

  # Runs the callbacks (method/block) for the specified hook +name+. Additional arguments will
  # be passed to the callback.
  #
  # Example:
  #
  #   cat.run_hook :after_dinner, "i want ice cream!"
  #
  # will invoke the callbacks like
  #
  #   desert("i want ice cream!")
  #   block.call("i want ice cream!")
  def run_hook(name, *args)
    self.class.run_hook_for(name, self, *args)
  end

  class HookSet < Hash
    def [](name)
      super(name.to_sym)
    end

    def []=(name, values)
      super(name.to_sym, values)
    end

    def clone
      super.tap do |cloned|
        each { |name, callbacks| cloned[name] = callbacks.clone }
      end
    end
  end
end

require File.join(File.dirname(__FILE__), "hooks/instance_hooks")
