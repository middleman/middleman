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

require 'rexml/document'

begin
	require 'rexml/formatters/pretty'
	require 'rexml/formatters/default'
	$rexml_new_version = true
rescue LoadError
	$rexml_new_version = false	
end

class String
	# A string is rendered into HTML by creating
	# a REXML::Text node. REXML takes care of all the encoding.
	def to_html
		REXML::Text.new(self)
	end
end


# This module groups all functions related to HTML export.
module MaRuKu; module Out; module HTML
	include REXML
	
	# Render as an HTML fragment (no head, just the content of BODY). (returns a string)
	def to_html(context={})
		indent = context[:indent] || -1
		ie_hack = context[:ie_hack] || true
		
		div = Element.new 'dummy'
			children_to_html.each do |e|
				div << e
			end

			# render footnotes
			if @doc.footnotes_order.size > 0
				div << render_footnotes
			end
		
		doc = Document.new(nil,{:respect_whitespace =>:all})
		doc << div
		
		# REXML Bug? if indent!=-1 whitespace is not respected for 'pre' elements
		# containing code.
		xml =""

		if $rexml_new_version
			formatter = if indent > -1
	          REXML::Formatters::Pretty.new( indent, ie_hack )
	        else
	          REXML::Formatters::Default.new( ie_hack )
	        end
			formatter.write( div, xml)
		else
			div.write(xml,indent,transitive=true,ie_hack)
		end

		xml.gsub!(/\A<dummy>\s*/,'')
		xml.gsub!(/\s*<\/dummy>\Z/,'')
		xml.gsub!(/\A<dummy\s*\/>/,'')
		xml
	end
	
	# Render to a complete HTML document (returns a string)
	def to_html_document(context={})
		indent = context[:indent] || -1
		ie_hack = context[:ie_hack] ||true
		doc = to_html_document_tree
		xml  = "" 
		
		# REXML Bug? if indent!=-1 whitespace is not respected for 'pre' elements
		# containing code.
		doc.write(xml,indent,transitive=true,ie_hack);
		
		Xhtml11_mathml2_svg11 + xml
	end
	
				
		Xhtml10strict  = 
"<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN'
'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>\n"
		
	Xhtml11strict_mathml2 = '<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN"
               "http://www.w3.org/TR/MathML2/dtd/xhtml-math11-f.dtd" [
  <!ENTITY mathml "http://www.w3.org/1998/Math/MathML">
]>
'

Xhtml11_mathml2_svg11 = 
'<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC
    "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"
    "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">
'
	
	
	def xml_newline() Text.new("\n") end
		

=begin maruku_doc
Attribute: title
Scope: document

Sets the title of the document.
If a title is not specified, the first header will be used.

These should be equivalent:

	Title: my document

	Content

and

	my document
	===========

	Content

In both cases, the title is set to "my document".
=end

=begin maruku_doc
Attribute: doc_prefix
Scope: document

String to disambiguate footnote links.
=end


=begin maruku_doc
Attribute: subject
Scope: document

Synonim for `title`.
=end


	# Render to an HTML fragment (returns a REXML document tree)
	def to_html_tree
		div = Element.new 'div'
			div.attributes['class'] = 'maruku_wrapper_div'
				children_to_html.each do |e|
						  div << e
				end

				# render footnotes
				if @doc.footnotes_order.size > 0
						  div << render_footnotes
				end

		 doc = Document.new(nil,{:respect_whitespace =>:all})
		 doc << div
	end

=begin maruku_doc
Attribute: css
Scope: document
Output: HTML
Summary: Activates CSS stylesheets for HTML.

`css` should be a space-separated list of urls.

Example:

	CSS: style.css math.css

=end

	METAS = %w{description keywords author revised}

	# Render to a complete HTML document (returns a REXML document tree)
	def to_html_document_tree
		doc = Document.new(nil,{:respect_whitespace =>:all})
	#	doc << XMLDecl.new
		
		root = Element.new('html', doc)
		root.add_namespace('http://www.w3.org/1999/xhtml')
		root.add_namespace('svg', "http://www.w3.org/2000/svg" )
		lang = self.attributes[:lang] || 'en'
		root.attributes['xml:lang'] = lang
		
		root << xml_newline
		head = Element.new 'head', root
		
			#<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
			me = Element.new 'meta', head
			me.attributes['http-equiv'] = 'Content-type'
#			me.attributes['content'] = 'text/html;charset=utf-8'	
			me.attributes['content'] = 'application/xhtml+xml;charset=utf-8'	
		
			METAS.each do |m|
				if value = self.attributes[m.to_sym]
					meta = Element.new 'meta', head
					meta.attributes['name'] = m
					meta.attributes['content'] = value.to_s
				end
			end
			
			
			self.attributes.each do |k,v|
				if k.to_s =~ /\Ameta-(.*)\Z/
					meta = Element.new 'meta', head
					meta.attributes['name'] = $1
					meta.attributes['content'] = v.to_s
				end
			end
			

			
			# Create title element
			doc_title = self.attributes[:title] || self.attributes[:subject] || ""
			title = Element.new 'title', head
				title << Text.new(doc_title)
							
			add_css_to(head)
			
		
		root << xml_newline
		
		body = Element.new 'body'
		
			children_to_html.each do |e|
				body << e
			end

			# render footnotes
			if @doc.footnotes_order.size > 0
				body << render_footnotes
			end
			
			# When we are rendering a whole document, we add a signature 
			# at the bottom. 
			if get_setting(:maruku_signature)
				body << maruku_html_signature 
			end
			
		root << body
		
		doc
	end

	def add_css_to(head)
		if css_list = self.attributes[:css]
			css_list.split.each do |css|
			# <link type="text/css" rel="stylesheet" href="..." />
			link = Element.new 'link'
			link.attributes['type'] = 'text/css'
			link.attributes['rel'] = 'stylesheet'
			link.attributes['href'] = css
			head << link 
			head << xml_newline
			end
		end
	end
	
	# returns "st","nd","rd" or "th" as appropriate
	def day_suffix(day)
		s = {
			1 => 'st',
			2 => 'nd',
			3 => 'rd',
			21 => 'st',
			22 => 'nd',
			23 => 'rd',
			31 => 'st'
		}
		return s[day] || 'th';
	end

	# formats a nice date
	def nice_date
		t = Time.now
		t.strftime(" at %H:%M on ")+
		t.strftime("%A, %B %d")+
		day_suffix(t.day)+
		t.strftime(", %Y")
	end
	
	def maruku_html_signature		
		div = Element.new 'div'
			div.attributes['class'] = 'maruku_signature'
			Element.new 'hr', div
			span = Element.new 'span', div
				span.attributes['style'] = 'font-size: small; font-style: italic'
				span << Text.new('Created by ')
				a = Element.new('a', span)
					a.attributes['href'] = 'http://maruku.rubyforge.org'
					a.attributes['title'] = 'Maruku: a Markdown-superset interpreter for Ruby'
					a << Text.new('Maruku')
				span << Text.new(nice_date+".")
		div
	end
	
	def render_footnotes()
		div = Element.new 'div'
		div.attributes['class'] = 'footnotes'
		div <<  Element.new('hr')
			ol = Element.new 'ol'
			@doc.footnotes_order.each_with_index do |fid, i| num = i+1
				f = self.footnotes[fid]
				if f
					li = f.wrap_as_element('li')
					li.attributes['id'] = "#{get_setting(:doc_prefix)}fn:#{num}"
					
					a = Element.new 'a'
						a.attributes['href'] = "\##{get_setting(:doc_prefix)}fnref:#{num}"
						a.attributes['rev'] = 'footnote'
						a<< Text.new('&#8617;', true, nil, true)
					li.insert_after(li.children.last, a)
					ol << li
				else
					maruku_error "Could not find footnote id '#{fid}' among ["+
					 self.footnotes.keys.map{|s|"'"+s+"'"}.join(', ')+"]."
				end
			end
		div << ol
		div
	end


	def to_html_hrule; create_html_element 'hr' end
	def to_html_linebreak; Element.new 'br' end

	# renders children as html and wraps into an element of given name
	# 
	# Sets 'id' if meta is set
	def wrap_as_element(name, attributes_to_copy=[])
		m = create_html_element(name, attributes_to_copy)
			children_to_html.each do |e| m << e; end
			
#			m << Comment.new( "{"+self.al.to_md+"}") if not self.al.empty?
#			m << Comment.new( @attributes.inspect) if not @attributes.empty?
		m
	end
	
=begin maruku_doc
Attribute: id
Scope: element
Output: LaTeX, HTML

It is copied as a standard HTML attribute.

Moreover, it used as a label name for hyperlinks in both HTML and
in PDF.

=end

=begin maruku_doc
Attribute: class
Scope: element
Output: HTML

It is copied as a standard HTML attribute.
=end

=begin maruku_doc
Attribute: style
Scope: element
Output: HTML

It is copied as a standard HTML attribute.
=end
	
		
	
	
	
	HTML4Attributes = {}
	
	coreattrs = [:id, :class, :style, :title]
	i18n = [:lang, 'xml:lang'.to_sym]
	events = [
		:onclick, :ondblclick, :onmousedown, :onmouseup, :onmouseover, 
		:onmousemove, :onmouseout,
		:onkeypress, :onkeydown, :onkeyup]	
	attrs = coreattrs + i18n + events
	cellhalign = [:align, :char, :charoff]
	cellvalign = [:valign]
	[
		['body', attrs + [:onload, :onunload]],
		['address', attrs],
		['div', attrs],
		['a', attrs+[:charset, :type, :name, :rel, :rev, :accesskey, :shape, :coords, :tabindex, 
			:onfocus,:onblur]],
		['img', attrs + [:longdesc, :name, :height, :width, :alt] ],
		['p', attrs],
		[['h1','h2','h3','h4','h5','h6'], attrs], 
		[['pre'], attrs],
		[['q', 'blockquote'], attrs+[:cite]],
		[['ins','del'], attrs+[:cite,:datetime]],
		[['ol','ul','li'], attrs],
		['table',attrs+[:summary, :width, :frame, :rules, :border, :cellspacing, :cellpadding]],
		['caption',attrs],	
		[['colgroup','col'],attrs+[:span, :width]+cellhalign+cellvalign],
		[['thead','tbody','tfoot'], attrs+cellhalign+cellvalign],
		[['td','td','th'], attrs+[:abbr, :axis, :headers, :scope, :rowspan, :colspan, :cellvalign, :cellhalign]],
		
		# altri
		[['em','code','strong','hr','span','dl','dd','dt'], attrs]
	].each do |el, a| [*el].each do |e| HTML4Attributes[e] = a end end
		
		
	def create_html_element(name, attributes_to_copy=[])
		m = Element.new name
			if atts = HTML4Attributes[name] then 
				atts.each do |att|
					if v = @attributes[att] then 
						m.attributes[att.to_s] = v.to_s 
					end
				end
			else
			#	puts "not atts for #{name.inspect}"
			end
		m
	end

	
	def to_html_ul
		if @attributes[:toc]
			# render toc
			html_toc = @doc.toc.to_html
			return html_toc
		else
			add_ws  wrap_as_element('ul')               
		end
	end
	
	
	def to_html_paragraph; add_ws wrap_as_element('p')                end
	def to_html_ol;        add_ws wrap_as_element('ol')        end
	def to_html_li;        add_ws wrap_as_element('li')        end
	def to_html_li_span;   add_ws wrap_as_element('li')        end
	def to_html_quote;     add_ws wrap_as_element('blockquote')  end
	def to_html_strong;    wrap_as_element('strong')           end
	def to_html_emphasis;  wrap_as_element('em')               end

=begin maruku_doc
Attribute: use_numbered_headers
Scope: document
Summary: Activates the numbering of headers.

If `true`, section headers will be numbered.

In LaTeX export, the numbering of headers is managed
by Maruku, to have the same results in both HTML and LaTeX.
=end

	# nil if not applicable, else string
	def section_number
		return nil if not get_setting(:use_numbered_headers)
		
		n = @attributes[:section_number]
		if n && (not n.empty?)
			 n.join('.')+". "
		else
			nil
		end
	end
	
	# nil if not applicable, else SPAN element
	def render_section_number
		# if we are bound to a section, add section number
		if num = section_number
			span = Element.new 'span'
			span.attributes['class'] = 'maruku_section_number'
			span << Text.new(section_number)
			span
		else
			nil
		end
	end
	
	def to_html_header
		element_name = "h#{self.level}" 
		h = wrap_as_element element_name
		
		if span = render_section_number
			h.insert_before(h.children.first, span)
		end
		add_ws h
	end

	def source2html(source)
#		source = source.gsub(/&/,'&amp;')
		source = Text.normalize(source)
		source = source.gsub(/\&apos;/,'&#39;') # IE bug
		source = source.gsub(/'/,'&#39;') # IE bug
		Text.new(source, true, nil, true )
	end
		
=begin maruku_doc
Attribute: html_use_syntax
Scope: global, document, element
Output: HTML
Summary: Enables the use of the `syntax` package.
Related: lang, code_lang
Default: <?mrk md_code(Globals[:html_use_syntax].to_s) ?>

If true, the `syntax` package is used. It supports the `ruby` and `xml`
languages. Remember to set the `lang` attribute of the code block.

Examples:

		require 'maruku'
	{:lang=ruby html_use_syntax=true}

and 
	
		<div style="text-align:center">Div</div>
	{:lang=html html_use_syntax=true}

produces:

	require 'maruku'
{:lang=ruby html_use_syntax=true}

and

	<div style="text-align:center">Div</div>
{:lang=html html_use_syntax=true}

=end

	$syntax_loaded = false
	def to_html_code; 
		source = self.raw_code

		lang = self.attributes[:lang] || @doc.attributes[:code_lang] 

		lang = 'xml' if lang=='html'

		use_syntax = get_setting :html_use_syntax
		
		element = 
		if use_syntax && lang
			begin
				if not $syntax_loaded
					require 'rubygems'
					require 'syntax'
					require 'syntax/convertors/html'
					$syntax_loaded = true
				end
				convertor = Syntax::Convertors::HTML.for_syntax lang
				
				# eliminate trailing newlines otherwise Syntax crashes
				source = source.gsub(/\n*\Z/,'')
				
				html = convertor.convert( source )
				html = html.gsub(/\&apos;/,'&#39;') # IE bug
				html = html.gsub(/'/,'&#39;') # IE bug
	#			html = html.gsub(/&/,'&amp;') 
				
				code = Document.new(html, {:respect_whitespace =>:all}).root
				code.name = 'code'
				code.attributes['class'] = lang
				code.attributes['lang'] = lang
				
				pre = Element.new 'pre'
				pre << code
				pre
			rescue LoadError => e
				maruku_error "Could not load package 'syntax'.\n"+
					"Please install it, for example using 'gem install syntax'."
				to_html_code_using_pre(source)	
			rescue Object => e
				maruku_error"Error while using the syntax library for code:\n#{source.inspect}"+
				 "Lang is #{lang} object is: \n"+
				  self.inspect + 
				"\nException: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
				
				tell_user("Using normal PRE because the syntax library did not work.")
				to_html_code_using_pre(source)
			end
		else
			to_html_code_using_pre(source)
		end
		
		color = get_setting(:code_background_color)
		if color != Globals[:code_background_color]
			element.attributes['style'] = "background-color: #{color};"
		end
		add_ws element
	end
	
=begin maruku_doc
Attribute: code_background_color
Scope: global, document, element
Summary: Background color for code blocks.

The format is either a named color (`green`, `red`) or a CSS color
of the form `#ff00ff`. 

* for **HTML output**, the value is put straight in the `background-color` CSS 
  property of the block.

* for **LaTeX output**, if it is a named color, it must be a color accepted
  by the LaTeX `color` packages. If it is of the form `#ff00ff`, Maruku
  defines a color using the `\color[rgb]{r,g,b}` macro. 

  For example, for `#0000ff`, the macro is called as: `\color[rgb]{0,0,1}`.

=end
	
	
	def to_html_code_using_pre(source)
		pre = create_html_element  'pre'
		code = Element.new 'code', pre
		s = source
		
#		s  = s.gsub(/&/,'&amp;')
		s = Text.normalize(s)
		s  = s.gsub(/\&apos;/,'&#39;') # IE bug
		s  = s.gsub(/'/,'&#39;') # IE bug

		if get_setting(:code_show_spaces) 
			# 187 = raquo
			# 160 = nbsp
			# 172 = not
			s.gsub!(/\t/,'&#187;'+'&#160;'*3)
			s.gsub!(/ /,'&#172;')
		end

		text = Text.new(s, respect_ws=true, parent=nil, raw=true )
		
		if lang = self.attributes[:lang]
			code.attributes['lang'] = lang
			code.attributes['class'] = lang
		end
		code << text
		pre
	end

	def to_html_inline_code; 
		pre =  create_html_element 'code'
			source = self.raw_code
			pre << source2html(source) 
			
			color = get_setting(:code_background_color)
			if color != Globals[:code_background_color]
				pre.attributes['style'] = "background-color: #{color};"+(pre.attributes['style']||"")
			end
			
		pre
	end

	def add_class_to(el, cl)
		el.attributes['class'] = 
		if already = el.attributes['class']
			already + " " + cl
		else
			cl
		end
	end

	def add_class_to_link(a)
		return # not ready yet
		
		# url = a.attributes['href']
		# return if not url
		# 
		# if url =~ /^#/
		# 	add_class_to(a, 'maruku-link-samedoc')
		# elsif url =~ /^http:/
		# 	add_class_to(a, 'maruku-link-external')
		# else
		# 	add_class_to(a, 'maruku-link-local')
		# end
		# 	
#		puts a.attributes['class']
	end
	
	
	def to_html_immediate_link
		a =  create_html_element 'a'
		url = self.url
		text = url.gsub(/^mailto:/,'') # don't show mailto
		a << Text.new(text)
		a.attributes['href'] = url
		add_class_to_link(a)
		a
	end
	
	def to_html_link
		a =  wrap_as_element 'a'
		id = self.ref_id
		
		if ref = @doc.refs[id]
			url = ref[:url]
			title = ref[:title]
			a.attributes['href'] = url if url
			a.attributes['title'] = title if title
		else
			maruku_error "Could not find ref_id = #{id.inspect} for #{self.inspect}\n"+
				"Available refs are #{@doc.refs.keys.inspect}"
			tell_user "Not creating a link for ref_id = #{id.inspect}."
			return wrap_as_element('span')
		end

#		add_class_to_link(a)
		return a
	end
	
	def to_html_im_link
		if url = self.url
			title = self.title
			a =  wrap_as_element 'a'
			a.attributes['href'] = url
			a.attributes['title'] = title if title
			return a
		else
			maruku_error"Could not find url in #{self.inspect}"
			tell_user "Not creating a link for ref_id = #{id.inspect}."
			return wrap_as_element('span')
		end
	end
	
	def add_ws(e)
		[Text.new("\n"), e, Text.new("\n")]
	end
##### Email address
	
	def obfuscate(s)
		res = ''
		s.each_byte do |char|
			res +=  "&#%03d;" % char
		end
		res
	end
	
	def to_html_email_address
		email = self.email
		a = create_html_element 'a'
			#a.attributes['href'] = Text.new("mailto:"+obfuscate(email),false,nil,true)
			#a.attributes.add Attribute.new('href',Text.new(
			#"mailto:"+obfuscate(email),false,nil,true))
			# Sorry, for the moment it doesn't work
			a.attributes['href'] = "mailto:#{email}"
			
			a << Text.new(obfuscate(email),false,nil,true)
		a
	end

##### Images

	def to_html_image
		a =  create_html_element 'img'
		id = self.ref_id
		if ref = @doc.refs[id]
			url = ref[:url]
			title = ref[:title]
			a.attributes['src'] = url.to_s
			a.attributes['alt'] = children_to_s 
		else
			maruku_error"Could not find id = #{id.inspect} for\n #{self.inspect}"
			tell_user "Could not create image with ref_id = #{id.inspect};"+
				 " Using SPAN element as replacement."
				return wrap_as_element('span')
		end
		return a
	end
	
	def to_html_im_image
		if not url = self.url
			maruku_error "Image with no url: #{self.inspect}"
			tell_user "Could not create image with ref_id = #{id.inspect};"+
				" Using SPAN element as replacement."
			return wrap_as_element('span')
		end
		title = self.title
		a =  create_html_element 'img'
			a.attributes['src'] = url.to_s
			a.attributes['alt'] = children_to_s 
		return a
	end

=begin maruku_doc
Attribute: filter_html
Scope: document

If true, raw HTML is discarded from the output.

=end

	def to_html_raw_html
		return [] if get_setting(:filter_html)
		
		raw_html = self.raw_html
		if rexml_doc = @parsed_html
			root = rexml_doc.root
			if root.nil?
				s = "Bug in REXML: root() of Document is nil: \n#{rexml_doc.inspect}\n"+
				"Raw HTML:\n#{raw_html.inspect}"
				maruku_error s
				tell_user 'The REXML version you have has a bug, omitting HTML'
				div = Element.new 'div'
				#div << Text.new(s)
				return div
			end
			
			# copies the @children array (FIXME is it deep?)
			elements =  root.to_a 
			return elements
		else # invalid
			# Creates red box with offending HTML
			tell_user "Wrapping bad html in a PRE with class 'markdown-html-error'\n"+
				add_tabs(raw_html,1,'|')
			pre = Element.new('pre')
			pre.attributes['style'] = 'border: solid 3px red; background-color: pink'
			pre.attributes['class'] = 'markdown-html-error'
			pre << Text.new("REXML could not parse this XML/HTML: \n#{raw_html}", true)
			return pre
		end
	end

	def to_html_abbr
		abbr = Element.new 'abbr'
		abbr << Text.new(children[0])
		abbr.attributes['title'] = self.title if self.title
		abbr
	end
	
	def to_html_footnote_reference
		id = self.footnote_id
		
		# save the order of used footnotes
		order = @doc.footnotes_order
		
		if order.include? id
		  # footnote has already been used
		  return []
	  end
	  
	  if not @doc.footnotes[id]
	    return []
    end
	  
		# take next number
		order << id
		
		#num = order.size; 
		num = order.index(id) + 1
		  
		sup = Element.new 'sup'
		sup.attributes['id'] = "#{get_setting(:doc_prefix)}fnref:#{num}"
			a = Element.new 'a'
			a << Text.new(num.to_s)
			a.attributes['href'] = "\##{get_setting(:doc_prefix)}fn:#{num}"
			a.attributes['rel'] = 'footnote'
		sup << a
			
		sup
	end
	
## Definition lists ###
	def to_html_definition_list() add_ws wrap_as_element('dl') end
	def to_html_definition() children_to_html end
	def to_html_definition_term() add_ws wrap_as_element('dt') end
	def to_html_definition_data() add_ws wrap_as_element('dd') end	

	# FIXME: Ugly code
	def to_html_table
		align = self.align
		num_columns = align.size

		head = @children.slice(0, num_columns)
		rows = []
		i = num_columns
		while i<@children.size
			rows << @children.slice(i, num_columns)
			i += num_columns
		end
		
		table = create_html_element 'table'
			thead = Element.new 'thead'
			tr = Element.new 'tr'
				array_to_html(head).each do |x| tr<<x end
			thead << tr
			table << thead
			
			tbody = Element.new 'tbody'
			rows.each do |row|
				tr = Element.new 'tr'
					array_to_html(row).each_with_index do |x,i| 
						x.attributes['style'] ="text-align: #{align[i].to_s};" 
						tr<<x 
					end
						
				tbody << tr << Text.new("\n")
			end
			table << tbody
		table
	end
	
	def to_html_head_cell; wrap_as_element('th') end
	def to_html_cell
		if @attributes[:scope]
			wrap_as_element('th', [:scope])
		else
			wrap_as_element('td')
		end
 	end
	
	def to_html_entity 
		MaRuKu::Out::Latex.need_entity_table
      
		entity_name = self.entity_name
		
		if (e = MaRuKu::Out::Latex::ENTITY_TABLE[entity_name]) && e.html_num
			entity_name = e.html_num
		end
		
		# Fix for Internet Explorer
		if entity_name == 'apos'
			entity_name = 39
		end

		
		if entity_name.kind_of? Fixnum
#			Entity.new(entity_name)
			Text.new('&#%d;' % [entity_name],  false, nil, true)
		else
			Text.new('&%s;' % [entity_name],  false, nil, true)
		end
	end

	def to_html_xml_instr
		target = self.target || ''
		code = self.code || ''
		REXML::Instruction.new(target, code)
	end

	# Convert each child to html
	def children_to_html
		array_to_html(@children)
	end

	def array_to_html(array)
		e = []
		array.each do |c|
			method = c.kind_of?(MDElement) ? 
			   "to_html_#{c.node_type}" : "to_html"

			if not c.respond_to?(method)
				#raise "Object does not answer to #{method}: #{c.class} #{c.inspect}"
				next
			end

			h =  c.send(method)

			if h.nil?
				raise "Nil html created by method  #{method}:\n#{h.inspect}\n"+
				" for object #{c.inspect[0,300]}"
			end

			if h.kind_of?Array
				e = e + h #h.each do |hh| e << hh end
			else
				e << h
			end
		end
		e
	end

	def to_html_ref_definition; [] end
	def to_latex_ref_definition; [] end

end # HTML
end # out
end # MaRuKu
