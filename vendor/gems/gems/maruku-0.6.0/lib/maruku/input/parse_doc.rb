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


require 'iconv'


module MaRuKu; module In; module Markdown; module BlockLevelParser
		
	def parse_doc(s)
		# FIXME \r\n => \n
		meta2 =  parse_email_headers(s)
		data = meta2[:data]
		meta2.delete :data
		
		self.attributes.merge! meta2
		
=begin maruku_doc
Attribute: encoding
Scope:     document
Summary:   Encoding for the document.

If the `encoding` attribute is specified, then the content
will be converted from the specified encoding to UTF-8.

Conversion happens using the `iconv` library.
=end

		enc = self.attributes[:encoding]
		self.attributes.delete :encoding
		if enc && enc.downcase != 'utf-8'
			converted = Iconv.new('utf-8', enc).iconv(data)
			
#			puts "Data: #{data.inspect}: #{data}"
#			puts "Conv: #{converted.inspect}: #{converted}"
			
			data = converted
		end
		
		@children = parse_text_as_markdown(data)
		
		if true #markdown_extra? 
			self.search_abbreviations
			self.substitute_markdown_inside_raw_html
		end
		
		toc = create_toc

		# use title if not set
		if not self.attributes[:title] and toc.header_element
			title = toc.header_element.to_s
			self.attributes[:title]  = title
#			puts "Set document title to #{title}"
		end
		
		# save for later use
		self.toc = toc
		
		# Now do the attributes magic
		each_element do |e|
			# default attribute list
			if default = self.ald[e.node_type.to_s]
				expand_attribute_list(default, e.attributes)
			end
			expand_attribute_list(e.al, e.attributes)
#			puts "#{e.node_type}: #{e.attributes.inspect}"
		end
	
=begin maruku_doc
Attribute: unsafe_features
Scope:     global
Summary:   Enables execution of XML instructions.

Disabled by default because of security concerns.
=end

		if Maruku::Globals[:unsafe_features]
			self.execute_code_blocks
			# TODO: remove executed code blocks
		end
	end
	
	# Expands an attribute list in an Hash
	def expand_attribute_list(al, result)
		al.each do |k, v|
			case k
			when :class
				if not result[:class]
					result[:class] = v
				else
					result[:class] += " " + v
				end
			when :id; result[:id] = v
			when :ref; 
				if self.ald[v]
					already = (result[:expanded_references] ||= [])
					if not already.include?(v)
						already.push v
						expand_attribute_list(self.ald[v], result)
					else
						already.push  v
						maruku_error "Circular reference between labels.\n\n"+
						"Label #{v.inspect} calls itself via recursion.\nThe recursion is "+
							(already.map{|x| x.inspect}.join(' => ')) 
					end
				else
					if not result[:unresolved_references]
						result[:unresolved_references] = v
					else
						result[:unresolved_references] << " #{v}"
					end
					
				#	$stderr.puts "Unresolved reference #{v.inspect} (avail: #{self.ald.keys.inspect})"
					result[v.to_sym] = true
				end
			else
				result[k.to_sym]=v
			end
		end
	end

	def safe_execute_code(object, code)
		begin
			return object.instance_eval(code)
		rescue Exception => e
			maruku_error "Exception while executing this:\n"+
				add_tabs(code, 1, ">")+
				"\nThe error was:\n"+
				add_tabs(e.inspect+"\n"+e.caller.join("\n"), 1, "|")
		rescue RuntimeError => e
			maruku_error "2: Exception while executing this:\n"+
				add_tabs(code, 1, ">")+
				"\nThe error was:\n"+
				add_tabs(e.inspect, 1, "|")
		rescue SyntaxError => e
			maruku_error "2: Exception while executing this:\n"+
				add_tabs(code, 1, ">")+
				"\nThe error was:\n"+
				add_tabs(e.inspect, 1, "|")
		end
		nil
	end
	
	def execute_code_blocks
		self.each_element(:xml_instr) do |e|
			if e.target == 'maruku'
				result = safe_execute_code(e, e.code)
				if result.kind_of?(String)
					puts "Result is : #{result.inspect}"
				end
			end
		end
	end
	
	def search_abbreviations
		self.abbreviations.each do |abbrev, title|
			reg = Regexp.new(Regexp.escape(abbrev))
			self.replace_each_string do |s|
				# bug if many abbreviations are present (agorf)
				if m = reg.match(s)
					e = md_abbr(abbrev.dup, title ? title.dup : nil)
					[m.pre_match, e, m.post_match]
				else
					s
				end
			end
		end
	end
	
	include REXML
	# (PHP Markdown extra) Search for elements that have
	# markdown=1 or markdown=block defined
	def substitute_markdown_inside_raw_html
		self.each_element(:raw_html) do |e|
			doc = e.instance_variable_get :@parsed_html
			if doc # valid html
				# parse block-level markdown elements in these HTML tags
				block_tags = ['div']

				# use xpath to find elements with 'markdown' attribute
				XPath.match(doc, "//*[attribute::markdown]" ).each do |e|
#					puts "Found #{e}"
					# should we parse block-level or span-level?
					
					how = e.attributes['markdown']
					parse_blocks = (how == 'block') || block_tags.include?(e.name)
					               
					# Select all text elements of e
					XPath.match(e, "//text()" ).each { |original_text| 
						s = original_text.value.strip
						if s.size > 0

					#	    puts "Parsing #{s.inspect} as blocks: #{parse_blocks}  (#{e.name}, #{e.attributes['markdown']})  "

							el = md_el(:dummy,
							 	parse_blocks ? parse_text_as_markdown(s) :
							                  parse_lines_as_span([s]) )
							p = original_text.parent
							el.children_to_html.each do |x|
								p.insert_before(original_text, x)
							end
							p.delete(original_text)
							
						end
					}
					
					
          # remove 'markdown' attribute
          e.delete_attribute 'markdown'
          
				end
				
			end
		end
	end
	
end end end end
