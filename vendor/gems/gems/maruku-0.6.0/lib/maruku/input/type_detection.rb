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
	include MaRuKu::Strings
	def md_type()
		@md_type ||= line_md_type(self)
	end
end

class NilClass
	def md_type() nil end
	
end

# This code does the classification of lines for block-level parsing.
module MaRuKu; module Strings
	
	def line_md_type(l)
		# The order of evaluation is important (:text is a catch-all)
		return :text   if l =~ /^[a-zA-Z]/
		return :code             if number_of_leading_spaces(l)>=4
		return :empty    if l =~ /^\s*$/
		return :footnote_text    if l =~ FootnoteText
		return :ref_definition   if l =~ LinkRegex or l=~ IncompleteLink
		return :abbreviation     if l =~ Abbreviation
		return :definition       if l =~ Definition
		# I had a bug with emails and urls at the beginning of the 
		# line that were mistaken for raw_html
		return :text if l=~ /^[ ]{0,3}#{EMailAddress}/
		return :text if l=~ /^[ ]{0,3}<http:/
		# raw html is like PHP Markdown Extra: at most three spaces before
		return :xml_instr if l =~ %r{^\s*<\?}
		return :raw_html if l =~ %r{^[ ]?[ ]?[ ]?</?\s*\w+}
		return :raw_html if l =~ %r{^[ ]?[ ]?[ ]?<\!\-\-}
		# Something is wrong with how we parse lists! :-(
		#return :ulist    if l =~ /^[ ]{0,3}([\*\-\+])\s+.*\w+/
		#return :olist    if l =~ /^[ ]{0,3}\d+\..*\w+/
		return :ulist    if l =~ /^[ ]{0,1}([\*\-\+])\s+.*\w+/
		return :olist    if l =~ /^[ ]{0,1}\d+\..*\w+/
		return :header1  if l =~ /^(=)+/ 
		return :header2  if l =~ /^([-\s])+$/ 
		return :header3  if l =~ /^(#)+\s*\S+/ 
		# at least three asterisks on a line, and only whitespace
		return :hrule    if l =~ /^(\s*\*\s*){3,1000}$/ 
		return :hrule    if l =~ /^(\s*-\s*){3,1000}$/ # or hyphens
		return :hrule    if l =~ /^(\s*_\s*){3,1000}$/ # or underscores	
		return :quote    if l =~ /^>/
		return :metadata if l =~ /^@/
#		if @@new_meta_data?
			return :ald   if l =~ AttributeDefinitionList
			return :ial   if l =~ InlineAttributeList
#		end
#		return :equation_end if l =~ EquationEnd
		return :text # else, it's just text
	end

		
	# $1 = id   $2 = attribute list
	AttributeDefinitionList = /^\s{0,3}\{([\w\d\s]+)\}:\s*(.*)\s*$/
	# 
	InlineAttributeList = /^\s{0,3}\{([:#\.].*)\}\s*$/
	# Example:
	#     ^:blah blah
	#     ^: blah blah
	#     ^   : blah blah
	Definition = %r{ 
		^ # begin of line
		[ ]{0,3} # up to 3 spaces
		: # colon
		\s* # whitespace
		(\S.*) # the text    = $1
		$ # end of line
	}x

	# Example:
	#     *[HTML]: Hyper Text Markup Language
	Abbreviation = %r{
		^  # begin of line
		[ ]{0,3} # up to 3 spaces
		\* # one asterisk
		\[ # opening bracket
		([^\]]+) # any non-closing bracket:  id = $1
		\] # closing bracket
		:  # colon
		\s* # whitespace
		(\S.*\S)* #           definition=$2
		\s* # strip this whitespace
		$   # end of line
	}x

	FootnoteText = %r{
		^  # begin of line
		[ ]{0,3} # up to 3 spaces
		\[(\^.+)\]: # id = $1 (including '^')
		\s*(\S.*)?$    # text = $2 (not obb.)
	}x

	# This regex is taken from BlueCloth sources
	# Link defs are in the form: ^[id]: \n? url "optional title"
	LinkRegex = %r{
		^[ ]{0,3}\[([^\[\]]+)\]:		# id = $1
		  [ ]*
		<?([^>\s]+)>?				# url = $2
		  [ ]*
		(?:# Titles are delimited by "quotes" or (parens).
			["(']
			(.+?)			# title = $3
			[")']			# Matching ) or "
			\s*(.+)?   # stuff = $4
		)?	# title is optional
	  }x

	IncompleteLink = %r{^[ ]{0,3}\[([^\[\]]+)\]:\s*$}

	HeaderWithId = /^(.*)\{\#([\w_-]+)\}\s*$/

	HeaderWithAttributes = /^(.*)\{(.*)\}\s*$/


	# if contains a pipe, it could be a table header
	MightBeTableHeader = %r{\|}
	# -------------:
	Sep = /\s*(\:)?\s*-+\s*(\:)?\s*/
	# | -------------:| ------------------------------ |
	TableSeparator = %r{^(\|?#{Sep}\|?)+\s*$}


	EMailAddress = /<([^:]+@[^:]+)>/
end end
