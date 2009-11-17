#--
#   Copyright (C) 2006  Andrea Censi  <andrea (at) rubyforge.org>
#
# This file is part of Maruku.
# 
#   Maruku is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
# 
#   Maruku is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with Maruku; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#++



class String

	# These are TeX's special characters
	LATEX_ADD_SLASH = [ ?{, ?}, ?$, ?&, ?#, ?_, ?%]

	# These, we transform to {\tt \char<ascii code>}
	LATEX_TO_CHARCODE = [ ?^, ?~, ?>,?<]

	def escape_to_latex(s)
		s2 = ""
		s.each_byte do |b|
			if LATEX_TO_CHARCODE.include? b
				s2 += "{\\tt \\char#{b}}" 
			elsif LATEX_ADD_SLASH.include? b
				s2 << ?\\ << b
			elsif b == ?\\
			# there is no backslash in cmr10 fonts
				s2 += "$\\backslash$"
			else
				s2 << b
			end
		end
		s2
	end
	
	# escapes special characters
	def to_latex
		s = escape_to_latex(self)
		OtherGoodies.each do |k, v|
			s.gsub!(k, v)
		end
		s
	end
	
	# other things that are good on the eyes
	OtherGoodies = {
		/(\s)LaTeX/ => '\1\\LaTeX\\xspace ', # XXX not if already \LaTeX
#		'HTML' => '\\textsc{html}\\xspace ',
#		'PDF' => '\\textsc{pdf}\\xspace '
	}
	
end