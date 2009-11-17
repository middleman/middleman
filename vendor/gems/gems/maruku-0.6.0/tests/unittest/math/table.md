Write a comment here
*** Parameters: ***
require 'maruku/ext/math';{:html_math_engine => 'itex2mml' }
*** Markdown input: ***
<table markdown='1'>
	$\alpha$
	<thead>
		<td>$\beta$</td>
	</thead>
</table>
*** Output of inspect ***
md_el(:document,[
	md_html("<table markdown='1'>\n\t$\\alpha$\n\t<thead>\n\t\t<td>$\\beta$</td>\n\t</thead>\n</table>")
],{},[])
*** Output of to_html ***
<table><math class='maruku-mathml' display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&alpha;</mi></math><thead>
		<td><math class='maruku-mathml' display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&beta;</mi></math></td>
	</thead>
</table>
*** Output of to_latex ***

*** Output of to_md ***

*** Output of to_s ***

*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)