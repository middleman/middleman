require File.join(File.dirname(__FILE__), "hooks/inheritable_attribute")

# Almost like ActiveSupport::Callbacks but 76,6% less complex.
#
# Example:
#
#   class CatWidget < Apotomo::Widget
#     define_hook :after_dinner
#
# Now you can add callbacks to your hook declaratively in your class.
#
#     after_dinner do puts "Ice cream!" end
#     after_dinner :have_a_desert   # => refers to CatWidget#have_a_desert
#
# Running the callbacks happens on instances. It will run the block and #have_a_desert from above.
#
#   cat.run_hook :after_dinner
module Hooks
  VERSION = "0.2.0"

  def self.included(base)
    base.extend InheritableAttribute
    base.extend ClassMethods
  end

  module ClassMethods
    def define_hook(name)
      accessor_name = "_#{name}_callbacks"

      setup_hook_accessors(accessor_name)
      define_hook_writer(name, accessor_name)
    end

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
      callbacks_for_hook(name).each do |callback|
        if callback.kind_of? Symbol
          scope.send(callback, *args)
        else
          scope.instance_exec(*args, &callback)
        end
      end
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
      send("_#{name}_callbacks")
    end

  private

    def define_hook_writer(hook, accessor_name)
      self.send(:define_method, hook.to_sym) do |&block|
        if self.class.respond_to?(hook)
          self.class.send(hook.to_sym, &block)
        end
      end

      instance_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{hook}(method=nil, &block)
          #{accessor_name} << (block || method)
        end
      RUBY_EVAL
    end

    def setup_hook_accessors(accessor_name)
      inheritable_attr(accessor_name)
      send("#{accessor_name}=", [])  # initialize ivar.
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
end
