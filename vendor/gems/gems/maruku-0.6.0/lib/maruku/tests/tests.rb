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


require 'maruku'

class Maruku
	
	
	def Maruku.failed(test, doc, s)
		raise "Test failed: #{s}\n*****\n#{test}\n*****\n"+
		"#{doc.inspect}\n*****\n{doc.to_html}"
	end

	def Maruku.metaTests
		ref = {:id => 'id1', :class => ['class1','class2'], 
			:style=> 'Style is : important = for all } things'}
	
		
		tests = MetaTests.split('***')
		for test in tests
			#puts "Test: #{test.inspect}"
			doc = Maruku.new(test)
			
			doc.children.size == 1 ||
			failed(test, doc, "children != 1") 
				
			
			h = doc.children[0]
			
			h.node_type==:header ||
			failed(test, doc, "child not header") 
			
#			puts doc.inspect
#			puts doc.to_html
		end
	end
	
MetaTests = <<EOF

# Head # {ref1 ref2 ref3}

{ref1}: id: id1; class: class1
{ref2}: class: class2
{ref3}: style: "Style is : important = for all } things"  

***

# Head # {ref1 ref3 ref2}

{ref1}: id: id1; class: class1
{ref2}: class: class2
{ref3}: style: "Style is : important = for all } things"  

***

# Head # {ref1 ref2 ref3}

{ref1}: id= id1; class=class1
{ref2}: class=class2
{ref3}: style="Style is : important = for all } things"

***

# Head # {ref1 ref2 ref3}

{ref1}: id=id1 class=class1
{ref2}: class=class2
{ref3}: style="Style is : important = for all } things"

***
# Head # {ref1 ref2 ref3}

{ref1}: id:id1	class:class1
{ref2}: class : class2
{ref3}: style	=	"Style is : important = for all } things"

***
# Head # {ref1 ref2 ref3}

{ref1}: id:id1	class:class1
  {ref2}: class : class2
   {ref3}: style	=	"Style is : important = for all } things"

***

# Head # {#id1 .class1 ref2 ref3}

{ref2}: class : class2
{ref3}: style	=	"Style is : important = for all } things"

***

# Head #  	 {  #id1	.class1	 	ref2	  ref3	}

{ref2}: class : class2
{ref3}: style	=	"Style is : important = for all } things"

***

# Head #  	 {  id=id1	class=class1	 	ref2	  ref3	}

{ref2}: class : class2
{ref3}: style	=	"Style is : important = for all } things"

***

# Head #  	 {  id:id1	class="class1" class:"class2"  style="Style is : important = for all } things"}

EOF

end

if File.basename($0) == 'tests.rb'
	Maruku.metaTests
	
end


