module Spec
  module Mocks
    class Mock
      include Methods

      # Creates a new mock with a +name+ (that will be used in error messages
      # only) == Options:
      # * <tt>:null_object</tt> - if true, the mock object acts as a forgiving
      #   null object allowing any message to be sent to it.
      def initialize(name=nil, stubs_and_options={})
        if name.is_a?(Hash) && stubs_and_options.empty?
          stubs_and_options = name
          @name = nil
        else
          @name = name
        end
        @options = extract_options(stubs_and_options)
        assign_stubs(stubs_and_options)
      end

      # This allows for comparing the mock to other objects that proxy such as
      # ActiveRecords belongs_to proxy objects. By making the other object run
      # the comparison, we're sure the call gets delegated to the proxy
      # target.
      def ==(other)
        other == __mock_proxy
      end

      def inspect
        "#<#{self.class}:#{sprintf '0x%x', self.object_id} @name=#{@name.inspect}>"
      end

      def to_s
        inspect.gsub('<','[').gsub('>',']')
      end

    private

      def method_missing(sym, *args, &block)
        __mock_proxy.record_message_received(sym, args, block)
        begin
          return self if __mock_proxy.null_object?
          super(sym, *args, &block)
        rescue NameError
          __mock_proxy.raise_unexpected_message_error sym, *args
        end
      end

      def extract_options(stubs_and_options)
        options = {}
        extract_option(stubs_and_options, options, :null_object)
        extract_option(stubs_and_options, options, :__declared_as, 'Mock')
        options
      end
      
      def extract_option(source, target, key, default=nil)
        if source[key]
          target[key] = source.delete(key)
        elsif default
          target[key] = default
        end
      end

      def assign_stubs(stubs)
        stubs.each_pair do |message, response|
          stub!(message).and_return(response)
        end
      end
    end
  end
end
