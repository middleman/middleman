Paragraphs eats everything, but not link definitions.
*** Parameters: ***
{}
*** Markdown input: ***
Paragraph
[google1]: #

Paragraph
 [google2]: #

Paragraph
  [google3]: #

*** Output of inspect ***
md_el(:document,[
	md_par(["Paragraph"]),
	md_ref_def("google1", "#", {:title=>nil}),
	md_par(["Paragraph"]),
	md_ref_def("google2", "#", {:title=>nil}),
	md_par(["Paragraph"]),
	md_ref_def("google3", "#", {:title=>nil})
],{},[])
*** Output of to_html ***
<p>Paragraph</p>

<p>Paragraph</p>

<p>Paragraph</p>
*** Output of to_latex ***
Paragraph

Paragraph

Paragraph
*** Output of to_md ***
Paragraph

Paragraph

Paragraph
*** Output of to_s ***
ParagraphParagraphParagraph
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)