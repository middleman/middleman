Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
 *  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
 *  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
 Suspendisse id sem consectetuer libero luctus adipiscing.

Ancora

*   This is a list item with two paragraphs. Lorem ipsum dolor
    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
    mi posuere lectus.

    ATTENZIONE!

*  Suspendisse id sem consectetuer libero luctus adipiscing.


Ancora

*   This is a list item with two paragraphs.

    This is the second paragraph in the list item. You're
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.

*   Another item in the same list.
*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[
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
	md_el(:ul,[
		md_el(:li,[
			md_par([
				"This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus."
			]),
			md_par(["ATTENZIONE!"])
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
<ul>
<li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>
</ul>

<p>Ancora</p>

<ul>
<li>
<p>This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.</p>

<p>ATTENZIONE!</p>
</li>

<li>
<p>Suspendisse id sem consectetuer libero luctus adipiscing.</p>
</li>
</ul>

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
\begin{itemize}%
\item Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.

\end{itemize}
Ancora

\begin{itemize}%
\item This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.

ATTENZIONE!


\item Suspendisse id sem consectetuer libero luctus adipiscing.



\end{itemize}
Ancora

\begin{itemize}%
\item This is a list item with two paragraphs.

This is the second paragraph in the list item. You'{}re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.


\item Another item in the same list.



\end{itemize}
*** Output of to_md ***
-orem ipsum dolor sit amet,
consectetuer adipiscing elit.
Aliquam hendrerit mi posuere
lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet
vitae, risus.
-onec sit amet nisl. Aliquam semper
ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus
adipiscing.
-onec sit amet nisl. Aliquam semper
ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus
adipiscing.
-onec sit amet nisl. Aliquam semper
ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus
adipiscing.
-onec sit amet nisl. Aliquam semper
ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus
adipiscing.

Ancora

-This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
ATTENZIONE!
-Suspendisse id sem consectetuer libero luctus adipiscing.

Ancora

-This is a list item with two paragraphs.
This is the second paragraph in the list item. Youre only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
-nother item in the same list.
*** Output of to_s ***
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.AncoraThis is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.ATTENZIONE!Suspendisse id sem consectetuer libero luctus adipiscing.AncoraThis is a list item with two paragraphs.This is the second paragraph in the list item. Youre only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.Another item in the same list.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)