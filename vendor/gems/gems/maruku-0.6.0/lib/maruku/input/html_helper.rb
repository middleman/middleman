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


module MaRuKu; module In; module Markdown; module SpanLevelParser

# This class helps me read and sanitize HTML blocks

# I tried to do this with REXML, but wasn't able to. (suggestions?)

	class HTMLHelper
		include MaRuKu::Strings
		
		Tag = %r{^<(/)?(\w+)\s*([^>]*)>}m
		PartialTag = %r{^<.*}m

		EverythingElse = %r{^[^<]+}m
		CommentStart = %r{^<!--}x
		CommentEnd = %r{^.*-->}
		TO_SANITIZE = ['img','hr','br'] 
		
		attr_reader :rest
		
		def my_debug(s)
#			puts "---"*10+"\n"+inspect+"\t>>>\t"s
		end
		
		def initialize 
			@rest = ""
			@tag_stack = []
			@m = nil
			@already = ""
			self.state = :inside_element
		end

		attr_accessor :state # = :inside_element, :inside_tag, :inside_comment,
		
		def eat_this(line)
			@rest = line  + @rest
			things_read = 0
			until @rest.empty?
				case self.state
					when :inside_comment
						if @m = CommentEnd.match(@rest)
							@already += @m.pre_match + @m.to_s
							@rest = @m.post_match
							self.state = :inside_element
						else 
							@already += @rest 
							@rest = ""
							self.state = :inside_comment
						end
					when :inside_element 
						if @m = CommentStart.match(@rest)
							things_read += 1
							@already += @m.pre_match + @m.to_s
							@rest = @m.post_match
							self.state = :inside_comment
						elsif @m = Tag.match(@rest) then
							my_debug "#{@state}: Tag: #{@m.to_s.inspect}"
							things_read += 1
							handle_tag
							self.state = :inside_element
						elsif @m = PartialTag.match(@rest) then
							my_debug "#{@state}: PartialTag: #{@m.to_s.inspect}"
							@already += @m.pre_match 
							@rest = @m.post_match
							@partial_tag = @m.to_s
							self.state = :inside_tag
						elsif @m = EverythingElse.match(@rest)
							my_debug "#{@state}: Everything: #{@m.to_s.inspect}"
							@already += @m.pre_match + @m.to_s
							@rest = @m.post_match
							self.state = :inside_element
						else
							error "Malformed HTML: not complete: #{@rest.inspect}"
						end
					when :inside_tag
						if @m = /^[^>]*>/.match(@rest) then
							my_debug "#{@state}: inside_tag: matched #{@m.to_s.inspect}"
							@partial_tag += @m.to_s
							my_debug "#{@state}: inside_tag: matched TOTAL: #{@partial_tag.to_s.inspect}"
							@rest = @partial_tag + @m.post_match
							@partial_tag = nil
							self.state = :inside_element
						else
							@partial_tag += @rest
							@rest = ""
							self.state = :inside_tag
						end
					else
						raise "Bug bug: state = #{self.state.inspect}"
				end # not inside comment
				
#				puts inspect
#				puts "Read: #{@tag_stack.inspect}"
				break if is_finished? and things_read>0	
			end
		end

		def handle_tag()
			@already += @m.pre_match
			@rest = @m.post_match

			is_closing = !!@m[1]
			tag = @m[2]
			attributes = @m[3].to_s
		
			is_single = false
			if attributes[-1] == ?/ # =~ /\A(.*)\/\Z/
				attributes = attributes[0, attributes.size-1]
				is_single = true
			end

			my_debug "Attributes: #{attributes.inspect}"
			my_debug "READ TAG #{@m.to_s.inspect} tag = #{tag} closing? #{is_closing} single = #{is_single}"
	
			if TO_SANITIZE.include? tag 
				attributes.strip!
		#		puts "Attributes: #{attributes.inspect}"
				if attributes.size > 0
					@already +=  '<%s %s />' % [tag, attributes]
				else
					@already +=  '<%s />' % [tag]
				end
			elsif is_closing
				@already += @m.to_s
				if @tag_stack.empty?
					error "Malformed: closing tag #{tag.inspect} "+
					      "in empty list"
				end 
				if @tag_stack.last != tag
					error "Malformed: tag <#{tag}> "+
					      "closes <#{@tag_stack.last}>"
				end
				@tag_stack.pop
			else 
				@already += @m.to_s
				
				if not is_single
					@tag_stack.push(tag) 
					my_debug "Pushing #{tag.inspect} when read #{@m.to_s.inspect}"
				end
			end
		end
		def error(s)
			raise Exception, "Error: #{s} \n"+ inspect, caller
		end

		def inspect; "HTML READER\n state=#{self.state} "+
			"match=#{@m.to_s.inspect}\n"+
			"Tag stack = #{@tag_stack.inspect} \n"+
			"Before:\n"+
			add_tabs(@already,1,'|')+"\n"+
			"After:\n"+
			add_tabs(@rest,1,'|')+"\n"
			
		end
		
		
		def stuff_you_read
			@already
		end
		
		def rest() @rest end
		
		def is_finished?
			(self.state == :inside_element)  and @tag_stack.empty?
		end
	end # html helper 

end end end end
