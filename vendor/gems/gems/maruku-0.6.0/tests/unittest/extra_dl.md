Write a comment abouth the test here.
*** Parameters: ***
{:css=>"style.css"}
*** Markdown input: ***
CSS: style.css


Apple
:   Pomaceous fruit of plants of the genus Malus in 
    the family Rosaceae.

Orange
:   The fruit of an evergreen tree of the genus Citrus.

*** Output of inspect ***
md_el(:document,[
	md_el(:definition_list,[
		md_el(:definition,[
			md_el(:definition_term,["Apple"],{},[]),
			md_el(:definition_data,[
				"Pomaceous fruit of plants of the genus Malus in the family Rosaceae."
			],{},[])
		],{:definitions=>[md_el(:definition_data,[
			"Pomaceous fruit of plants of the genus Malus in the family Rosaceae."
		],{},[])],:terms=>[md_el(:definition_term,["Apple"],{},[])],:want_my_paragraph=>false},[]),
		md_el(:definition,[
			md_el(:definition_term,["Orange"],{},[]),
			md_el(:definition_data,["The fruit of an evergreen tree of the genus Citrus."],{},[])
		],{:definitions=>[md_el(:definition_data,["The fruit of an evergreen tree of the genus Citrus."],{},[])],:terms=>[md_el(:definition_term,["Orange"],{},[])],:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<dl>
<dt>Apple</dt>

<dd>Pomaceous fruit of plants of the genus Malus in the family Rosaceae.</dd>

<dt>Orange</dt>

<dd>The fruit of an evergreen tree of the genus Citrus.</dd>
</dl>
*** Output of to_latex ***
\begin{description}

\item[Apple] Pomaceous fruit of plants of the genus Malus in the family Rosaceae. 

\item[Orange] The fruit of an evergreen tree of the genus Citrus. 
\end{description}
*** Output of to_md ***
ApplePomaceous fruit of plants of the genus Malus in the family Rosaceae.OrangeThe fruit of an evergreen tree of the genus Citrus.
*** Output of to_s ***
ApplePomaceous fruit of plants of the genus Malus in the family Rosaceae.OrangeThe fruit of an evergreen tree of the genus Citrus.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)