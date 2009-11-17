Write a comment here
*** Parameters: ***
{}
*** Markdown input: ***

  Symbol    | Meaning | comments
------------|---------|---------
{:r} &alpha; | The first | I like it.
{:r} &aleph; | The first | I like it.


{:r: scope='row'}
*** Output of inspect ***
md_el(:document,[
	md_el(:table,[
		md_el(:head_cell,["Symbol"],{},[]),
		md_el(:head_cell,["Meaning"],{},[]),
		md_el(:head_cell,["comments"],{},[]),
		md_el(:cell,[" ", md_entity("alpha")],{},[[:ref, "r"]]),
		md_el(:cell,["The first"],{},[]),
		md_el(:cell,["I like it."],{},[]),
		md_el(:cell,[" ", md_entity("aleph")],{},[[:ref, "r"]]),
		md_el(:cell,["The first"],{},[]),
		md_el(:cell,["I like it."],{},[])
	],{:align=>[:left, :left, :left]},[]),
	md_el(:ald,[],{:ald=>[["scope", "row"]],:ald_id=>"r"},[])
],{},[])
*** Output of to_html ***
<table><thead><tr><th>Symbol</th><th>Meaning</th><th>comments</th></tr></thead><tbody><tr><th scope='row' style='text-align: left;'> &#945;</th><td style='text-align: left;'>The first</td><td style='text-align: left;'>I like it.</td>
</tr><tr><th scope='row' style='text-align: left;'> &aleph;</th><td style='text-align: left;'>The first</td><td style='text-align: left;'>I like it.</td>
</tr></tbody></table>
*** Output of to_latex ***
\begin{tabular}{l|l|l}
Symbol&Meaning&comments\\
\hline 
 $\alpha${}&The first&I like it.\\
 &The first&I like it.\\
\end{tabular}
*** Output of to_md ***
SymbolMeaningcomments The firstI like it. The firstI like it.
*** Output of to_s ***
SymbolMeaningcomments The firstI like it. The firstI like it.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)