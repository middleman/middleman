require "sdoc"

module SDoc::Templatable
	### Load and render the erb template in the given +templatefile+ within the
	### specified +context+ (a Binding object) and return output
	### Both +templatefile+ and +outfile+ should be Pathname-like objects.
  def eval_template(templatefile, context)
		template_src = templatefile.read
		template = ERB.new( template_src, nil, '<>' )
		template.filename = templatefile.to_s

    begin
      template.result( context )
    rescue NoMethodError => err
      raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
        templatefile.to_s,
        err.message,
        eval( "_erbout[-50,50]", context )
        ], err.backtrace
      end
  end
  
  ### Load and render the erb template with the given +template_name+ within
  ### current context. Adds all +local_assigns+ to context
  def include_template(template_name, local_assigns = {})
    source = local_assigns.keys.map { |key| "#{key} = local_assigns[:#{key}];" }.join
    eval("#{source};templatefile = @template_dir + template_name;eval_template(templatefile, binding)")
  end
  
	### Load and render the erb template in the given +templatefile+ within the
	### specified +context+ (a Binding object) and write it out to +outfile+.
	### Both +templatefile+ and +outfile+ should be Pathname-like objects.
	def render_template( templatefile, context, outfile )
    output = eval_template(templatefile, context)
    
    # TODO delete this dirty hack when documentation for example for GeneratorMethods will not be cutted off by <script> tag
    begin
      if output.respond_to? :force_encoding
        encoding = output.encoding
        output = output.force_encoding('ASCII-8BIT').gsub('<script>', '&lt;script;&gt;').force_encoding(encoding)
      else
        output = output.gsub('<script>', '&lt;script&gt;')
      end
    rescue Exception => e
      
    end
    
		unless $dryrun
			outfile.dirname.mkpath
			outfile.open( 'w', 0644 ) do |file|
				file.print( output )
			end
		else
			debug_msg "  would have written %d bytes to %s" %
			[ output.length, outfile ]
		end
	end  
end