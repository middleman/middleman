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
require 'maruku/ext/math'

module MaRuKu; module Tests
	# 5 accented letters in italian, encoded as UTF-8
	AccIta8 = "\303\240\303\250\303\254\303\262\303\271"

	# Same letters, written in ISO-8859-1 (one byte per letter)
	AccIta1 = "\340\350\354\362\371"
	
	# The word MA-RU-KU, written in katakana using UTF-8
	Maruku8 = "\343\203\236\343\203\253\343\202\257"
	
	def test_span_parser(verbose, break_on_first_error, quiet)
	good_cases = [
		
		["",       [],         'Empty string gives empty list'],
		["a",      ["a"],      'Easy char'],
		[" a",     ["a"],      'First space in the paragraph is ignored'],
		["a\n \n", ["a"],      'Last spaces in the paragraphs are ignored'],
		[' ',      [],      'One char => nothing'],
		['  ',     [],      'Two chars => nothing'],
		['a  b',   ['a b'],    'Spaces are compressed'],
		['a  b',   ['a b'],    'Newlines are spaces'],
		["a\nb",   ['a b'],    'Newlines are spaces'],
		["a\n b",  ['a b'],    'Compress newlines 1'],
		["a \nb",  ['a b'],    'Compress newlines 2'],
		[" \nb",   ['b'],      'Compress newlines 3'],
		["\nb",    ['b'],      'Compress newlines 4'],
		["b\n",    ['b'],     'Compress newlines 5'],
		["\n",     [],      'Compress newlines 6'],
		["\n\n\n", [],      'Compress newlines 7'],
		
		[nil, :throw, "Should throw on nil input"],
		
		# Code blocks
		["`" ,   :throw,  'Unclosed single ticks'],
		["``" ,  :throw,  'Unclosed double ticks'],
		["`a`" ,     [md_code('a')],    'Simple inline code'],
		["`` ` ``" ,    [md_code('`')],   ],
		["`` \\` ``" ,    [md_code('\\`')],   ],
		["``a``" ,   [md_code('a')],    ],
		["`` a ``" ,   [md_code('a')],    ],
		
		# Newlines 
		["a  \n", ['a',md_el(:linebreak)], 'Two spaces give br.'],
		["a \n",  ['a'], 'Newlines 2'],
		["  \n",  [md_el(:linebreak)], 'Newlines 3'],
		["  \n  \n",  [md_el(:linebreak),md_el(:linebreak)],'Newlines 3'],
		["  \na  \n",  [md_el(:linebreak),'a',md_el(:linebreak)],'Newlines 3'],
		
		# Inline HTML
		["a < b", ['a < b'], '< can be on itself'],
		["<hr>",  [md_html('<hr />')], 'HR will be sanitized'],
		["<hr/>", [md_html('<hr />')], 'Closed tag is ok'],
		["<hr  />", [md_html('<hr />')], 'Closed tag is ok 2'],
		["<hr/>a", [md_html('<hr />'),'a'], 'Closed tag is ok 2'],
		["<em></em>a", [md_html('<em></em>'),'a'], 'Inline HTML 1'],
		["<em>e</em>a", [md_html('<em>e</em>'),'a'], 'Inline HTML 2'],
		["a<em>e</em>b", ['a',md_html('<em>e</em>'),'b'], 'Inline HTML 3'],
		["<em>e</em>a<em>f</em>", 
			[md_html('<em>e</em>'),'a',md_html('<em>f</em>')], 
			'Inline HTML 4'],
		["<em>e</em><em>f</em>a", 
			[md_html('<em>e</em>'),md_html('<em>f</em>'),'a'], 
			'Inline HTML 5'],
			
			["<img src='a' />", [md_html("<img src='a' />")], 'Attributes'],
			["<img src='a'/>"],
		
		# emphasis
		["**", :throw, 'Unclosed double **'],
		["\\*", ['*'], 'Escaping of *'],
		["a *b* ", ['a ', md_em('b')], 'Emphasis 1'],
		["a *b*", ['a ', md_em('b')], 'Emphasis 2'],
		["a * b", ['a * b'], 'Emphasis 3'],
		["a * b*", :throw, 'Unclosed emphasis'],
		# same with underscore
		["__", :throw, 'Unclosed double __'],
		["\\_", ['_'], 'Escaping of _'],
		["a _b_ ", ['a ', md_em('b')], 'Emphasis 4'],
		["a _b_", ['a ', md_em('b')], 'Emphasis 5'],
		["a _ b", ['a _ b'], 'Emphasis 6'],
		["a _ b_", :throw, 'Unclosed emphasis'],
		["_b_", [md_em('b')], 'Emphasis 7'],
		["_b_ _c_", [md_em('b'),' ',md_em('c')], 'Emphasis 8'],
		["_b__c_", [md_em('b'),md_em('c')], 'Emphasis 9'],
		# underscores in word
		["mod_ruby", ['mod_ruby'], 'Word with underscore'],
		# strong
		["**a*", :throw, 'Unclosed double ** 2'],
		["\\**a*", ['*', md_em('a')], 'Escaping of *'],
		["a **b** ", ['a ', md_strong('b')], 'Emphasis 1'],
		["a **b**", ['a ', md_strong('b')], 'Emphasis 2'],
		["a ** b", ['a ** b'], 'Emphasis 3'],
		["a ** b**", :throw, 'Unclosed emphasis'],
		["**b****c**", [md_strong('b'),md_strong('c')], 'Emphasis 9'],
		# strong (with underscore)
		["__a_", :throw, 'Unclosed double __ 2'],
	
	#	["\\__a_", ['_', md_em('a')], 'Escaping of _'],
		["a __b__ ", ['a ', md_strong('b')], 'Emphasis 1'],
		["a __b__", ['a ', md_strong('b')], 'Emphasis 2'],
		["a __ b", ['a __ b'], 'Emphasis 3'],
		["a __ b__", :throw, 'Unclosed emphasis'],
		["__b____c__", [md_strong('b'),md_strong('c')], 'Emphasis 9'],
		# extra strong
		["***a**", :throw, 'Unclosed triple *** '],
		["\\***a**", ['*', md_strong('a')], 'Escaping of *'],
		["a ***b*** ", ['a ', md_emstrong('b')], 'Strong elements'],
		["a ***b***", ['a ', md_emstrong('b')]],
		["a *** b", ['a *** b']],
		["a ** * b", ['a ** * b']],
		["***b******c***", [md_emstrong('b'),md_emstrong('c')]],
		["a *** b***", :throw, 'Unclosed emphasis'],
		# same with underscores
		["___a__", :throw, 'Unclosed triple *** '],
#		["\\___a__", ['_', md_strong('a')], 'Escaping of _'],
		["a ___b___ ", ['a ', md_emstrong('b')], 'Strong elements'],
		["a ___b___", ['a ', md_emstrong('b')]],
		["a ___ b", ['a ___ b']],
		["a __ _ b", ['a __ _ b']],
		["___b______c___", [md_emstrong('b'),md_emstrong('c')]],
		["a ___ b___", :throw, 'Unclosed emphasis'],
		# mixing is bad
		["*a_", :throw, 'Mixing is bad'],
		["_a*", :throw],
		["**a__", :throw],
		["__a**", :throw],
		["___a***", :throw],
		["***a___", :throw],
		# links of the form [text][ref]
		["\\[a]",  ["[a]"], 'Escaping 1'],
		["\\[a\\]", ["[a]"], 'Escaping 2'],
# This is valid in the new Markdown version
#		["[a]",   ["a"],   'Not a link'],
		["[a]",   [ md_link(["a"],'a')], 'Empty link'],
		["[a][]", ],
		["[a][]b",   [ md_link(["a"],'a'),'b'], 'Empty link'],
		["[a\\]][]", [ md_link(["a]"],'a')], 'Escape inside link (throw ?] away)'],
		
		["[a",  :throw,   'Link not closed'],
		["[a][",  :throw,   'Ref not closed'],
		
		# links of the form [text](url)
		["\\[a](b)",  ["[a](b)"], 'Links'],
		["[a](url)c",  [md_im_link(['a'],'url'),'c'], 'url'],
		["[a]( url )c" ],
		["[a] (	url )c" ],
		["[a] (	url)c" ],
		
		["[a](ur:/l/ 'Title')",  [md_im_link(['a'],'ur:/l/','Title')],
		 	'url and title'],
		["[a] (	ur:/l/ \"Title\")" ],
		["[a] (	ur:/l/ \"Title\")" ],
		["[a]( ur:/l/ Title)", :throw, "Must quote title" ],

		["[a](url 'Tit\\\"l\\\\e')", [md_im_link(['a'],'url','Tit"l\\e')],
		 	'url and title escaped'],
		["[a] (	url \"Tit\\\"l\\\\e\")" ],
		["[a] (	url	\"Tit\\\"l\\\\e\"  )" ],
		['[a] (	url	"Tit\\"l\\\\e"  )' ],
		["[a]()", [md_im_link(['a'],'')], 'No URL is OK'],
	
		["[a](\"Title\")", :throw, "No url specified" ],
		["[a](url \"Title)", :throw, "Unclosed quotes" ],
		["[a](url \"Title\\\")", :throw],
		["[a](url \"Title\" ", :throw],

		["[a](url \'Title\")", :throw, "Mixing is bad" ],
		["[a](url \"Title\')"],
		
		["[a](/url)", [md_im_link(['a'],'/url')], 'Funny chars in url'],
		["[a](#url)", [md_im_link(['a'],'#url')]],
		["[a](</script?foo=1&bar=2>)", [md_im_link(['a'],'/script?foo=1&bar=2')]],
		
		
		# Images
		["\\![a](url)",  ['!', md_im_link(['a'],'url') ], 'Escaping images'],
		
		["![a](url)",  [md_im_image(['a'],'url')], 'Image no title'],
		["![a]( url )" ],
		["![a] (	url )" ],
		["![a] (	url)" ],

		["![a](url 'ti\"tle')",  [md_im_image(['a'],'url','ti"tle')], 'Image with title'],
		['![a]( url "ti\\"tle")' ],

		["![a](url", :throw, 'Invalid images'],
		["![a( url )" ],
		["![a] ('url )" ],

		["![a][imref]",  [md_image(['a'],'imref')], 'Image with ref'],
		["![a][ imref]"],
		["![a][ imref ]"],
		["![a][\timref\t]"],
		

		['<http://example.com/?foo=1&bar=2>', 
			[md_url('http://example.com/?foo=1&bar=2')], 'Immediate link'],
			['a<http://example.com/?foo=1&bar=2>b', 
				['a',md_url('http://example.com/?foo=1&bar=2'),'b']  ],
		['<andrea@censi.org>', 
			[md_email('andrea@censi.org')], 'Email address'],
		['<mailto:andrea@censi.org>'],
		["Developmen <http://rubyforge.org/projects/maruku/>",
			 ["Developmen ", md_url("http://rubyforge.org/projects/maruku/")]],
		["a<!-- -->b", ['a',md_html('<!-- -->'),'b'], 
			'HTML Comment'],

		["a<!--", :throw, 'Bad HTML Comment'],
		["a<!-- ", :throw, 'Bad HTML Comment'],

		["<?xml <?!--!`3  ?>", [md_xml_instr('xml','<?!--!`3')], 'XML processing instruction'],
		["<? <?!--!`3  ?>", [md_xml_instr('','<?!--!`3')] ],

		["<? ", :throw, 'Bad Server directive'],

		["a <b", :throw, 'Bad HTML 1'],
		["<b",   :throw, 'Bad HTML 2'],
		["<b!",  :throw, 'Bad HTML 3'],
		['`<div>`, `<table>`, `<pre>`, `<p>`',
			[md_code('<div>'),', ',md_code('<table>'),', ',
				md_code('<pre>'),', ',md_code('<p>')],
				'Multiple HTLM tags'],
				
		["&andrea", ["&andrea"], 'Parsing of entities'],
# no escaping is allowed
#			["\\&andrea;", ["&andrea;"]],
		["l&andrea;", ["l", md_entity('andrea')] ],
		["&&andrea;", ["&", md_entity('andrea')] ],
		["&123;;&amp;",[md_entity('123'),';',md_entity('amp')]],
		
		["a\nThe [syntax page] [s] provides", 
			['a The ', md_link(['syntax page'],'s'), ' provides'], 'Regression'],
		
		['![a](url "ti"tle")', [md_im_image(['a'],'url','ti"tle')], 
			"Image with quotes"],
		['![a](url \'ti"tle\')' ],
		
		['[bar](/url/ "Title with "quotes" inside")', 
			[md_im_link(["bar"],'/url/', 'Title with "quotes" inside')],
			"Link with quotes"],

# We dropped this idea		
#		['$20,000 and $30,000', ['$20,000 and $30,000'], 'Math: spaces'],
		['$20,000$', [md_inline_math('20,000')]],
#		['$ 20,000$', ['$ 20,000$']],
#		['$20,000 $ $20,000$', ['$20,000 $ ', md_inline_math('20,000')]],
		["#{Maruku8}", [Maruku8], "Reading UTF-8"],
#		["#{AccIta1}", [AccIta8], "Converting ISO-8859-1 to UTF-8", 
#			{:encoding => 'iso-8859-1'}],
						
	]

		good_cases = unit_tests_for_attribute_lists + good_cases
		
		count = 1; last_comment=""; last_expected=:throw
		good_cases.each do |t|
			if not t[1]
				t[1] = last_expected
			else
				last_expected = t[1]
			end				
			if not t[2]
				t[2] = last_comment + " #{count+=1}"
			else
				last_comment = t[2]; count=1
			end
		end
		
		
			
		@verbose = verbose
		m = Maruku.new
		m.attributes[:on_error] = :raise
		Globals[:debug_keep_ials] = true
		
		num_ok = 0
		good_cases.each do |input, expected, comment|
				output = nil
				begin
					output = m.parse_span_better(input)
					#lines = Maruku.split_lines input
					#output = m.parse_lines_as_span(lines)
				rescue Exception => e
					if not expected == :throw
						ex = e.inspect+ "\n"+ e.backtrace.join("\n")
						s = comment+describe_difference(input, expected, output)
							
						print_status(comment,'CRASHED :-(', ex+s)
						raise e if @break_on_first_error 
					else
						quiet || print_status(comment,'OK')
						num_ok += 1
					end
				end
				
				if not expected == :throw
					if not (expected == output)
						s = comment+describe_difference(input, expected, output)
						print_status(comment, 'FAILED', s)
						break if break_on_first_error
					else
						num_ok += 1
						quiet || print_status(comment, 'OK')
					end
				else # I expected a raise
					if output
						s = comment+describe_difference(input, expected, output)
						
						print_status(comment, 'FAILED (no throw)', s)
						break if break_on_first_error
					end
				end		
		end  # do 
		if num_ok != good_cases.size
			return false
		else
			return true
		end
	end
	
	PAD=40
	def print_status(comment, status, verbose_text=nil)
		if comment.size < PAD
			comment = comment + (" "*(PAD-comment.size))
		end
		puts "- #{comment} #{status}"
		if @verbose and verbose_text
			puts verbose_text
		end
	end
	
	
	def describe_difference(input, expected, output)
		"\nInput:\n  #{input.inspect}" +
		    "\nExpected:\n  #{expected.inspect}" +
			"\nOutput:\n  #{output.inspect}\n"
	end
end end

class Maruku
	include MaRuKu::Tests
end

verbose = ARGV.include? 'v'
break_on_first = ARGV.include? 'b'
quiet = ARGV.include? 'q'
ok = Maruku.new.test_span_parser(verbose, break_on_first, quiet)

exit (ok ? 0 : 1)
