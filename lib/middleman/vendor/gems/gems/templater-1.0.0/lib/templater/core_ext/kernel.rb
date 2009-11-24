module Kernel
  unless (RUBY_VERSION[0,3] == '1.9')
    def instance_exec(*args, &block)
      mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
      Object.class_eval{ define_method(mname, &block) }
      begin
        ret = send(mname, *args)
      ensure
        Object.class_eval{ undef_method(mname) } rescue nil
      end
      ret
    end
  end
end
