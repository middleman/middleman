
*** Parameters: ***
{}
*** Markdown input: ***
<div markdown="1">Test **bold**</div>
<p markdown="1">Test **bold**</p>
*** Output of inspect ***
md_el(:document,[
	md_html("<div markdown=\"1\">Test **bold**</div>"),
	md_html("<p markdown=\"1\">Test **bold**</p>")
],{},[])
*** Output of to_html ***
<div>
<p>Test <strong>bold</strong></p>
</div><p>Test <strong>bold</strong></p>
*** Output of to_latex ***

*** Output of to_md ***

*** Output of to_s ***

*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)