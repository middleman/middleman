module Templater
  
  class Description
    attr_accessor :name, :options, :block
    
    def initialize(name, options={}, &block)
      @name = name
      @options = options
      @block = block
    end    
  end
  
  class ActionDescription < Description
    
    def compile(generator)
      @block.call(generator)
    end
    
  end
  
  class ArgumentDescription < Description
    
    # Checks if the given argument is valid according to this description
    #
    # === Parameters
    # argument<Object>:: Checks if the given argument is valid.
    # === Returns
    # Boolean:: Validity of the argument
    def valid?(argument)
      if argument.nil? and options[:required]
        raise Templater::TooFewArgumentsError
      elsif not argument.nil?
        if options[:as] == :hash and not argument.is_a?(Hash)
          raise Templater::MalformattedArgumentError, "Expected the argument to be a Hash, but was '#{argument.inspect}'"
        elsif options[:as] == :array and not argument.is_a?(Array)
          raise Templater::MalformattedArgumentError, "Expected the argument to be an Array, but was '#{argument.inspect}'"
        end
           
        invalid = catch :invalid do
          block.call(argument) if block
          throw :invalid, :not_invalid
        end
        raise Templater::ArgumentError, invalid unless invalid == :not_invalid
      end
    end
    
    def extract(argument)
      case options[:as]
      when :hash
        if argument.is_a?(String)
          return argument.split(',').inject({}) do |h, pair|
            key, value = pair.strip.split(':')
            raise Templater::MalformattedArgumentError, "Expected '#{argument.inspect}' to be a key/value pair" unless key and value
            h[key] = value
            h
          end
        end
      when :array
        return argument.split(',') if argument.is_a?(String)
      end
      return argument
    end
    
  end
  
  class InvocationDescription < Description
    
    def get(generator)
      klass = generator.class.manifold.generator(name)
      if klass and block
        generator.instance_exec(klass, &block)
      elsif klass
        klass.new(generator.destination_root, generator.options, *generator.arguments)
      end
    end
    
  end
end