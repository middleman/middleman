Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
|    | 1  | 2  |
|----|----|----|
|  A | X  |    |
|  B |    | X  |
*** Output of inspect ***
md_el(:document,[
	md_el(:table,[
		md_el(:head_cell,[],{},[]),
		md_el(:head_cell,["1"],{},[]),
		md_el(:head_cell,["2"],{},[]),
		md_el(:cell,["A"],{},[]),
		md_el(:cell,["X"],{},[]),
		md_el(:cell,[],{},[]),
		md_el(:cell,["B"],{},[]),
		md_el(:cell,[],{},[]),
		md_el(:cell,["X"],{},[])
	],{:align=>[:left, :left, :left]},[])
],{},[])
*** Output of to_html ***
<table><thead><tr><th /><th>1</th><th>2</th></tr></thead><tbody><tr><td style='text-align: left;'>A</td><td style='text-align: left;'>X</td><td style='text-align: left;' />
</tr><tr><td style='text-align: left;'>B</td><td style='text-align: left;' /><td style='text-align: left;'>X</td>
</tr></tbody></table>
*** Output of to_latex ***
\begin{tabular}{l|l|l}
&1&2\\
\hline 
A&X&\\
B&&X\\
\end{tabular}
*** Output of to_md ***
12AXBX
*** Output of to_s ***
12AXBX
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)