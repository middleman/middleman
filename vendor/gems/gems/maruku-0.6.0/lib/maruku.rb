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

# :include:MaRuKu.txt
module MaRuKu

	module In
		module Markdown
			module SpanLevelParser; end
			module BlockLevelParser; end
		end
		# more to come?
	end

	module Out
		# Functions for exporting to MarkDown.
		module Markdown; end
		# Functions for exporting to HTML.
		module HTML; end
		# Functions for exporting to Latex
		module Latex; end
	end
		
	# These are strings utilities.
	module Strings; end

	module Helpers; end

	module Errors; end
		
	class MDElement
		include REXML
		include MaRuKu
		include Out::Markdown
		include Out::HTML
		include Out::Latex
		include Strings
		include Helpers
		include Errors
	end
	
	
	class MDDocument < MDElement
		include In::Markdown
		include In::Markdown::SpanLevelParser
		include In::Markdown::BlockLevelParser
	end
end

# This is the public interface
class Maruku < MaRuKu::MDDocument; end



require 'rexml/document'

# Structures definition
require 'maruku/structures'
require 'maruku/structures_inspect'

require 'maruku/defaults'
# Less typing
require 'maruku/helpers'

# Code for parsing whole Markdown documents
require 'maruku/input/parse_doc'

# Ugly things kept in a closet
require 'maruku/string_utils'
require 'maruku/input/linesource'
require 'maruku/input/type_detection'

# A class for reading and sanitizing inline HTML
require 'maruku/input/html_helper'

# Code for parsing Markdown block-level elements
require 'maruku/input/parse_block'

# Code for parsing Markdown span-level elements
require 'maruku/input/charsource'
require 'maruku/input/parse_span_better'
require 'maruku/input/rubypants'

require 'maruku/input/extensions'

require 'maruku/attributes'

require 'maruku/structures_iterators'

require 'maruku/errors_management'

# Code for creating a table of contents
require 'maruku/toc'

# Support for div Markdown extension
require 'maruku/ext/div'

# Version and URL
require 'maruku/version'


# Exporting to html
require 'maruku/output/to_html'

# Exporting to latex
require 'maruku/output/to_latex'
require 'maruku/output/to_latex_strings'
require 'maruku/output/to_latex_entities'

# Pretty print
require 'maruku/output/to_markdown'

# S5 slides
require 'maruku/output/s5/to_s5'
require 'maruku/output/s5/fancy'

# Exporting to text: strips all formatting (not complete)
require 'maruku/output/to_s'

# class Maruku is the global interface
require 'maruku/maruku'

