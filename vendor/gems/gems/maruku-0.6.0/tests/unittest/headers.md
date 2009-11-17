Write a comment abouth the test here.
*** Parameters: ***
{:title=>"A title with emphasis"}
*** Markdown input: ***
A title with *emphasis*
=======================

A title with *emphasis*
-----------------------


#### A title with *emphasis* ####



*** Output of inspect ***
md_el(:document,[
	md_el(:header,["A title with ", md_em(["emphasis"])],{:level=>1},[]),
	md_el(:header,["A title with ", md_em(["emphasis"])],{:level=>2},[]),
	md_el(:header,["A title with ", md_em(["emphasis"])],{:level=>4},[])
],{},[])
*** Output of to_html ***
<h1 id='a_title_with_emphasis'>A title with <em>emphasis</em></h1>

<h2 id='a_title_with_emphasis'>A title with <em>emphasis</em></h2>

<h4 id='a_title_with_emphasis'>A title with <em>emphasis</em></h4>
*** Output of to_latex ***
\hypertarget{a_title_with_emphasis}{}\section*{{A title with \emph{emphasis}}}\label{a_title_with_emphasis}

\hypertarget{a_title_with_emphasis}{}\subsection*{{A title with \emph{emphasis}}}\label{a_title_with_emphasis}

\hypertarget{a_title_with_emphasis}{}\paragraph*{{A title with \emph{emphasis}}}\label{a_title_with_emphasis}
*** Output of to_md ***
A title with emphasisA title with emphasisA title with emphasis
*** Output of to_s ***
A title with emphasisA title with emphasisA title with emphasis
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)