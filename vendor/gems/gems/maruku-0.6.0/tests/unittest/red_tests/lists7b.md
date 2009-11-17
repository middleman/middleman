Test case given by Scott.

http://rubyforge.org/tracker/index.php?func=detail&aid=8862&group_id=2795&atid=10735

a should not be indented.

*** Parameters: ***
{} # params 
*** Markdown input: ***
* a
  * a1
  * a2
* b


*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[
		md_el(:li,[
			"a",
			md_el(:ul,[
				md_el(:li_span,["a1"],{:want_my_paragraph=>false},[]),
				md_el(:li_span,["a2"],{:want_my_paragraph=>false},[])
			],{},[])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[md_par(["b"])],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<ul>
<li>
a

<ul>
<li>a1</li>

<li>a2</li>
</ul>
</li>

<li>
<p>b</p>
</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item a

\begin{itemize}%
\item a1
\item a2

\end{itemize}

\item b



\end{itemize}
*** Output of to_md ***
-* a1
* a2
-
*** Output of to_s ***
aa1a2b
*** EOF ***




Failed tests:   [:inspect, :to_html] 

*** Output of inspect ***
-----| WARNING | -----
md_el(:document,[
	md_el(:ul,[
		md_el(:li,[
			md_par(["a"]),
			md_el(:ul,[
				md_el(:li_span,["a1"],{:want_my_paragraph=>false},[]),
				md_el(:li_span,["a2"],{:want_my_paragraph=>false},[])
			],{},[])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[md_par(["b"])],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
-----| WARNING | -----
<ul>
<li>
<p>a</p>

<ul>
<li>a1</li>

<li>a2</li>
</ul>
</li>

<li>
<p>b</p>
</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item a

\begin{itemize}%
\item a1
\item a2

\end{itemize}

\item b



\end{itemize}
*** Output of to_md ***
-* a1
* a2
-
*** Output of to_s ***
aa1a2b
*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)