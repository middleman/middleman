module Hooks
  module InstanceHooks
    include ClassMethods

    def run_hook(name, *args)
      run_hook_for(name, self, *args)
    end

  private
    def _hooks
      @_hooks ||= self.class._hooks.clone # TODO: generify that with representable_attrs.
    end

    module ClassMethods
      def define_hook_writer(name)
        super
        class_eval *hook_writer_args(name)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end