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


require 'set'

module MaRuKu; module In; module Markdown; module SpanLevelParser
	include MaRuKu::Helpers
	
	EscapedCharInText = 
		Set.new [?\\,?`,?*,?_,?{,?},?[,?],?(,?),?#,?.,?!,?|,?:,?+,?-,?>]

	EscapedCharInQuotes = 
		Set.new [?\\,?`,?*,?_,?{,?},?[,?],?(,?),?#,?.,?!,?|,?:,?+,?-,?>,?',?"]
	
	EscapedCharInInlineCode = [?\\,?`]

	def parse_lines_as_span(lines, parent=nil)
		parse_span_better lines.join("\n"), parent
	end

	def parse_span_better(string, parent=nil)
		if not string.kind_of? String then 
			error "Passed #{string.class}." end

		st = (string + "")
		st.freeze
		src = CharSource.new(st, parent)
		read_span(src, EscapedCharInText, [nil])
	end
		
	# This is the main loop for reading span elements
	#
	# It's long, but not *complex* or difficult to understand.
	#
	#
	def read_span(src, escaped, exit_on_chars, exit_on_strings=nil)
		con = SpanContext.new
		c = d = nil
		while true
			c = src.cur_char

			# This is only an optimization which cuts 50% of the time used.
			# (but you can't use a-zA-z in exit_on_chars)
			if c && ((c>=?a && c<=?z) || ((c>=?A && c<=?Z)))
				con.cur_string << src.shift_char
				next
			end

			break if exit_on_chars && exit_on_chars.include?(c)
			break if exit_on_strings && exit_on_strings.any? {|x| src.cur_chars_are x}
			
			# check if there are extensions
			if check_span_extensions(src, con)
				next
			end
			
			case c = src.cur_char	
			when ?\ # it's space (32)
				if src.cur_chars_are "  \n"
					src.ignore_chars(3)
					con.push_element  md_br()
					next
				else
					src.ignore_char
					con.push_space 
				end
			when ?\n, ?\t 
				src.ignore_char
				con.push_space 
			when ?`
				read_inline_code(src,con)
			when ?<
				# It could be:
				# 1) HTML "<div ..."
				# 2) HTML "<!-- ..."
				# 3) url "<http:// ", "<ftp:// ..."
				# 4) email "<andrea@... ", "<mailto:andrea@..."
				# 5) on itself! "a < b	"
				# 6) Start of <<guillemettes>>
				
				case d = src.next_char
					when ?<;  # guillemettes
						src.ignore_chars(2)
						con.push_char ?<
						con.push_char ?<
					when ?!; 
						if src.cur_chars_are '<!--'
							read_inline_html(src, con)
						else 
							con.push_char src.shift_char
						end
					when ?? 
						read_xml_instr_span(src, con) 
					when ?\ , ?\t 
						con.push_char src.shift_char
					else
						if src.next_matches(/<mailto:/) or
						   src.next_matches(/<[\w\.]+\@/)
							read_email_el(src, con)
						elsif src.next_matches(/<\w+:/)
							read_url_el(src, con)
						elsif src.next_matches(/<\w/)
							#puts "This is HTML: #{src.cur_chars(20)}"
							read_inline_html(src, con)
						else 
							#puts "This is NOT HTML: #{src.cur_chars(20)}"
							con.push_char src.shift_char
						end
				end
			when ?\\
				d = src.next_char
				if d == ?'
					src.ignore_chars(2)
					con.push_element md_entity('apos')
				elsif d == ?"
					src.ignore_chars(2)
					con.push_element md_entity('quot')
				elsif escaped.include? d
					src.ignore_chars(2)
					con.push_char d
				else
					con.push_char src.shift_char
				end
			when ?[
				if markdown_extra? && src.next_char == ?^
					read_footnote_ref(src,con)
				else
					read_link(src, con)
				end
			when ?!
				if src.next_char == ?[
					read_image(src, con)
				else
					con.push_char src.shift_char
				end
			when ?&
				# named references
				if m = src.read_regexp(/\&([\w\d]+);/)
					con.push_element md_entity(m[1])
				# numeric
				elsif m = src.read_regexp(/\&\#(x)?([\w\d]+);/)
					num = m[1]  ? m[2].hex : m[2].to_i
					con.push_element md_entity(num)
				else
					con.push_char src.shift_char
				end
			when ?*
				if not src.next_char
					maruku_error "Opening * as last char.", src, con
					maruku_recover "Threating as literal"
					con.push_char src.shift_char
				else
					follows = src.cur_chars(4)
					if follows =~ /^\*\*\*[^\s\*]/
						con.push_element read_emstrong(src,'***')
					elsif follows  =~ /^\*\*[^\s\*]/
						con.push_element read_strong(src,'**')
					elsif follows =~ /^\*[^\s\*]/
						con.push_element read_em(src,'*')
					else # * is just a normal char
						con.push_char src.shift_char
					end
				end
			when ?_
				if not src.next_char
					maruku_error "Opening _ as last char", src, con
					maruku_recover "Threating as literal", src, con
					con.push_char src.shift_char
				else
					# we don't want "mod_ruby" to start an emphasis
					# so we start one only if
					# 1) there's nothing else in the span (first char)
					# or 2) the last char was a space
					# or 3) the current string is empty
					#if con.elements.empty? ||
					if	 (con.cur_string =~ /\s\Z/) || (con.cur_string.size == 0)
						# also, we check the next characters
						follows = src.cur_chars(4)
						if  follows =~ /^\_\_\_[^\s\_]/
							con.push_element read_emstrong(src,'___')
						elsif follows  =~ /^\_\_[^\s\_]/
							con.push_element read_strong(src,'__')
						elsif follows =~ /^\_[^\s\_]/
							con.push_element read_em(src,'_')
						else # _ is just a normal char
							con.push_char src.shift_char
						end
					else
						# _ is just a normal char
							con.push_char src.shift_char
					end
				end
			when ?{ # extension
				if [?#, ?., ?:].include? src.next_char
					src.ignore_char # {
					interpret_extension(src, con, [?}])
					src.ignore_char # }
				else
					con.push_char src.shift_char
				end
			when nil
				maruku_error( ("Unclosed span (waiting for %s"+
				 "#{exit_on_strings.inspect})") % [
						exit_on_chars ? "#{exit_on_chars.inspect} or" : ""],
						src,con)
				break
			else # normal text
				con.push_char src.shift_char
			end # end case
		end # end while true
		con.push_string_if_present 

		# Assign IAL to elements
		merge_ial(con.elements, src, con)
		
		
		# Remove leading space
		if (s = con.elements.first).kind_of? String
			if s[0] == ?\ then con.elements[0] = s[1, s.size-1] end
			con.elements.shift if s.size == 0 
		end
		
		# Remove final spaces
		if (s = con.elements.last).kind_of? String
			s.chop! if s[-1] == ?\ 
			con.elements.pop if s.size == 0 
		end
		
		educated = educate(con.elements)

		educated
	end


	def read_xml_instr_span(src, con) 
		src.ignore_chars(2) # starting <?

		# read target <?target code... ?>
		target = if m = src.read_regexp(/(\w+)/)
			m[1]
		else
			''
		end
		
		delim = "?>"
		
		code = 
			read_simple(src, escaped=[], break_on_chars=[], 
			break_on_strings=[delim])
		
		src.ignore_chars delim.size
		
		code = (code || "").strip
		con.push_element md_xml_instr(target, code)
	end

	# Start: cursor on character **after** '{'
	# End: curson on '}' or EOF
	def interpret_extension(src, con, break_on_chars)
		case src.cur_char
		when ?:
			src.ignore_char # :
			extension_meta(src, con, break_on_chars)
		when ?#, ?.
			extension_meta(src, con, break_on_chars)
		else
			stuff = read_simple(src, escaped=[?}], break_on_chars, [])
			if stuff =~ /^(\w+\s|[^\w])/
				extension_id = $1.strip
				if false
				else
					maruku_recover "I don't know what to do with extension '#{extension_id}'\n"+
						"I will threat this:\n\t{#{stuff}} \n as meta-data.\n", src, con
					extension_meta(src, con, break_on_chars)
				end
			else 
				maruku_recover "I will threat this:\n\t{#{stuff}} \n as meta-data.\n", src, con
				extension_meta(src, con, break_on_chars)
			end
		end
	end

	def extension_meta(src, con, break_on_chars)
		if m = src.read_regexp(/([^\s\:\"\']+):/)
			name = m[1]
			al = read_attribute_list(src, con, break_on_chars)
#			puts "#{name}=#{al.inspect}"
			self.doc.ald[name] = al
		 	con.push md_ald(name, al)
		else
			al = read_attribute_list(src, con, break_on_chars)
			self.doc.ald[name] = al
			con.push md_ial(al)
		end
	end	

	def read_url_el(src,con)
		src.ignore_char # leading <
		url = read_simple(src, [], [?>])
		src.ignore_char # closing >
		
		con.push_element md_url(url)
	end

	def read_email_el(src,con)
		src.ignore_char # leading <
		mail = read_simple(src, [], [?>])
		src.ignore_char # closing >
		
		address = mail.gsub(/^mailto:/,'')
		con.push_element md_email(address)
	end
	
	def read_url(src, break_on)
		if [?',?"].include? src.cur_char 
			error 'Invalid char for url', src
		end
		
		url = read_simple(src, [], break_on)
		if not url # empty url
			url = ""
		end
		
		if url[0] == ?< && url[-1] == ?>
			url = url[1, url.size-2]
		end
		
		if url.size == 0 
			return nil
		end
		
		url
	end
	
	
	def read_quoted_or_unquoted(src, con, escaped, exit_on_chars)
		case src.cur_char
		when ?', ?"
			read_quoted(src, con)
		else
			read_simple(src, escaped, exit_on_chars)
		end
	end
	
	# Tries to read a quoted value. If stream does not
	# start with ' or ", returns nil.
	def read_quoted(src, con)
		case src.cur_char
			when ?', ?"
				quote_char = src.shift_char # opening quote
				string = read_simple(src, EscapedCharInQuotes, [quote_char])
				src.ignore_char # closing quote
				return string
			else 
#				puts "Asked to read quote from: #{src.cur_chars(10).inspect}"
				return nil
		end
	end
	
	# Reads a simple string (no formatting) until one of break_on_chars, 
	# while escaping the escaped.
	# If the string is empty, it returns nil.
	# Raises on error if the string terminates unexpectedly.
#	# If eat_delim is true, and if the delim is not the EOF, then the delim
#	# gets eaten from the stream.
	def read_simple(src, escaped, exit_on_chars, exit_on_strings=nil)
		text = ""
		while true
#			puts "Reading simple #{text.inspect}"
			c = src.cur_char
			if exit_on_chars && exit_on_chars.include?(c)
#				src.ignore_char if eat_delim
				break
			end
			
			break if exit_on_strings && 
				exit_on_strings.any? {|x| src.cur_chars_are x}
			
			case c
			when nil
				s= "String finished while reading (break on "+
				"#{exit_on_chars.map{|x|""<<x}.inspect})"+
				" already read: #{text.inspect}"
				maruku_error s, src
				maruku_recover "I boldly continue", src
				break
			when ?\\
				d = src.next_char
				if escaped.include? d
					src.ignore_chars(2)
					text << d
				else
					text << src.shift_char
				end
			else 
				text << src.shift_char
			end
		end
#		puts "Read simple #{text.inspect}"
		text.empty? ? nil : text
	end
	
	def read_em(src, delim)
		src.ignore_char
		children = read_span(src, EscapedCharInText, nil, [delim])
		src.ignore_char
		md_em(children)
	end
	
	def read_strong(src, delim)
		src.ignore_chars(2)
		children = read_span(src, EscapedCharInText, nil, [delim])
		src.ignore_chars(2)
		md_strong(children)
	end

	def read_emstrong(src, delim)
		src.ignore_chars(3)
		children = read_span(src, EscapedCharInText, nil, [delim])
		src.ignore_chars(3)
		md_emstrong(children)
	end
	
	SPACE = ?\ # = 32
	
#	R_REF_ID = Regexp.compile(/([^\]\s]*)(\s*\])/)
#	R_REF_ID = Regexp.compile(/([^\]\s]*)(\s*\])/)
	R_REF_ID = Regexp.compile(/([^\]]*)\]/)
	
	# Reads a bracketed id "[refid]". Consumes also both brackets.
	def read_ref_id(src, con)
		src.ignore_char # [
		src.consume_whitespace
#		puts "Next: #{src.cur_chars(10).inspect}"
		if m = src.read_regexp(R_REF_ID) 
#			puts "Got: #{m[1].inspect} Ignored: #{m[2].inspect}"
#			puts "Then: #{src.cur_chars(10).inspect}"
			m[1]
		else
			nil
		end
	end
	
	def read_footnote_ref(src,con)
		ref = read_ref_id(src,con)
		con.push_element md_foot_ref(ref)
	end
	
	def read_inline_html(src, con)
		h = HTMLHelper.new
		begin
			# This is our current buffer in the context
			next_stuff = src.current_remaining_buffer
			
			consumed = 0
			while true
				if consumed >= next_stuff.size
					maruku_error "Malformed HTML starting at #{next_stuff.inspect}", src, con
					break
				end

				h.eat_this next_stuff[consumed].chr; consumed += 1
				break if h.is_finished? 
			end
			src.ignore_chars(consumed)
			con.push_element md_html(h.stuff_you_read)
			
			#start = src.current_remaining_buffer
			# h.eat_this start
			# if not h.is_finished?
			# 	error "inline_html: Malformed:\n "+
			# 		"#{start.inspect}\n #{h.inspect}",src,con
			# end
			# 
			# consumed = start.size - h.rest.size 
			# if consumed > 0
			# 	con.push_element md_html(h.stuff_you_read)
			# 	src.ignore_chars(consumed)
			# else
			# 	puts "HTML helper did not work on #{start.inspect}"
			# 	con.push_char src.shift_char
			# end
		rescue Exception => e
			maruku_error "Bad html: \n" + 
				add_tabs(e.inspect+e.backtrace.join("\n"),1,'>'),
				src,con
			maruku_recover "I will try to continue after bad HTML.", src, con
			con.push_char src.shift_char
		end
	end
	
	def read_inline_code(src, con)
		# Count the number of ticks
		num_ticks = 0
		while src.cur_char == ?` 
			num_ticks += 1
			src.ignore_char
		end
		# We will read until this string
		end_string = "`"*num_ticks

		code = 
			read_simple(src, escaped=[], break_on_chars=[], 
				break_on_strings=[end_string])
		
#		puts "Now I expects #{num_ticks} ticks: #{src.cur_chars(10).inspect}"
		src.ignore_chars num_ticks
		
		# Ignore at most one space
		if num_ticks > 1 && code[0] == SPACE
			code = code[1, code.size-1]
		end
		
		# drop last space 
		if num_ticks > 1 && code[-1] == SPACE
			code = code[0,code.size-1]
		end

#		puts "Read `` code: #{code.inspect}; after: #{src.cur_chars(10).inspect} "
		con.push_element md_code(code)
	end
	
	def read_link(src, con)
		# we read the string and see what happens
		src.ignore_char # opening bracket
		children = read_span(src, EscapedCharInText, [?]])
		src.ignore_char # closing bracket

		# ignore space
		if src.cur_char == SPACE and 
			(src.next_char == ?[ or src.next_char == ?( )
			src.shift_char
		end
		
		case src.cur_char
		when ?(
			src.ignore_char # opening (
			src.consume_whitespace
			url = read_url(src, [SPACE,?\t,?)])
			if not url
				url = '' # no url is ok
			end
			src.consume_whitespace
			title = nil
			if src.cur_char != ?) # we have a title
				quote_char = src.cur_char
				title = read_quoted(src,con)
				
				if not title
					maruku_error 'Must quote title',src,con
				else
					# Tries to read a title with quotes: ![a](url "ti"tle")
					# this is the most ugly thing in Markdown
					if not src.next_matches(/\s*\)/)
						# if there is not a closing par ), then read
						# the rest and guess it's title with quotes
						rest = read_simple(src, escaped=[], break_on_chars=[?)], 
							break_on_strings=[])
						# chop the closing char
						rest.chop!
						title << quote_char << rest
					end
				end
			end
			src.consume_whitespace
			closing = src.shift_char # closing )
			if closing != ?)
				maruku_error 'Unclosed link',src,con
				maruku_recover "No closing ): I will not create"+
				" the link for #{children.inspect}", src, con
				con.push_elements children
				return
			end
			con.push_element md_im_link(children,url, title)
		when ?[ # link ref
			ref_id = read_ref_id(src,con)
			if ref_id
				if ref_id.size == 0
					ref_id = sanitize_ref_id(children.to_s)
				else
					ref_id = sanitize_ref_id(ref_id)
				end	
				con.push_element md_link(children, ref_id)
			else 
				maruku_error "Could not read ref_id", src, con
				maruku_recover "I will not create the link for "+
					"#{children.inspect}", src, con
				con.push_elements children
				return
			end
		else # empty [link]
			id = sanitize_ref_id(children.to_s) #. downcase.gsub(' ','_')
			con.push_element md_link(children, id)
		end
	end # read link

	def read_image(src, con)
		src.ignore_chars(2) # opening "!["
		alt_text = read_span(src, EscapedCharInText, [?]])
		src.ignore_char # closing bracket
		# ignore space
		if src.cur_char == SPACE and 
			(src.next_char == ?[ or src.next_char == ?( )
			src.ignore_char
		end
		case src.cur_char
		when ?(
			src.ignore_char # opening (
			src.consume_whitespace
			url = read_url(src, [SPACE,?\t,?)])
			if not url
				error "Could not read url from #{src.cur_chars(10).inspect}",
					src,con
			end
			src.consume_whitespace
			title = nil
			if src.cur_char != ?) # we have a title
				quote_char = src.cur_char
				title = read_quoted(src,con)
				if not title
					maruku_error 'Must quote title',src,con
				else				
					# Tries to read a title with quotes: ![a](url "ti"tle")
					# this is the most ugly thing in Markdown
					if not src.next_matches(/\s*\)/)
						# if there is not a closing par ), then read
						# the rest and guess it's title with quotes
						rest = read_simple(src, escaped=[], break_on_chars=[?)], 
							break_on_strings=[])
						# chop the closing char
						rest.chop!
						title << quote_char << rest
					end
				end
			end
			src.consume_whitespace
			closing = src.shift_char # closing )
			if closing != ?)
				error( ("Unclosed link: '"<<closing<<"'")+
					" Read url=#{url.inspect} title=#{title.inspect}",src,con)
			end
			con.push_element md_im_image(alt_text, url, title)
		when ?[ # link ref
			ref_id = read_ref_id(src,con)
			if not ref_id # TODO: check around
				error('Reference not closed.', src, con)
				ref_id = ""
			end
			if ref_id.size == 0
				ref_id =  alt_text.to_s
			end

			ref_id = sanitize_ref_id(ref_id)

			con.push_element md_image(alt_text, ref_id)
		else # no stuff
			ref_id =  sanitize_ref_id(alt_text.to_s)
			con.push_element md_image(alt_text, ref_id)
		end
	end # read link


	class SpanContext 
		include MaRuKu::Strings
	
		# Read elements
		attr_accessor :elements
		attr_accessor :cur_string
	
		def initialize
			@elements = []
			@cur_string = ""
		end
	
		def push_element(e)
			raise "Only MDElement and String, please. You pushed #{e.class}: #{e.inspect} " if
			 not (e.kind_of?(String) or e.kind_of?(MDElement))
		
			push_string_if_present
			@elements << e
			nil
		end
		alias push push_element
		
		def push_elements(a)
			for e in a 
				if e.kind_of? String
					e.each_byte do |b| push_char b end
				else
					push_element e
				end
			end
		end
		
		def push_string_if_present
			if @cur_string.size > 0
				@elements << @cur_string
				@cur_string = ""
			end
			nil
		end
	
		def push_char(c)
			@cur_string << c 
			nil
		end
	
		# push space into current string if
		# there isn't one
		def push_space
			last = @cur_string[@cur_string.size-1]
			@cur_string << ?\  if last != ?\ 
		end
	
		def describe
			lines = @elements.map{|x| x.inspect}.join("\n")
			s = "Elements read in span: \n" +
			add_tabs(lines,1, ' -')+"\n"
		
			if @cur_string.size > 0
			s += "Current string: \n  #{@cur_string.inspect}\n" 
			end
			s
		end
	end # SpanContext
	
end end end end # module MaRuKu; module In; module Markdown; module SpanLevelParser

