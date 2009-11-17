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



class Module
	def safe_attr_accessor1(symbol, klass)
		attr_reader symbol
		code = <<-EOF
		def #{symbol}=(val)  
			if not val.kind_of? #{klass}
				s = "\nCould not assign an object of type \#{val.class} to #{symbol}.\n\n"
				s += "Tried to assign object of class \#{val.class}:\n"+
				     "\#{val.inspect}\n"+
				     "to \#{self.class}::#{symbol} constrained to be of class #{klass}.\n"
				raise s
			end
			@#{symbol} = val
		end
		
EOF
		module_eval code
  end

	def safe_attr_accessor2(symbol, klass)
		attr_accessor symbol
	end
	
	alias  safe_attr_accessor  safe_attr_accessor2
end

module MaRuKu
	
# I did not want to have a class for each possible element. 
# Instead I opted to have only the class "MDElement"
# that represents eveything in the document (paragraphs, headers, etc).
#
# You can tell what it is by the variable `node_type`. 
#
# In the instance-variable `children` there are the children. These
# can be of class 1) String or 2) MDElement. 
#
# The @doc variable points to the document to which the MDElement
# belongs (which is an instance of Maruku, subclass of MDElement).
#
# Attributes are contained in the hash `attributes`. 
# Keys are symbols (downcased, with spaces substituted by underscores)
#
# For example, if you write in the source document.
# 
#     Title: test document
#     My property: value
#     
#     content content
#
# You can access `value` by writing:
#
#     @doc.attributes[:my_property] # => 'value'
#
# from whichever MDElement in the hierarchy.
#
class MDElement 
	# See helpers.rb for the list of allowed #node_type values
	safe_attr_accessor :node_type, Symbol
	
	# Children are either Strings or MDElement
	safe_attr_accessor :children, Array
	
	# An attribute list, may not be nil
	safe_attr_accessor :al, Array #Maruku::AttributeList

	# These are the processed attributes
	safe_attr_accessor :attributes, Hash
	
	# Reference of the document (which is of class Maruku)
	attr_accessor :doc
	
	def initialize(node_type=:unset, children=[], meta={}, 
			al=MaRuKu::AttributeList.new )
		super(); 
		self.children = children
		self.node_type = node_type
		
		@attributes = {}
		
		meta.each do |symbol, value|
			self.instance_eval "
			  def #{symbol}; @#{symbol}; end
			  def #{symbol}=(val); @#{symbol}=val; end"
			self.send "#{symbol}=", value
		end
		
		self.al = al || AttributeList.new

		self.meta_priv = meta
	end
	
	attr_accessor :meta_priv
	
	def ==(o)
		ok = o.kind_of?(MDElement) &&
		(self.node_type == o.node_type) &&
		(self.meta_priv == o.meta_priv) &&
		(self.children == o.children)
		
		if not ok
#			puts "This:\n"+self.inspect+"\nis different from\n"+o.inspect+"\n\n"
		end
		ok
	end
end

# This represents the whole document and holds global data.

class MDDocument
	
	safe_attr_accessor :refs, Hash
	safe_attr_accessor :footnotes, Hash
	
	# This is an hash. The key might be nil.
	safe_attr_accessor :abbreviations, Hash
	
	# Attribute lists definition
	safe_attr_accessor :ald, Hash
	
	# The order in which footnotes are used. Contains the id.
	safe_attr_accessor :footnotes_order, Array
	
	safe_attr_accessor :latex_required_packages, Array
	
	safe_attr_accessor :refid2ref, Hash
	
	def initialize(s=nil)
		super(:document)
		@doc       = self

		self.refs = {}
		self.footnotes = {}
		self.footnotes_order = []
		self.abbreviations = {}
		self.ald = {}
		self.latex_required_packages = []
		
		parse_doc(s) if s 
	end
end


end # MaRuKu

