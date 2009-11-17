
*** Parameters: ***
{}
*** Markdown input: ***

Paragraph
{:a}


{:a: b}
{:b: a}

*** Output of inspect ***
md_el(:document,[
	md_par(["Paragraph"], [[:ref, "a"]]),
	md_el(:ald,[],{:ald=>[[:ref, "b"]],:ald_id=>"a"},[]),
	md_el(:ald,[],{:ald=>[[:ref, "a"]],:ald_id=>"b"},[])
],{},[])
*** Output of to_html ***
<p>Paragraph</p>
*** Output of to_latex ***
Paragraph
*** Output of to_md ***
Paragraph
*** Output of to_s ***
Paragraph
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)