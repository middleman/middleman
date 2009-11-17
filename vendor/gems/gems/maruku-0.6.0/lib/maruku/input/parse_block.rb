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


module MaRuKu; module In; module Markdown; module BlockLevelParser

	include Helpers
	include MaRuKu::Strings
	include MaRuKu::In::Markdown::SpanLevelParser

	class BlockContext < Array
		def describe
			n = 5
			desc = size > n ? self[-n,n] : self
			"Last #{n} elements: "+
			desc.map{|x| "\n -" + x.inspect}.join
		end
	end
	
	# Splits the string and calls parse_lines_as_markdown
	def parse_text_as_markdown(text)
		lines =  split_lines(text)
		src = LineSource.new(lines)
		return parse_blocks(src)
	end
	
	# Input is a LineSource
	def parse_blocks(src)
		output = BlockContext.new
		
		# run state machine
		while src.cur_line
			
			next if check_block_extensions(src, output, src.cur_line)
			
#  Prints detected type (useful for debugging)
#			puts "#{src.cur_line.md_type}|#{src.cur_line}"
			case src.cur_line.md_type
				when :empty; 
					output.push :empty
					src.ignore_line
				when :ial
					m =  InlineAttributeList.match src.shift_line
					content = m[1] ||  "" 
#					puts "Content: #{content.inspect}"
					src2 = CharSource.new(content, src)
					interpret_extension(src2, output, [nil])
				when :ald
					output.push read_ald(src)
				when :text
					# paragraph, or table, or definition list
					read_text_material(src, output)
				when :header2, :hrule
					# hrule
					src.shift_line
					output.push md_hrule()
				when :header3
					output.push read_header3(src)
				when :ulist, :olist
					list_type = src.cur_line.md_type == :ulist ? :ul : :ol
					li = read_list_item(src)
					# append to current list if we have one
					if output.last.kind_of?(MDElement) && 
						output.last.node_type == list_type then
						output.last.children << li
					else
						output.push md_el(list_type, [li])
					end
				when :quote;    output.push read_quote(src)
				when :code;     e = read_code(src); output << e if e
				when :raw_html; e = read_raw_html(src); output << e if e

				when :footnote_text;   output.push read_footnote_text(src)
				when :ref_definition;  
					if src.parent && (src.cur_index == 0)
						read_text_material(src, output)
					else
						read_ref_definition(src, output)
					end
				when :abbreviation;    output.push read_abbreviation(src)
				when :xml_instr;       read_xml_instruction(src, output)
				when :metadata;        
					maruku_error "Please use the new meta-data syntax: \n"+
					"  http://maruku.rubyforge.org/proposal.html\n", src
					src.ignore_line
				else # warn if we forgot something
					md_type = src.cur_line.md_type
					line = src.cur_line
					maruku_error "Ignoring line '#{line}' type = #{md_type}", src
					src.shift_line
			end
		end

		merge_ial(output, src, output)
		output.delete_if {|x| x.kind_of?(MDElement) &&
			x.node_type == :ial}
		
		# get rid of empty line markers
		output.delete_if {|x| x == :empty}
		# See for each list if we can omit the paragraphs and use li_span
		# TODO: do this after
		output.each do |c| 
			# Remove paragraphs that we can get rid of
			if [:ul,:ol].include? c.node_type 
				if c.children.all? {|li| !li.want_my_paragraph} then
					c.children.each do |d|
						d.node_type = :li_span
						d.children = d.children[0].children 
					end
				end
			end 
			if c.node_type == :definition_list
				if c.children.all?{|defi| !defi.want_my_paragraph} then
					c.children.each do |definition| 
						definition.definitions.each do |dd|
							dd.children = dd.children[0].children 
						end
					end
				end
			end 
		end
		
		output
	end
	
	def read_text_material(src, output)
		if src.cur_line =~ MightBeTableHeader and 
			(src.next_line && src.next_line =~ TableSeparator)
			output.push read_table(src)
		elsif [:header1,:header2].include? src.next_line.md_type
			output.push read_header12(src)
		elsif eventually_comes_a_def_list(src)
		 	definition = read_definition(src)
			if output.last.kind_of?(MDElement) && 
				output.last.node_type == :definition_list then
				output.last.children << definition
			else
				output.push md_el(:definition_list, [definition])
			end
		else # Start of a paragraph
			output.push read_paragraph(src)
		end
	end
	
	
	def read_ald(src)
		if (l=src.shift_line) =~ AttributeDefinitionList
			id = $1;   al=$2;
			al = read_attribute_list(CharSource.new(al,src), context=nil, break_on=[nil])
			self.ald[id] = al;
			return md_ald(id, al)
		else
			maruku_error "Bug Bug:\n#{l.inspect}"
			return nil
		end
	end
		
	# reads a header (with ----- or ========)
	def read_header12(src)
		line = src.shift_line.strip
		al = nil
		# Check if there is an IAL
		if new_meta_data? and line =~ /^(.*)\{(.*)\}\s*$/
			line = $1.strip
			ial = $2
			al  = read_attribute_list(CharSource.new(ial,src), context=nil, break_on=[nil])
		end
		text = parse_lines_as_span [ line ]
		level = src.cur_line.md_type == :header2 ? 2 : 1;  
		src.shift_line
		return md_header(level, text, al)
	end

	# reads a header like '#### header ####'	
	def read_header3(src)
		line = src.shift_line.strip
		al = nil
		# Check if there is an IAL
		if new_meta_data? and line =~ /^(.*)\{(.*)\}\s*$/
			line = $1.strip
			ial = $2
			al  = read_attribute_list(CharSource.new(ial,src), context=nil, break_on=[nil])
		end
		level = num_leading_hashes(line)
		text = parse_lines_as_span [strip_hashes(line)] 
		return md_header(level, text, al)
	end

	def read_xml_instruction(src, output)
		m = /^\s*<\?((\w+)\s*)?(.*)$/.match src.shift_line
		raise "BugBug" if not m
		target = m[2] || ''
		code = m[3]
		until code =~ /\?>/
			code += "\n"+src.shift_line
		end
		if not code =~ (/\?>\s*$/)
			garbage = (/\?>(.*)$/.match(code))[1]
			maruku_error "Trailing garbage on last line: #{garbage.inspect}:\n"+
				add_tabs(code, 1, '|'), src
		end
		code.gsub!(/\?>\s*$/, '')
		
		if target == 'mrk' && MaRuKu::Globals[:unsafe_features]
			result = safe_execute_code(self, code)	
			if result
				if result.kind_of? String
					raise "Not expected"
				else
					output.push(*result)
				end
			end
		else
			output.push md_xml_instr(target, code)
		end
	end
	
	def read_raw_html(src)
		h = HTMLHelper.new
		begin 
			h.eat_this(l=src.shift_line)
#			puts "\nBLOCK:\nhtml -> #{l.inspect}"
			while src.cur_line and not h.is_finished? 
				l=src.shift_line
#				puts "html -> #{l.inspect}"
				h.eat_this "\n"+l
			end
		rescue Exception => e
			ex = e.inspect + e.backtrace.join("\n")
			maruku_error "Bad block-level HTML:\n#{add_tabs(ex,1,'|')}\n", src
		end
		if not (h.rest =~ /^\s*$/)
			maruku_error "Could you please format this better?\n"+
				"I see that #{h.rest.inspect} is left after the raw HTML.", src
		end
		raw_html = h.stuff_you_read
		
		return md_html(raw_html)
	end
	
	def read_paragraph(src)
		lines = [src.shift_line]
		while src.cur_line 
			# :olist does not break
			case t = src.cur_line.md_type
				when :quote,:header3,:empty,:ref_definition,:ial #,:xml_instr,:raw_html
					break
				when :olist,:ulist
					break if src.next_line.md_type == t
			end
			break if src.cur_line.strip.size == 0			
			break if [:header1,:header2].include? src.next_line.md_type
			break if any_matching_block_extension?(src.cur_line) 
			
			lines << src.shift_line
		end
#		dbg_describe_ary(lines, 'PAR')
		children = parse_lines_as_span(lines, src)

		return md_par(children)
	end
	
	# Reads one list item, either ordered or unordered.
	def read_list_item(src)
		parent_offset = src.cur_index
		
		item_type = src.cur_line.md_type
		first = src.shift_line

		indentation = spaces_before_first_char(first)
		break_list = [:ulist, :olist, :ial]
		# Ugly things going on inside `read_indented_content`
		lines, want_my_paragraph = 
			read_indented_content(src,indentation, break_list, item_type)

		# add first line
			# Strip first '*', '-', '+' from first line
			stripped = first[indentation, first.size-1]
		lines.unshift stripped
		
		# dbg_describe_ary(lines, 'LIST ITEM ')

		src2 = LineSource.new(lines, src, parent_offset)
		children = parse_blocks(src2)
		with_par = want_my_paragraph || (children.size>1)
		
		return md_li(children, with_par)
	end

	def read_abbreviation(src)
		if not (l=src.shift_line) =~ Abbreviation
			maruku_error "Bug: it's Andrea's fault. Tell him.\n#{l.inspect}"
		end
		
		abbr = $1
		desc = $2
		
		if (not abbr) or (abbr.size==0)
			maruku_error "Bad abbrev. abbr=#{abbr.inspect} desc=#{desc.inspect}"
		end
		
		self.abbreviations[abbr] = desc
		
		return md_abbr_def(abbr, desc)
	end
	
	def read_footnote_text(src)
		parent_offset = src.cur_index
			
		first = src.shift_line
		
		if not first =~ FootnoteText 
			maruku_error "Bug (it's Andrea's fault)"
		end
		
		id = $1
		text = $2

		# Ugly things going on inside `read_indented_content`
		indentation = 4 #first.size-text.size
		
#		puts "id =_#{id}_; text=_#{text}_ indent=#{indentation}"
		
		break_list = [:footnote_text, :ref_definition, :definition, :abbreviation]
		item_type = :footnote_text
		lines, want_my_paragraph = 
			read_indented_content(src,indentation, break_list, item_type)

		# add first line
		if text && text.strip != "" then lines.unshift text end
		
#		dbg_describe_ary(lines, 'FOOTNOTE')
		src2 = LineSource.new(lines, src, parent_offset)
		children = parse_blocks(src2)
		
		e = md_footnote(id, children)
		self.footnotes[id] = e
		return e
	end


	# This is the only ugly function in the code base.
	# It is used to read list items, descriptions, footnote text
	def read_indented_content(src, indentation, break_list, item_type)
		lines =[]
		# collect all indented lines
		saw_empty = false; saw_anything_after = false
		while src.cur_line 
#			puts "Reading indent = #{indentation} #{src.cur_line.inspect}"
			#puts "#{src.cur_line.md_type} #{src.cur_line.inspect}"
			if src.cur_line.md_type == :empty
				saw_empty = true
				lines << src.shift_line
				next
			end
		
			# after a white line
			if saw_empty
				# we expect things to be properly aligned
				if (ns=number_of_leading_spaces(src.cur_line)) < indentation
					#puts "breaking for spaces, only #{ns}: #{src.cur_line}"
					break
				end
				saw_anything_after = true
			else
#				if src.cur_line[0] != ?\ 
					break if break_list.include? src.cur_line.md_type
#				end
#				break if src.cur_line.md_type != :text
			end
		

			stripped = strip_indent(src.shift_line, indentation)
			lines << stripped

			#puts "Accepted as #{stripped.inspect}"
		
			# You are only required to indent the first line of 
			# a child paragraph.
			if stripped.md_type == :text
				while src.cur_line && (src.cur_line.md_type == :text)
					lines << strip_indent(src.shift_line, indentation)
				end
			end
		end

		want_my_paragraph = saw_anything_after || 
			(saw_empty && (src.cur_line  && (src.cur_line.md_type == item_type))) 
	
#		dbg_describe_ary(lines, 'LI')
		# create a new context 
	
		while lines.last && (lines.last.md_type == :empty)
			lines.pop
		end
		
		return lines, want_my_paragraph
	end

	
	def read_quote(src)
		parent_offset = src.cur_index
			
		lines = []
		# collect all indented lines
		while src.cur_line && src.cur_line.md_type == :quote
			lines << unquote(src.shift_line)
		end
#		dbg_describe_ary(lines, 'QUOTE')

		src2 = LineSource.new(lines, src, parent_offset)
		children = parse_blocks(src2)
		return md_quote(children)
	end

	def read_code(src)
		# collect all indented lines
		lines = []
		while src.cur_line && ([:code, :empty].include? src.cur_line.md_type)
			lines << strip_indent(src.shift_line, 4)
		end
		
		#while lines.last && (lines.last.md_type == :empty )
		while lines.last && lines.last.strip.size == 0
			lines.pop 
		end

		while lines.first && lines.first.strip.size == 0
			lines.shift 
		end
		
		return nil if lines.empty?

		source = lines.join("\n")
		
#		dbg_describe_ary(lines, 'CODE')

		return md_codeblock(source)
	end

	# Reads a series of metadata lines with empty lines in between
	def read_metadata(src)
		hash = {}
		while src.cur_line 
			case src.cur_line.md_type
				when :empty;  src.shift_line
				when :metadata; hash.merge! parse_metadata(src.shift_line)
				else break
			end
		end
		hash
	end
	
		
	def read_ref_definition(src, out)	
		line = src.shift_line
		
		
		# if link is incomplete, shift next line
		if src.cur_line && !([:footnote_text, :ref_definition, :definition, :abbreviation].include? src.cur_line.md_type) && 
			([1,2,3].include? number_of_leading_spaces(src.cur_line) ) 
			line += " "+ src.shift_line
		end
		
#		puts "total= #{line}"
		
		match = LinkRegex.match(line)
		if not match
			maruku_error "Link does not respect format: '#{line}'"
			return
		end
		
		id = match[1]; url = match[2]; title = match[3]; 
		id = sanitize_ref_id(id)
		
		hash = self.refs[id] = {:url=>url,:title=>title}
		
		stuff=match[4]
		
		if stuff
			stuff.split.each do |couple|
#					puts "found #{couple}"
				k, v = couple.split('=')
				v ||= ""
				if v[0,1]=='"' then v = v[1, v.size-2] end
#					puts "key:_#{k}_ value=_#{v}_"
				hash[k.to_sym] = v
			end
		end
#			puts hash.inspect
		
		out.push md_ref_def(id, url, meta={:title=>title})
	end
	
	def split_cells(s)
#		s.strip.split('|').select{|x|x.strip.size>0}.map{|x|x.strip}
# changed to allow empty cells
		s.strip.split('|').select{|x|x.size>0}.map{|x|x.strip}
	end

	def read_table(src)
		head = split_cells(src.shift_line).map{|s| md_el(:head_cell, parse_lines_as_span([s])) }
			
		separator=split_cells(src.shift_line)

		align = separator.map { |s|  s =~ Sep
			if $1 and $2 then :center elsif $2 then :right else :left end }
				
		num_columns = align.size
		
		if head.size != num_columns
			maruku_error "Table head does not have #{num_columns} columns: \n#{head.inspect}"
			tell_user "I will ignore this table."
			# XXX try to recover
			return md_br()
		end
				
		rows = []
		
		while src.cur_line && src.cur_line =~ /\|/
			row = split_cells(src.shift_line).map{|s|
				md_el(:cell, parse_lines_as_span([s]))}
			if head.size != num_columns
				maruku_error  "Row does not have #{num_columns} columns: \n#{row.inspect}"
				tell_user "I will ignore this table."
				# XXX try to recover
				return md_br()
			end
			rows << row
		end

		children = (head+rows).flatten
		return md_el(:table, children, {:align => align})
	end
	
	# If current line is text, a definition list is coming
	# if 1) text,empty,[text,empty]*,definition
	
	def eventually_comes_a_def_list(src)
		future = src.tell_me_the_future
		ok = future =~ %r{^t+e?d}x
#		puts "future: #{future} - #{ok}"
		ok
	end
	
		
	def read_definition(src)
		# Read one or more terms
		terms = []
		while  src.cur_line &&  src.cur_line.md_type == :text
			terms << md_el(:definition_term, parse_lines_as_span([src.shift_line]))
		end
#		dbg_describe_ary(terms, 'DT')

		want_my_paragraph = false

		raise "Chunky Bacon!" if not src.cur_line

		# one optional empty
		if src.cur_line.md_type == :empty
			want_my_paragraph = true
			src.shift_line
		end
		
		raise "Chunky Bacon!" if src.cur_line.md_type != :definition
		
		# Read one or more definitions
		definitions = []
		while src.cur_line && src.cur_line.md_type == :definition
			parent_offset = src.cur_index
				
			first = src.shift_line
			first =~ Definition
			first = $1
			
			# I know, it's ugly!!!

			lines, w_m_p = 
				read_indented_content(src,4, [:definition], :definition)
			want_my_paragraph ||= w_m_p
		
			lines.unshift first
			
#			dbg_describe_ary(lines, 'DD')
			src2 = LineSource.new(lines, src, parent_offset)
			children = parse_blocks(src2)
			definitions << md_el(:definition_data, children)
		end
		
		return md_el(:definition, terms+definitions, { 	
			:terms => terms, 
			:definitions => definitions, 
			:want_my_paragraph => want_my_paragraph})
	end
end # BlockLevelParser
end # MaRuKu
end
end