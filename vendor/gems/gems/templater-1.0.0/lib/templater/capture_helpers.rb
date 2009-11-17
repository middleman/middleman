module Templater
  
  # Stolen from merb-core. Merb-core is licensed under the MIT license as follows:

  # Copyright (c) 2008 Ezra Zygmuntowicz
  # 
  # Permission is hereby granted, free of charge, to any person obtaining
  # a copy of this software and associated documentation files (the
  # "Software"), to deal in the Software without restriction, including
  # without limitation the rights to use, copy, modify, merge, publish,
  # distribute, sublicense, and/or sell copies of the Software, and to
  # permit persons to whom the Software is furnished to do so, subject to
  # the following conditions:
  # 
  # The above copyright notice and this permission notice shall be
  # included in all copies or substantial portions of the Software.
  # 
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
  # TODO: this should be specced in some way.
  module CaptureHelpers #:nodoc:
    
    def _erb_buffer( the_binding )
      @_buffer = eval( "_erbout", the_binding, __FILE__, __LINE__)
    end
    
    def capture(*args, &block)
      # get the buffer from the block's binding
      buffer = _erb_buffer( block.binding ) rescue nil

      # If there is no buffer, just call the block and get the contents
      if buffer.nil?
        block.call(*args)
      # If there is a buffer, execute the block, then extract its contents
      else
        pos = buffer.length
        block.call(*args)

        # extract the block
        data = buffer[pos..-1]

        # replace it in the original with empty string
        buffer[pos..-1] = ''

        data
      end
    end

    # DOC
    def concat(string, binding)
      _erb_buffer(binding) << string
    end
    
  end
  
end