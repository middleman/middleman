module MaRuKu
	
	class MDDocument
		# Hash equation id (String) to equation element (MDElement)
		safe_attr_accessor :eqid2eq, Hash
		
		def is_math_enabled? 
			get_setting :math_enabled
		end
	end
end


	# Everything goes; takes care of escaping the "\$" inside the expression
	RegInlineMath = /\${1}((?:[^\$]|\\\$)+)\$/
	
	MaRuKu::In::Markdown::register_span_extension(
		:chars => ?$, 
		:regexp => RegInlineMath, 
		:handler => lambda { |doc, src, con|
			return false if not doc.is_math_enabled?
		
			if m = src.read_regexp(RegInlineMath)
				math = m.captures.compact.first
				con.push doc.md_inline_math(math)
				true
			else
				#puts "not math: #{src.cur_chars 10}"
				false
			end
		}
	)
	
	
	MathOpen1 = Regexp.escape('\\begin{equation}')
	MathClose1 = Regexp.escape('\\end{equation}')
	MathOpen2 = Regexp.escape('\\[')
	MathClose2 = Regexp.escape('\\]')
	MathOpen3 = Regexp.escape('$$')
	MathClose3 = Regexp.escape('$$')
	
	EqLabel = /(?:\((\w+)\))/
	EquationOpen = /#{MathOpen1}|#{MathOpen2}|#{MathOpen3}/
	EquationClose = /#{MathClose1}|#{MathClose2}|#{MathClose3}/
	
	# $1 is opening, $2 is tex
	EquationStart = /^[ ]{0,3}(#{EquationOpen})(.*)$/
	# $1 is tex, $2 is closing, $3 is tex
	EquationEnd = /^(.*)(#{EquationClose})\s*#{EqLabel}?\s*$/
	# $1 is opening, $2 is tex, $3 is closing, $4 is label
	OneLineEquation = /^[ ]{0,3}(#{EquationOpen})(.*)(#{EquationClose})\s*#{EqLabel}?\s*$/

	MaRuKu::In::Markdown::register_block_extension(
		:regexp  => EquationStart,
		:handler => lambda { |doc, src, con|
			return false if not doc.is_math_enabled?
			first = src.shift_line
			if first =~ OneLineEquation
				opening, tex, closing, label = $1, $2, $3, $4
				numerate = doc.get_setting(:math_numbered).include?(opening)
				con.push doc.md_equation(tex, label, numerate)
			else
				first =~ EquationStart
				opening, tex = $1, $2
				
				numerate = doc.get_setting(:math_numbered).include?(opening)
				label = nil
				while true
					if not src.cur_line
						doc.maruku_error("Stream finished while reading equation\n\n"+
							doc.add_tabs(tex,1,'$> '), src, con)
						break
					end
					line = src.shift_line
					if line =~ EquationEnd
						tex_line, closing = $1, $2
						label = $3 if $3
						tex += tex_line + "\n"
						break
					else
						tex += line + "\n"
					end
				end
				con.push doc.md_equation(tex, label, numerate)
			end
			true
		})
		
		
	# This adds support for \eqref
	RegEqrefLatex = /\\eqref\{(\w+)\}/
	RegEqPar = /\(eq:(\w+)\)/
	RegEqref = Regexp::union(RegEqrefLatex, RegEqPar)
	
	MaRuKu::In::Markdown::register_span_extension(
		:chars => [?\\, ?(], 
		:regexp => RegEqref,
		:handler => lambda { |doc, src, con|
			return false if not doc.is_math_enabled?
			eqid = src.read_regexp(RegEqref).captures.compact.first
			r = doc.md_el(:eqref, [], meta={:eqid=>eqid})
			con.push r
	 		true 
		}
	)

	# This adds support for \ref
	RegRef = /\\ref\{(\w*)\}/
        MaRuKu::In::Markdown::register_span_extension(
                :chars => [?\\, ?(], 
                :regexp => RegRef,
                :handler => lambda { |doc, src, con|
                        return false if not doc.is_math_enabled?
                        refid = src.read_regexp(RegRef).captures.compact.first
                        r = doc.md_el(:divref, [], meta={:refid=>refid})
                        con.push r
                        true 
                }
        )
