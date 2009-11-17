Write a comment abouth the test here.
*** Parameters: ***
{:css=>"style.css"}
*** Markdown input: ***
CSS: style.css

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

*** Output of inspect ***
md_el(:document,[
	md_el(:table,[
		md_el(:head_cell,["First Header"],{},[]),
		md_el(:head_cell,["Second Header"],{},[]),
		md_el(:cell,["Content Cell"],{},[]),
		md_el(:cell,["Content Cell"],{},[]),
		md_el(:cell,["Content Cell"],{},[]),
		md_el(:cell,["Content Cell"],{},[])
	],{:align=>[:left, :left]},[])
],{},[])
*** Output of to_html ***
<table><thead><tr><th>First Header</th><th>Second Header</th></tr></thead><tbody><tr><td style='text-align: left;'>Content Cell</td><td style='text-align: left;'>Content Cell</td>
</tr><tr><td style='text-align: left;'>Content Cell</td><td style='text-align: left;'>Content Cell</td>
</tr></tbody></table>
*** Output of to_latex ***
\begin{tabular}{l|l}
First Header&Second Header\\
\hline 
Content Cell&Content Cell\\
Content Cell&Content Cell\\
\end{tabular}
*** Output of to_md ***
First HeaderSecond HeaderContent CellContent CellContent CellContent Cell
*** Output of to_s ***
First HeaderSecond HeaderContent CellContent CellContent CellContent Cell
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)