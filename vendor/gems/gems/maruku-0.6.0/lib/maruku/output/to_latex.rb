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

module MaRuKu

class MDDocument

	Latex_preamble_enc_cjk = 
"\\usepackage[C40]{fontenc}
\\usepackage[cjkjis]{ucs}
\\usepackage[utf8x]{inputenc}"

	Latex_preamble_enc_utf8 = 
"\\usepackage{ucs}
\\usepackage[utf8x]{inputenc}"

	def latex_require_package(p)
		if not self.latex_required_packages.include? p
			self.latex_required_packages.push p
		end
	end

	# Render as a LaTeX fragment 
	def to_latex
		children_to_latex
	end

=begin maruku_doc
Attribute: maruku_signature
Scope: document
Output: html, latex
Summary: Enables Maruku's signature.
Default: true

If false, Maruku does not append a signature to the
generated file.
=end

	# Render as a complete LaTeX document 
	def to_latex_document
		body = to_latex
		
		if get_setting(:maruku_signature)
			body += render_latex_signature 
		end
		
		required = 
		self.latex_required_packages.map {|p|
			"\\usepackage{#{p}}\n"
		}.join
		
=begin maruku_doc
Attribute: latex_cjk
Scope:     document
Output:    latex
Summary:   Support for CJK characters.

If the `latex_cjk` attribute is specified, then appropriate headers
are added to the LaTeX preamble to support Japanese fonts.
You have to have these fonts installed -- and this can be a pain.

If `latex_cjk` is specified, this is added to the preamble:

<?mrk puts "ciao" ?> 

<?mrk md_codeblock(Maruku::MDDocument::Latex_preamble_enc_cjk) ?>


while the default is to add this:

<?mrk md_codeblock(Maruku::MDDocument::Latex_preamble_enc_utf8) ?>

=end
		encoding = get_setting(:latex_cjk) ? 
			Latex_preamble_enc_cjk : Latex_preamble_enc_utf8

=begin maruku_doc
Attribute: latex_preamble
Scope:     document
Output:    latex
Summary:   User-defined preamble.

If the `latex_preamble` attribute is specified, then its value
will be used as a custom preamble. 

For example:

	Title: My document
	Latex preamble: preamble.tex

will produce:

	...
	\input{preamble.tex}
	...

=end
	user_preamble = (file = @doc.attributes[:latex_preamble]) ?
		"\\input{#{file}}\n" : ""
		
"\\documentclass{article}

% Packages required to support encoding
#{encoding}

% Packages required by code
#{required}

% Packages always used
\\usepackage{hyperref}
\\usepackage{xspace}
\\usepackage[usenames,dvipsnames]{color}
\\hypersetup{colorlinks=true,urlcolor=blue}

#{user_preamble}

\\begin{document} 
#{body}
\\end{document}
"	
	end
	
	
	def render_latex_signature
"\\vfill
\\hrule
\\vspace{1.2mm}
\\begin{tiny}
Created by \\href{http://maruku.rubyforge.org}{Maruku} #{self.nice_date}.
\\end{tiny}"
	end

end end

module MaRuKu; module Out; module Latex
	
	def to_latex_hrule; "\n\\vspace{.5em} \\hrule \\vspace{.5em}\n" end
	def to_latex_linebreak; "\\newline " end
	
	def to_latex_paragraph 
		children_to_latex+"\n\n"
	end

	
=begin maruku_doc
Title: Input format for colors
Output: latex, html
Related: code_background_color

Admissible formats:

	green
	#abc
	#aabbcc
=end

	# \color[named]{name} 	
	# \color[rgb]{1,0.2,0.3} 
	def latex_color(s, command='color')
		if s =~ /^\#(\w\w)(\w\w)(\w\w)$/
			r = $1.hex; g = $2.hex; b=$3.hex
			# convert from 0-255 to 0.0-1.0
			r = r / 255.0; g = g / 255.0; b = b / 255.0; 
			"\\#{command}[rgb]{%0.2f,%0.2f,%0.2f}" % [r,g,b]
		elsif s =~ /^\#(\w)(\w)(\w)$/
			r = $1.hex; g = $2.hex; b=$3.hex
			# convert from 0-15 to 0.0-1.0
			r = r / 15.0; g = g / 15.0; b = b / 15.0; 
			"\\#{command}[rgb]{%0.2f,%0.2f,%0.2f}" % [r,g,b]
		else	
			"\\#{command}{#{s}}"
		end
	end
	
=begin maruku_doc
Attribute: code_show_spaces
Scope: global, document, element

If `true`, shows spaces and tabs in code blocks.

Example:

		 One space
		  Two spaces
			 	Tab, space, tab
					Tab, tab, tab and all is green!
	{:code_show_spaces code_background_color=#ffeedd}
{:markdown}
	
That will produce:

	 One space
	  Two spaces
		 	Tab, space, tab
				Tab, tab, tab and all is green!
{:code_show_spaces code_background_color=#ffeedd}

=end
	
=begin maruku_doc
Attribute: latex_use_listings
Scope: document
Output: latex
Summary: Support for `listings` package.
Related: code_show_spaces, code_background_color, lang, code_lang

If the `latex_use_listings` attribute is specified, then 
code block are rendered using the `listings` package.
Otherwise, a standard `verbatim` environment is used.

*	If the `lang` attribute for the code block has been specified,
	it gets passed to the `listings` package using the `lstset` macro.
	The default lang for code blocks is specified through 
	the `code_lang` attribute.

		\lstset{language=ruby}

	Please refer to the documentation of the `listings` package for
	supported languages.

	If a language is not supported, the `listings` package will emit
	a warning during the compilation. Just press enter and nothing
	wrong will happen.

*	If the `code_show_spaces` is specified, than spaces and tabs will
	be shown using the macro:

		\lstset{showspaces=true,showtabs=true}

*	The background color is given by `code_background_color`.

=end

	def to_latex_code;
		raw_code = self.raw_code
		
		if get_setting(:latex_use_listings)
			@doc.latex_require_package('listings')
				
			s = "\\lstset{columns=fixed,frame=shadowbox}"

			if get_setting(:code_show_spaces) 
				s+= "\\lstset{showspaces=true,showtabs=true}\n"
			else
				s+= "\\lstset{showspaces=false,showtabs=false}\n"
			end
			
			color = latex_color get_setting(:code_background_color)
			
			s+= "\\lstset{backgroundcolor=#{color}}\n" 
			
			s+= "\\lstset{basicstyle=\\ttfamily\\footnotesize}\n" 
			
			
			lang = self.attributes[:lang] || @doc.attributes[:code_lang] || '{}'
			if lang
				s += "\\lstset{language=#{lang}}\n"
			end
			
			"#{s}\n\\begin{lstlisting}\n#{raw_code}\n\\end{lstlisting}"
		else
			"\\begin{verbatim}#{raw_code}\\end{verbatim}\n"
		end
	end
	
	TexHeaders = {
		1=>'section',
		2=>'subsection',
		3=>'subsubsection',
		4=>'paragraph'}

	def to_latex_header
		h = TexHeaders[self.level] || 'paragraph'
		
		title = children_to_latex
		if number = section_number
			title = number + title
		end
		
		if id = self.attributes[:id]
			# drop '#' at the beginning
			if id[0,1] == '#' then id = [1,id.size] end
			%{\\hypertarget{%s}{}\\%s*{{%s}}\\label{%s}\n\n} % [ id, h, title, id ]
		else
			%{\\%s*{%s}\n\n} % [ h, title]
		end
	end
	
	
	def to_latex_ul;       
		if self.attributes[:toc]
			@doc.toc.to_latex
		else
			wrap_as_environment('itemize')
		end
	end
		   
	def to_latex_quote;        wrap_as_environment('quote')               end
	def to_latex_ol;        wrap_as_environment('enumerate')               end
	def to_latex_li;        
		"\\item #{children_to_latex}\n"  
	end
	def to_latex_li_span;
		"\\item #{children_to_latex}\n"
	end

	def to_latex_strong
		"\\textbf{#{children_to_latex}}"
 	end
	def to_latex_emphasis
		"\\emph{#{children_to_latex}}"
	end
	
	def wrap_as_span(c)
		"{#{c} #{children_to_latex}}"
	end
	
	def wrap_as_environment(name)
"\\begin{#{name}}%
#{children_to_latex}
\\end{#{name}}\n"	
	end
	
	SAFE_CHARS = Set.new((?a..?z).to_a + (?A..?Z).to_a)
	# the ultimate escaping
	# (is much better than using \verb)
	def latex_escape(source)
		s=""; 
		
		source.each_byte do |b| 
			if b == ?\ 
				s << '~'
			elsif SAFE_CHARS.include? b
				s << b
			else
				s += "\\char%d" % b 
			end
		end
		s
	end
	
	def to_latex_inline_code; 
		source = self.raw_code
		
		# Convert to printable latex chars 
		s = latex_escape(source)
		
		color = get_setting(:code_background_color)
		colorspec = latex_color(color, 'colorbox')

		"{#{colorspec}{\\tt #{s}}}"
	end

	def to_latex_immediate_link
		url = self.url
		text = url.gsub(/^mailto:/,'') # don't show mailto
#			gsub('~','$\sim$')
		text = latex_escape(text)
		if url[0,1] == '#'
			url = url[1,url.size]
			return "\\hyperlink{#{url}}{#{text}}"
		else

			return "\\href{#{url}}{#{text}}"
		end
	end

	def to_latex_im_link
		url = self.url

		if url[0,1] == '#'
			url = url[1,url.size]
			return "\\hyperlink{#{url}}{#{children_to_latex}}"
		else
			return "\\href{#{url}}{#{children_to_latex}}"
		end
	end
	
	def to_latex_link
		id = self.ref_id
		ref = @doc.refs[id]
		if not ref
			$stderr.puts "Could not find id = '#{id}'"
			return children_to_latex
		else
			url = ref[:url]
			#title = ref[:title] || 'no title'

			if url[0,1] == '#'
				url = url[1,url.size]
				return "\\hyperlink{#{url}}{#{children_to_latex}}"
			else
				return "\\href{#{url}}{#{children_to_latex}}"
			end
		end
		
	end
	
	def to_latex_email_address
		email = self.email
		"\\href{mailto:#{email}}{#{latex_escape(email)}}"
	end
	
	
	def to_latex_table
		align = self.align
		num_columns = align.size

		head = @children.slice(0, num_columns)
		rows = []
		i = num_columns
		while i<@children.size
			rows << @children.slice(i, num_columns)
			i+=num_columns
		end
		
		h = {:center=>'c',:left=>'l',:right=>'r'}
		align_string = align.map{|a| h[a]}.join('|')
		
		s = "\\begin{tabular}{#{align_string}}\n"
			
			s += array_to_latex(head, '&') + "\\\\" +"\n"
			
			s += "\\hline \n"
			
			rows.each do |row|
				s += array_to_latex(row, '&') + "\\\\" +"\n"
			end
			
		s += "\\end{tabular}"
		
		# puts table in its own paragraph
		s += "\n\n"
		
		s
	end
	
	
	def to_latex_head_cell; children_to_latex end
	def to_latex_cell; children_to_latex end
	
	
	def to_latex_footnote_reference
		id = self.footnote_id
		f = @doc.footnotes[id]
		if f
			"\\footnote{#{f.children_to_latex.strip}} "
		else
			$stderr.puts "Could not find footnote '#{fid}'"
		end
	end
	
	def to_latex_raw_html
		#'{\bf Raw HTML removed in latex version }'
		""
	end
	
	## Definition lists ###
	def to_latex_definition_list
		s = "\\begin{description}\n"
		s += children_to_latex
		s += "\\end{description}\n"
		s
	end
	
	def to_latex_definition		
		terms = self.terms
		definitions = self.definitions
		
		s = ""
		terms.each do |t|
			s +="\n\\item[#{t.children_to_latex}] "
		end

		definitions.each do |d|
			s += "#{d.children_to_latex} \n"
		end
		
		s
	end
	

	def to_latex_abbr
		children_to_latex
	end

	def to_latex_image
		id = self.ref_id
		ref = @doc.refs[id]
		if not ref
			maruku_error "Could not find ref #{id.inspect} for image.\n"+
				"Available are: #{@docs.refs.keys.inspect}"
#			$stderr.puts "Could not find id = '#{id}'"
			""
		else
			url = ref[:url]
			$stderr.puts "Images not supported yet (#{url})"
			# "{\\bf Images not supported yet (#{latex_escape(url)})}"
			""
		end

	end

	def to_latex_div
		type = self.attributes[:class]
		id = self.attributes[:id]
		case type
		  when /^un_(\w*)/
                	s = "\\begin{u#{$1}}"
#			s += "[#{@children[0].send('children_to_latex')}]"
			@children.delete_at(0)
                	s += "\n" + children_to_latex
                	s += "\\end{u#{$1}}\n"
		  when /^num_(\w*)/
                        s = "\\begin{#{$1}}"
#			s += "[#{@children[0].send('children_to_latex')}]"
			@children.delete_at(0)
			s += "\n\\label{#{id}}\\hypertarget{#{id}}{}\n"
                        s += children_to_latex
                        s += "\\end{#{$1}}\n"
                  when /^proof/
                        s = "\\begin{proof}"
                        @children.delete_at(0)
                        s += "\n" + children_to_latex
                        s += "\\end{proof}\n"
		  else
			s = children_to_latex
		end
                s
	end

	# Convert each child to html
	def children_to_latex
		array_to_latex(@children)
	end

	def array_to_latex(array, join_char='')
		e = []
		array.each do |c|
			method = c.kind_of?(MDElement) ? 
			   "to_latex_#{c.node_type}" : "to_latex"
			
			if not c.respond_to?(method)
		#		raise "Object does not answer to #{method}: #{c.class} #{c.inspect[0,100]}"
				next
			end
			
			h =  c.send(method)
			
			if h.nil?
				raise "Nil html for #{c.inspect} created with method #{method}"
			end
			
			if h.kind_of?Array
				e = e + h
			else
				e << h
			end
		end
		
		# puts a space after commands if needed
		# e.each_index do |i|
		# 	if e[i] =~ /\\\w+\s*$/ # command
		# 		if (s=e[i+1]) && s[0] == ?\ # space
		# 			e[i]  = e[i] + "\\ "
		# 		end
		# 	end
		# end
		
		e.join(join_char)
	end
	
end end end # MaRuKu::Out::Latex
