class FSSM::Monitor
  def initialize(options={})
    @options = options
    @backend = FSSM::Backends::Default.new
  end

  def path(*args, &block)
    path = FSSM::Path.new(*args)

    if block_given?
      if block.arity == 1
        block.call(path)
      else
        path.instance_eval(&block)
      end
    end

    @backend.add_path(path)
    path
  end

  def run
    @backend.run
  end
end
