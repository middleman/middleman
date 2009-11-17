Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***


What do you see here? `\\` it should be two backslashes.


*** Output of inspect ***
md_el(:document,[
	md_par([
		"What do you see here? ",
		md_code("\\\\"),
		" it should be two backslashes."
	])
],{},[])
*** Output of to_html ***
<p>What do you see here? <code>\\</code> it should be two backslashes.</p>
*** Output of to_latex ***
What do you see here? {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char92\char92}} it should be two backslashes.
*** Output of to_md ***
What do you see here? it should be two
backslashes.
*** Output of to_s ***
What do you see here?  it should be two backslashes.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)