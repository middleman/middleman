module MaRuKu; class MDElement
	
	def md_inline_math(math)
		self.md_el(:inline_math, [], meta={:math=>math})
	end

	def md_equation(math, label, numerate)
		reglabel= /\\label\{(\w+)\}/
		if math =~ reglabel
			label = $1
			math.gsub!(reglabel,'')
		end
#		puts "Found label = #{label} math #{math.inspect} "
		num = nil
		if (label || numerate) && @doc #take number
			@doc.eqid2eq ||= {}	
			num = @doc.eqid2eq.size + 1
			label = "eq#{num}" if not label      # FIXME do id for document
		end
		e = self.md_el(:equation, [], meta={:math=>math, :label=>label,:num=>num})
		if label && @doc #take number
			@doc.eqid2eq[label] = e
		end
		e
	end

end end