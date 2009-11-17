Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
Paragraph 1

Paragraph 2


Paragraph 3
Paragraph 4
Paragraph Br->  
Paragraph 5


*** Output of inspect ***
md_el(:document,[
	md_par(["Paragraph 1"]),
	md_par(["Paragraph 2"]),
	md_par([
		"Paragraph 3 Paragraph 4 Paragraph Br->",
		md_el(:linebreak,[],{},[]),
		"Paragraph 5"
	])
],{},[])
*** Output of to_html ***
<p>Paragraph 1</p>

<p>Paragraph 2</p>

<p>Paragraph 3 Paragraph 4 Paragraph Br-&gt;<br />Paragraph 5</p>
*** Output of to_latex ***
Paragraph 1

Paragraph 2

Paragraph 3 Paragraph 4 Paragraph Br-{\tt \char62}\newline Paragraph 5
*** Output of to_md ***
Paragraph 1

Paragraph 2

Paragraph 3 Paragraph 4 Paragraph Br->  
Paragraph 5
*** Output of to_s ***
Paragraph 1Paragraph 2Paragraph 3 Paragraph 4 Paragraph Br->Paragraph 5
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)