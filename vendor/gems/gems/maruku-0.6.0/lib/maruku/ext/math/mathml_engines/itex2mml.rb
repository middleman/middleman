
module MaRuKu; module Out; module HTML

	def convert_to_mathml_itex2mml(kind, tex)
		begin
			if not $itex2mml_parser
				require 'itextomml'
				$itex2mml_parser =  Itex2MML::Parser.new
			end
			
			itex_method = {:equation=>:block_filter,:inline=>:inline_filter}
			
			mathml =  $itex2mml_parser.send(itex_method[kind], tex)
			doc = Document.new(mathml, {:respect_whitespace =>:all}).root
			return doc
		rescue LoadError => e
			maruku_error "Could not load package 'itex2mml'.\n"+ "Please install it." 			unless $already_warned_itex2mml 
			$already_warned_itex2mml = true
		rescue REXML::ParseException => e
			maruku_error "Invalid MathML TeX: \n#{add_tabs(tex,1,'tex>')}"+
				"\n\n #{e.inspect}"
		rescue 
			maruku_error "Could not produce MathML TeX: \n#{tex}"+
				"\n\n #{e.inspect}"
		end
		nil
	end

end end end
