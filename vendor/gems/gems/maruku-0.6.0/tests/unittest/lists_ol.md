Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
1.   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
 2.   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.
3.   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
 3.  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
 4.  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
 Suspendisse id sem consectetuer libero luctus adipiscing.

Ancora

1.  This is a list item with two paragraphs. Lorem ipsum dolor
    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
    mi posuere lectus.

    ATTENZIONE!

    - Uno
    - Due
      1. tre
      1. tre
      1. tre
    - Due

2.  Suspendisse id sem consectetuer libero luctus adipiscing.


Ancora

*   This is a list item with two paragraphs.

    This is the second paragraph in the list item. You're
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.

*   Another item in the same list.
*** Output of inspect ***
md_el(:document,[
	md_el(:ol,[
		md_el(:li_span,[
			"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],{:want_my_paragraph=>false},[])
	],{},[]),
	md_par(["Ancora"]),
	md_el(:ol,[
		md_el(:li,[
			md_par([
				"This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus."
			]),
			md_par(["ATTENZIONE!"]),
			md_el(:ul,[
				md_el(:li,[md_par(["Uno"])],{:want_my_paragraph=>false},[]),
				md_el(:li,[
					md_par(["Due"]),
					md_el(:ol,[
						md_el(:li_span,["tre"],{:want_my_paragraph=>false},[]),
						md_el(:li_span,["tre"],{:want_my_paragraph=>false},[]),
						md_el(:li_span,["tre"],{:want_my_paragraph=>false},[])
					],{},[])
				],{:want_my_paragraph=>true},[]),
				md_el(:li,[md_par(["Due"])],{:want_my_paragraph=>false},[])
			],{},[])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[
			md_par(["Suspendisse id sem consectetuer libero luctus adipiscing."])
		],{:want_my_paragraph=>false},[])
	],{},[]),
	md_par(["Ancora"]),
	md_el(:ul,[
		md_el(:li,[
			md_par(["This is a list item with two paragraphs."]),
			md_par([
				"This is the second paragraph in the list item. You",
				md_entity("rsquo"),
				"re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
			])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[md_par(["Another item in the same list."])],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<ol>
<li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>
</ol>

<p>Ancora</p>

<ol>
<li>
<p>This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.</p>

<p>ATTENZIONE!</p>

<ul>
<li>
<p>Uno</p>
</li>

<li>
<p>Due</p>

<ol>
<li>tre</li>

<li>tre</li>

<li>tre</li>
</ol>
</li>

<li>
<p>Due</p>
</li>
</ul>
</li>

<li>
<p>Suspendisse id sem consectetuer libero luctus adipiscing.</p>
</li>
</ol>

<p>Ancora</p>

<ul>
<li>
<p>This is a list item with two paragraphs.</p>

<p>This is the second paragraph in the list item. You&#8217;re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</p>
</li>

<li>
<p>Another item in the same list.</p>
</li>
</ul>
*** Output of to_latex ***
\begin{enumerate}%
\item Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.

\end{enumerate}
Ancora

\begin{enumerate}%
\item This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.

ATTENZIONE!

\begin{itemize}%
\item Uno


\item Due

\begin{enumerate}%
\item tre
\item tre
\item tre

\end{enumerate}

\item Due



\end{itemize}

\item Suspendisse id sem consectetuer libero luctus adipiscing.



\end{enumerate}
Ancora

\begin{itemize}%
\item This is a list item with two paragraphs.

This is the second paragraph in the list item. You'{}re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.


\item Another item in the same list.



\end{itemize}
*** Output of to_md ***
1.  Lorem ipsum dolor sit amet,
    consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere
    lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet
    vitae, risus.
2.  Donec sit amet nisl. Aliquam semper
    ipsum sit amet velit. Suspendisse
    id sem consectetuer libero luctus
    adipiscing.
3.  Donec sit amet nisl. Aliquam semper
    ipsum sit amet velit. Suspendisse
    id sem consectetuer libero luctus
    adipiscing.
4.  Donec sit amet nisl. Aliquam semper
    ipsum sit amet velit. Suspendisse
    id sem consectetuer libero luctus
    adipiscing.
5.  Donec sit amet nisl. Aliquam semper
    ipsum sit amet velit. Suspendisse
    id sem consectetuer libero luctus
    adipiscing.

Ancora

1.  
    This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
    ATTENZIONE!
    Uno
    
    Due
    
    1.  tre
    2.  tre
    3.  tre
    
    Due
2.  
    Suspendisse id sem consectetuer libero luctus adipiscing.

Ancora

-This is a list item with two paragraphs.
This is the second paragraph in the list item. Youre only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
-nother item in the same list.
*** Output of to_s ***
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.AncoraThis is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.ATTENZIONE!UnoDuetretretreDueSuspendisse id sem consectetuer libero luctus adipiscing.AncoraThis is a list item with two paragraphs.This is the second paragraph in the list item. Youre only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.Another item in the same list.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)