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
	# an instance of Section (see below)
	attr_accessor :toc 
end

	# This represents a section in the TOC.
	class Section
		# a Fixnum, is == header_element.level
		attr_accessor :section_level 
		
		# An array of fixnum, like [1,2,5] for Section 1.2.5
		attr_accessor :section_number 
		
		# reference to header (header has h.meta[:section] to self)
		attr_accessor :header_element

		# Array of immediate children of this element
		attr_accessor :immediate_children
		
		# Array of Section inside this section
		attr_accessor :section_children
		
		def initialize
			@immediate_children = []
			@section_children = []
		end
	end 

	class Section
		def inspect(indent=1)
			s = ""
			if @header_element
				s +=  "\_"*indent +  "(#{@section_level})>\t #{@section_number.join('.')} : "
				s +=  @header_element.children_to_s +
				 " (id: '#{@header_element.attributes[:id]}')\n"
			else
				s += "Master\n"
			end
			
			@section_children.each do |c|
				s+=c.inspect(indent+1)
			end
			s
		end
		
		# Numerate this section and its children
		def numerate(a=[])
			self.section_number = a
			section_children.each_with_index do |c,i|
				c.numerate(a.clone.push(i+1))
			end
			if h = self.header_element
				h.attributes[:section_number] = self.section_number
			end
		end
		
		include REXML
		# Creates an HTML toc.
		# Call this on the root 
		def to_html
			div = Element.new 'div'
			div.attributes['class'] = 'maruku_toc'
			div << create_toc
			div
		end
		
		def create_toc
			ul = Element.new 'ul'
			# let's remove the bullets
			ul.attributes['style'] = 'list-style: none;' 
			@section_children.each do |c|
				li = Element.new 'li'
				if span = c.header_element.render_section_number
					li << span
				end
				a = c.header_element.wrap_as_element('a')
					a.delete_attribute 'id'
					a.attributes['href'] = "##{c.header_element.attributes[:id]}"
				li << a
				li << c.create_toc if c.section_children.size>0
				ul << li
			end
			ul
		end

		# Creates a latex toc.
		# Call this on the root 
		def to_latex
			to_latex_rec + "\n\n"
		end
		
		def to_latex_rec
			s = ""
			@section_children.each do |c|
				s += "\\noindent"
				number = c.header_element.section_number
				s += number if number
					text = c.header_element.children_to_latex
					id = c.header_element.attributes[:id]
				s += "\\hyperlink{#{id}}{#{text}}"
				s += "\\dotfill \\pageref*{#{id}} \\linebreak\n"
				s += c.to_latex_rec  if c.section_children.size>0

			end
			s
		end
		
	end

	class MDDocument
	
		def create_toc
			each_element(:header) do |h|
				h.attributes[:id] ||= h.generate_id
			end
		
			stack = []
		
			# the ancestor section
			s = Section.new
			s.section_level = 0

			stack.push s
	
			i = 0;
			while i < @children.size
				while i < @children.size 
					if @children[i].node_type == :header
						level = @children[i].level
						break if level <= stack.last.section_level+1
					end
				
					stack.last.immediate_children.push @children[i]
					i += 1
				end

				break if i>=@children.size
			
				header = @children[i]
				level = header.level
			
				if level > stack.last.section_level
					# this level is inside
				
					s2 = Section.new
					s2.section_level = level
					s2.header_element = header
					header.instance_variable_set :@section, s2
				
					stack.last.section_children.push s2
					stack.push s2
				
					i+=1
				elsif level == stack.last.section_level
					# this level is a sibling
					stack.pop
				else 
					# this level is a parent
					stack.pop
				end
			
			end

			# If there is only one big header, then assume
			# it is the master
			if s.section_children.size == 1
				s = s.section_children.first
			end
		
			# Assign section numbers
			s.numerate
	
			s
		end
	end
end