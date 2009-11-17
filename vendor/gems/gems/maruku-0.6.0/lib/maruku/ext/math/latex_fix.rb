class String
	# fix some LaTeX command-name clashes
	def fix_latex
		if #{html_math_engine} == 'itex2mml'
			s = self.gsub("\\mathop{", "\\operatorname{")
			s.gsub!(/\\begin\{svg\}.*?\\end\{svg\}/m, " ")
			s.gsub("\\space{", "\\itexspace{")
		else
			self
		end
	end
end
