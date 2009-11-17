IALs can refer to element before or after.
*** Parameters: ***
{}
*** Markdown input: ***
Paragraph1
{:#par1}

{:#par2}
Paragraph2
*** Output of inspect ***
md_el(:document,[
	md_par(["Paragraph1"], [[:id, "par1"]]),
	md_par(["Paragraph2"], [[:id, "par2"]])
],{},[])
*** Output of to_html ***
<p id='par1'>Paragraph1</p>

<p id='par2'>Paragraph2</p>
*** Output of to_latex ***
Paragraph1

Paragraph2
*** Output of to_md ***
Paragraph1

Paragraph2
*** Output of to_s ***
Paragraph1Paragraph2
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)