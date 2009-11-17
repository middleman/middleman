Write a comment here
*** Parameters: ***
require 'maruku/ext/div'; {} # params 
*** Markdown input: ***
+---------
| text
+----------

+---------
|text

+--
 text
 
=--


 +---------
 | text
 +----------

 +---------
 |text

 +--
 text

 =--


  +---------
  | text
  +----------

  +---------
  |text

  +--
  text

  =--

   +---------
   | text
   +----------

   +---------
   |text

   +--
   text

   =--

*** Output of inspect ***
md_el(:document,[
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[]),
	md_el(:div,[md_par(["text"])],{:label=>nil,:num=>nil,:type=>nil},[])
],{},[])
*** Output of to_html ***
<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>

<div>
<p>text</p>
</div>
*** Output of to_latex ***
text

text

text

text

text

text

text

text

text

text

text

text
*** Output of to_md ***
text

text

text

text

text

text

text

text

text

text

text

text
*** Output of to_s ***
texttexttexttexttexttexttexttexttexttexttexttext
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)