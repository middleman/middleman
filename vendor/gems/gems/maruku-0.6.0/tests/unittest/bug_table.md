Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***


hello
{: summary="Table summary" .class1 style="color:red"}

h         | h
----------|--
{:t}  c1  | c2
{: summary="Table summary" .class1 style="color:red"}



{:t: scope="row"}
*** Output of inspect ***
md_el(:document,[
	md_par(["hello"], [["summary", "Table summary"], [:class, "class1"], ["style", "color:red"]]),
	md_el(:table,[
		md_el(:head_cell,["h"],{},[]),
		md_el(:head_cell,["h"],{},[]),
		md_el(:cell,[" c1"],{},[[:ref, "t"]]),
		md_el(:cell,["c2"],{},[])
	],{:align=>[:left, :left]},[["summary", "Table summary"], [:class, "class1"], ["style", "color:red"]]),
	md_el(:ald,[],{:ald=>[["scope", "row"]],:ald_id=>"t"},[])
],{},[])
*** Output of to_html ***
<p class='class1' style='color:red'>hello</p>
<table class='class1' summary='Table summary' style='color:red'><thead><tr><th>h</th><th>h</th></tr></thead><tbody><tr><th scope='row' style='text-align: left;'> c1</th><td style='text-align: left;'>c2</td>
</tr></tbody></table>
*** Output of to_latex ***
hello

\begin{tabular}{l|l}
h&h\\
\hline 
 c1&c2\\
\end{tabular}
*** Output of to_md ***
hello

hh c1c2
*** Output of to_s ***
hellohh c1c2
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)