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




# A series of helper functions for creating elements: they hide the 
# particular internal representation.
#
# Please, always use these instead of creating MDElement.
#

module MaRuKu
module Helpers

	# if the first is a md_ial, it is used as such
	def md_el(node_type, children=[], meta={}, al=nil)
		if  (e=children.first).kind_of?(MDElement) and 
			e.node_type == :ial then
			if al
				al += e.ial
			else
				al = e.ial
			end
			children.shift
		end 
		e = MDElement.new(node_type, children, meta, al)
		e.doc = @doc
		return e
	end

	def md_header(level, children, al=nil)
		md_el(:header, children, {:level => level}, al)
	end
	
	# Inline code
	def md_code(code, al=nil)
		md_el(:inline_code, [], {:raw_code => code}, al)
	end

	# Code block
	def md_codeblock(source, al=nil)
		md_el(:code, [], {:raw_code => source}, al)
	end

	def md_quote(children, al=nil)
		md_el(:quote, children, {}, al)
	end

	def md_li(children, want_my_par, al=nil)
		md_el(:li, children, {:want_my_paragraph=>want_my_par}, al)
	end

	def md_footnote(footnote_id, children, al=nil)
		md_el(:footnote, children, {:footnote_id=>footnote_id}, al)
	end

	def md_abbr_def(abbr, text, al=nil)
		md_el(:abbr_def, [], {:abbr=>abbr, :text=>text}, al)
	end

	def md_abbr(abbr, title)
		md_el(:abbr, [abbr], {:title=>title})
	end
	
	def md_html(raw_html, al=nil)
		e = md_el(:raw_html, [], {:raw_html=>raw_html})
		begin
			# remove newlines and whitespace at begin
			# end end of string, or else REXML gets confused
			raw_html = raw_html.gsub(/\A\s*</,'<').
			                    gsub(/>[\s\n]*\Z/,'>')
			
			raw_html = "<marukuwrap>#{raw_html}</marukuwrap>"
			e.instance_variable_set :@parsed_html,
			 	REXML::Document.new(raw_html)
		rescue   	REXML::ParseException => ex
			e.instance_variable_set :@parsed_html, nil
			maruku_recover "REXML cannot parse this block of HTML/XML:\n"+
			add_tabs(raw_html,1,'|') + "\n"+ex.inspect
#			"  #{raw_html.inspect}\n\n"+ex.inspect
		end
		e
	end
		
	def md_link(children, ref_id, al=nil)
		md_el(:link, children, {:ref_id=>ref_id.downcase}, al)
	end
	
	def md_im_link(children, url, title=nil, al=nil)
		md_el(:im_link, children, {:url=>url,:title=>title}, al)
	end
	
	def md_image(children, ref_id, al=nil)
		md_el(:image, children, {:ref_id=>ref_id}, al)
	end
	
	def md_im_image(children, url, title=nil, al=nil)
		md_el(:im_image, children, {:url=>url,:title=>title},al)
	end

	def md_em(children, al=nil)
		md_el(:emphasis, [children].flatten, {}, al)
	end

	def md_br()
		md_el(:linebreak, [], {}, nil)
	end

	def md_hrule()
		md_el(:hrule, [], {}, nil)
	end

	def md_strong(children, al=nil)
		md_el(:strong, [children].flatten, {}, al)
	end

	def md_emstrong(children, al=nil)
		md_strong(md_em(children), al)
	end

	# <http://www.example.com/>
	def md_url(url, al=nil)
		md_el(:immediate_link, [], {:url=>url}, al)
	end
	
	# <andrea@rubyforge.org>
	# <mailto:andrea@rubyforge.org>
	def md_email(email, al=nil)
		md_el(:email_address, [], {:email=>email}, al)
	end
	
	def md_entity(entity_name, al=nil)
		md_el(:entity, [], {:entity_name=>entity_name}, al)
	end
	
	# Markdown extra
	def md_foot_ref(ref_id, al=nil)
		md_el(:footnote_reference, [], {:footnote_id=>ref_id}, al)
	end
	
	def md_par(children, al=nil)
		md_el(:paragraph, children, meta={}, al)
	end

	# [1]: http://url [properties]
	def md_ref_def(ref_id, url, title=nil, meta={}, al=nil)
		meta[:url] = url
		meta[:ref_id] = ref_id
		meta[:title] = title if title
		md_el(:ref_definition, [], meta, al)
	end
	
	# inline attribute list
	def md_ial(al)
		al = Maruku::AttributeList.new(al) if 
			not al.kind_of?Maruku::AttributeList
		md_el(:ial, [], {:ial=>al})
	end

	# Attribute list definition
	def md_ald(id, al)
		md_el(:ald, [], {:ald_id=>id,:ald=>al})
	end
	
	# Server directive <?target code... ?>
	def md_xml_instr(target, code)
		md_el(:xml_instr, [], {:target=>target, :code=>code})
	end

end
end

module MaRuKu

class MDElement	
	# outputs abbreviated form  (this should be eval()uable to get the document)
	def inspect2 
		s = 
		case @node_type
		when :paragraph
			"md_par(%s)" % children_inspect
		when :footnote_reference
			"md_foot_ref(%s)" % self.footnote_id.inspect
		when :entity
			"md_entity(%s)" % self.entity_name.inspect
		when :email_address
			"md_email(%s)" % self.email.inspect
		when :inline_code
			"md_code(%s)" % self.raw_code.inspect
		when :raw_html
			"md_html(%s)" % self.raw_html.inspect
		when :emphasis 
			"md_em(%s)" % children_inspect
		when :strong
			"md_strong(%s)" % children_inspect
		when :immediate_link
			"md_url(%s)" % self.url.inspect
		when :image
			"md_image(%s, %s)" % [
				children_inspect, 
				self.ref_id.inspect]
		when :im_image
			"md_im_image(%s, %s, %s)" % [
				children_inspect, 
				self.url.inspect,
				self.title.inspect]
		when :link
				"md_link(%s,%s)" % [
					children_inspect, self.ref_id.inspect]
		when :im_link
				"md_im_link(%s, %s, %s)" % [
					children_inspect, 
					self.url.inspect,
					self.title.inspect,
				]
		when :ref_definition
			"md_ref_def(%s, %s, %s)" % [
					self.ref_id.inspect, 
					self.url.inspect,
					self.title.inspect
				]
		when :ial
			"md_ial(%s)" % self.ial.inspect
		else
			return nil
		end
		if @al and not @al.empty? then 
			s = s.chop + ", #{@al.inspect})"
		end
		s
	end
	
end

end







