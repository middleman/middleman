Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
Examples of numeric character references include &#169; or &#xA9; for the copyright symbol, &#913; or &#x391; for the Greek capital letter alpha, and &#1575; or &#x627; for the Arabic letter alef.


*** Output of inspect ***
md_el(:document,[
	md_par([
		"Examples of numeric character references include ",
		md_entity(169),
		" or ",
		md_entity(169),
		" for the copyright symbol, ",
		md_entity(913),
		" or ",
		md_entity(913),
		" for the Greek capital letter alpha, and ",
		md_entity(1575),
		" or ",
		md_entity(1575),
		" for the Arabic letter alef."
	])
],{},[])
*** Output of to_html ***
<p>Examples of numeric character references include &#169; or &#169; for the copyright symbol, &#913; or &#913; for the Greek capital letter alpha, and &#1575; or &#1575; for the Arabic letter alef.</p>
*** Output of to_latex ***
Examples of numeric character references include \copyright{} or \copyright{} for the copyright symbol, $A${} or $A${} for the Greek capital letter alpha, and  or  for the Arabic letter alef.
*** Output of to_md ***
Examples of numeric character
references include or for the copyright
symbol, or for the Greek capital letter
alpha, and or for the Arabic letter
alef.
*** Output of to_s ***
Examples of numeric character references include  or  for the copyright symbol,  or  for the Greek capital letter alpha, and  or  for the Arabic letter alef.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)