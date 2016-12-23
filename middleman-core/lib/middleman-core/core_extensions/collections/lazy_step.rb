module Middleman
  module CoreExtensions
    module Collections
      class LazyCollectorStep < BasicObject
        DELEGATE = [:hash, :eql?].freeze

        def initialize(name, args, block, parent=nil)
          @name = name
          @args = args
          @block = block

          @parent = parent
          @result = nil

          leaves << self
        end

        def leaves
          @parent.leaves
        end

        def value(ctx=nil)
          data = @parent.value(ctx)

          original_block = @block

          if original_block
            b = if ctx
              ::Proc.new do |*args|
                ctx.instance_exec(*args, &original_block)
              end
            else
              original_block
            end
          end

          data.send(@name, *@args.deep_dup, &b)
        end

        def method_missing(name, *args, &block)
          return ::Kernel.send(name, *args, &block) if DELEGATE.include? name

          leaves.delete self

          LazyCollectorStep.new(name, args, block, self)
        end
      end
    end
  end
end
