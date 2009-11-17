Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***

h         | h
----------|--
{:t}  c1  | c2
{: summary="Table summary" .class1 style="color:red" border=3 width="50%" frame=lhs rules=cols  cellspacing=2em cellpadding=4px}

{:t: scope="row"}
*** Output of inspect ***
md_el(:document,[
	md_el(:table,[
		md_el(:head_cell,["h"],{},[]),
		md_el(:head_cell,["h"],{},[]),
		md_el(:cell,[" c1"],{},[[:ref, "t"]]),
		md_el(:cell,["c2"],{},[])
	],{:align=>[:left, :left]},[["summary", "Table summary"], [:class, "class1"], ["style", "color:red"], ["border", "3"], ["width", "50%"], ["frame", "lhs"], ["rules", "cols"], ["cellspacing", "2em"], ["cellpadding", "4px"]]),
	md_el(:ald,[],{:ald=>[["scope", "row"]],:ald_id=>"t"},[])
],{},[])
*** Output of to_html ***
<table cellspacing='2em' class='class1' border='3' rules='cols' frame='lhs' summary='Table summary' cellpadding='4px' width='50%' style='color:red'><thead><tr><th>h</th><th>h</th></tr></thead><tbody><tr><th scope='row' style='text-align: left;'> c1</th><td style='text-align: left;'>c2</td>
</tr></tbody></table>
*** Output of to_latex ***
\begin{tabular}{l|l}
h&h\\
\hline 
 c1&c2\\
\end{tabular}
*** Output of to_md ***
hh c1c2
*** Output of to_s ***
hh c1c2
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)