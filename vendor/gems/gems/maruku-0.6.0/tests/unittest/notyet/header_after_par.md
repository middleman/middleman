Write a comment abouth the test here.
*** Parameters: ***
{:title=>"header"}
*** Markdown input: ***
Paragraph
### header ###

Paragraph
header
------

Paragraph
header
======

*** Output of inspect ***
md_el(:document,[
	md_par(["Paragraph"]),
	md_el(:header,["header"],{:level=>3},[]),
	md_par(["Paragraph"]),
	md_el(:header,["header"],{:level=>2},[]),
	md_par(["Paragraph"]),
	md_el(:header,["header"],{:level=>1},[])
],{},[])
*** Output of to_html ***
<p>Paragraph</p>

<h3 id='header'>header</h3>

<p>Paragraph</p>

<h2 id='header'>header</h2>

<p>Paragraph</p>

<h1 id='header'>header</h1>
*** Output of to_latex ***
Paragraph

\hypertarget{header}{}\subsubsection*{{header}}\label{header}

Paragraph

\hypertarget{header}{}\subsection*{{header}}\label{header}

Paragraph

\hypertarget{header}{}\section*{{header}}\label{header}
*** Output of to_md ***
Paragraph

headerParagraph

headerParagraph

header
*** Output of to_s ***
ParagraphheaderParagraphheaderParagraphheader
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)