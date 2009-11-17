#--
#   Copyright (C) 2006  Andrea Censi  <andrea (at) rubyforge.org>
#
# This file is part of Maruku.
# 
#   Maruku is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
# 
#   Maruku is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with Maruku; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#++


require 'rexml/document'

module MaRuKu; module Out; module Latex
	
	include REXML
	
	def to_latex_entity 
		MaRuKu::Out::Latex.need_entity_table
		
		entity_name = self.entity_name
	
		entity = ENTITY_TABLE[entity_name]
		if not entity
			maruku_error "I don't know how to translate entity '#{entity_name}' "+
			"to LaTeX."
			return ""
		end
		replace = entity.latex_string
		
		entity.latex_packages.each do |p|
			@doc.latex_require_package p
		end
		
#		if replace =~ /^\\/
#			replace = replace + " "
#		end
		
 		if replace
			return replace + "{}"
		else
			tell_user "Cannot translate entity #{entity_name.inspect} to LaTeX."
			return entity_name
		end
	end
	
	class LatexEntity
		safe_attr_accessor :html_num, Fixnum
		safe_attr_accessor :html_entity, String
		safe_attr_accessor :latex_string, String
		safe_attr_accessor :latex_packages, Array
	end
	
	def Latex.need_entity_table
		Latex.init_entity_table if ENTITY_TABLE.empty?
	end
	
	# create hash @@entity_to_latex
	def Latex.init_entity_table
#		$stderr.write "Creating entity table.."
#		$stderr.flush
		doc = Document.new XML_TABLE
		doc.elements.each("//char") do |c| 
			num =  c.attributes['num'].to_i
			name =  c.attributes['name']
			package =  c.attributes['package']
			
			convert =  c.attributes['convertTo']
			convert.gsub!(/@DOUBLEQUOT/,'"')
			convert.gsub!(/@QUOT/,"'")
			convert.gsub!(/@GT/,">")
			convert.gsub!(/@LT/,"<")
			convert.gsub!(/@AMP/,"&")
			convert.freeze
			
			e = LatexEntity.new
			e.html_num = num
			e.html_entity = name
			e.latex_string = convert
			e.latex_packages = package ? package.split : []
			
			ENTITY_TABLE[num] = e
			ENTITY_TABLE[name] = e
		end
#		$stderr.puts "..done."
	end
	
	ENTITY_TABLE = {}

# The following is a conversion chart for html elements, courtesy of 
# text2html 

	XML_TABLE ="
	<chars>
	  <char num='913' name='Alpha' convertTo='$A$' />
	  <char num='914' name='Beta' convertTo='$B$' />
	  <char num='915' name='Gamma' convertTo='$\\Gamma$' />
	  <char num='916' name='Delta' convertTo='$\\Delta$' />
	  <char num='917' name='Epsilon' convertTo='$E$' />
	  <char num='918' name='Zeta' convertTo='$Z$' />
	  <char num='919' name='Eta' convertTo='$H$' />
	  <char num='920' name='Theta' convertTo='$\\Theta$' />
	  <char num='921' name='Iota' convertTo='$I$' />
	  <char num='922' name='Kappa' convertTo='$K$' />
	  <char num='923' name='Lambda' convertTo='$\\Lambda$' />
	  <char num='924' name='Mu' convertTo='$M$' />
	  <char num='925' name='Nu' convertTo='$N$' />
	  <char num='926' name='Xi' convertTo='$\\Xi$' />
	  <char num='927' name='Omicron' convertTo='$O$' />
	  <char num='928' name='Pi' convertTo='$\\Pi$' />
	  <char num='929' name='Rho' convertTo='$P$' />
	  <char num='931' name='Sigma' convertTo='$\\Sigma$' />
	  <char num='932' name='Tau' convertTo='$T$' />
	  <char num='933' name='Upsilon' convertTo='$Y$' />
	  <char num='934' name='Phi' convertTo='$\\Phi$' />
	  <char num='935' name='Chi' convertTo='$X$' />
	  <char num='936' name='Psi' convertTo='$\\Psi$' />
	  <char num='937' name='Omega' convertTo='$\\Omega$' />
	  <char num='945' name='alpha' convertTo='$\\alpha$' />
	  <char num='946' name='beta' convertTo='$\\beta$' />
	  <char num='947' name='gamma' convertTo='$\\gamma$' />
	  <char num='948' name='delta' convertTo='$\\delta$' />
	  <char num='949' name='epsilon' convertTo='$\\epsilon$' />
	  <char num='950' name='zeta' convertTo='$\\zeta$' />
	  <char num='951' name='eta' convertTo='$\\eta$' />
	  <char num='952' name='theta' convertTo='$\\theta$' />
	  <char num='953' name='iota' convertTo='$\\iota$' />
	  <char num='954' name='kappa' convertTo='$\\kappa$' />
	  <char num='955' name='lambda' convertTo='$\\lambda$' />
	  <char num='956' name='mu' convertTo='$\\mu$' />

	  <char num='957' name='nu' convertTo='$\\nu$' />
	  <char num='958' name='xi' convertTo='$\\xi$' />
	  <char num='959' name='omicron' convertTo='$o$' />
	  <char num='960' name='pi' convertTo='$\\pi$' />
	  <char num='961' name='rho' convertTo='$\\rho$' />
	  <char num='963' name='sigma' convertTo='$\\sigma$' />
	  <char num='964' name='tau' convertTo='$\\tau$' />
	  <char num='965' name='upsilon' convertTo='$\\upsilon$' />
	  <char num='966' name='phi' convertTo='$\\phi$' />

	  <char num='967' name='chi' convertTo='$\\chi$' />
	  <char num='968' name='psi' convertTo='$\\psi$' />
	  <char num='969' name='omega' convertTo='$\\omega$' />
	  <char num='962' name='sigmaf' convertTo='$\\varsigma$' />
	  <char num='977' name='thetasym' convertTo='$\\vartheta$' />
	  <char num='982' name='piv' convertTo='$\\varpi$' />
	  <char num='8230' name='hellip' convertTo='\\ldots' />
	  <char num='8242' name='prime' convertTo='$\\prime$' />
	  <char num='8254' name='oline' convertTo='-' />

	  <char num='8260' name='frasl' convertTo='/' />
	  <char num='8472' name='weierp' convertTo='$\\wp$' />
	  <char num='8465' name='image' convertTo='$\\Im$' />
	  <char num='8476' name='real' convertTo='$\\Re$' />
	  <char num='8501' name='alefsym' convertTo='$\\aleph$' />
	  <char num='8226' name='bull' convertTo='$\\bullet$' />
	  <char num='8482' name='trade' convertTo='$^{\\rm TM}$' /> <!-- \texttrademark -->
	  <char num='8592' name='larr' convertTo='$\\leftarrow$' />

	  <char num='8594' name='rarr' convertTo='$\\rightarrow$' />
	  <char num='8593' name='uarr' convertTo='$\\uparrow$' />
	  <char num='8595' name='darr' convertTo='$\\downarrow$' />
	  <char num='8596' name='harr' convertTo='$\\leftrightarrow$' />
	  <char num='8629' name='crarr' convertTo='$\\hookleftarrow$' />
	  <char num='8657' name='uArr' convertTo='$\\Uparrow$' />
	  <char num='8659' name='dArr' convertTo='$\\Downarrow$' />
	  <char num='8656' name='lArr' convertTo='$\\Leftarrow$' />
	  <char num='8658' name='rArr' convertTo='$\\Rightarrow$' />

	  <char num='8660' name='hArr' convertTo='$\\Leftrightarrow$' />
	  <char num='8704' name='forall' convertTo='$\\forall$' />
	  <char num='8706' name='part' convertTo='$\\partial$' />
	  <char num='8707' name='exist' convertTo='$\\exists$' />
	  <char num='8709' name='empty' convertTo='$\\emptyset$' />
	  <char num='8711' name='nabla' convertTo='$\\nabla$' />
	  <char num='8712' name='isin' convertTo='$\\in$' />
	  <char num='8715' name='ni' convertTo='$\\ni$' />
	  <char num='8713' name='notin' convertTo='$\\notin$' />

	  <char num='8721' name='sum' convertTo='$\\sum$' />
	  <char num='8719' name='prod' convertTo='$\\prod$' />
	  <char num='8722' name='minus' convertTo='$-$' />
	  <char num='8727' name='lowast' convertTo='$\\ast$' />
	  <char num='8730' name='radic' convertTo='$\\surd$' />
	  <char num='8733' name='prop' convertTo='$\\propto$' />
	  <char num='8734' name='infin' convertTo='$\\infty$' />
	  <char num='8736' name='ang' convertTo='$\\angle$' />
	  <char num='8743' name='and' convertTo='$\\wedge$' />

	  <char num='8744' name='or' convertTo='$\\vee$' />
	  <char num='8745' name='cup' convertTo='$\\cup$' />
	  <char num='8746' name='cap' convertTo='$\\cap$' />
	  <char num='8747' name='int' convertTo='$\\int$' />
	  <char num='8756' name='there4' convertTo='$\\therefore$' package='amssymb' /> <!-- only AMS -->
	  <char num='8764' name='sim' convertTo='$\\sim$' />
	  <char num='8776' name='asymp' convertTo='$\\approx$' />
	  <char num='8773' name='cong' convertTo='$\\cong$' />

	  <char num='8800' name='ne' convertTo='$\\neq$' />
	  <char num='8801' name='equiv' convertTo='$\\equiv$' />
	  <char num='8804' name='le' convertTo='$\\leq$' />
	  <char num='8805' name='ge' convertTo='$\\geq$' />
	  <char num='8834' name='sub' convertTo='$\\subset$' />
	  <char num='8835' name='sup' convertTo='$\\supset$' />
<!--	  <char num='8838' name='sube' convertTo='$\\subseteq$' />-->
	  <char num='8839' name='supe' convertTo='$\\supseteq$' />
<!--	  <char num='8836' name='nsub' convertTo='$\\nsubset$'  /> --><!-- only AMS -->

	  <char num='8853' name='oplus' convertTo='$\\oplus$' />
	  <char num='8855' name='otimes' convertTo='$\\otimes$' />
	  <char num='8869' name='perp' convertTo='$\\perp$' />
	  <char num='8901' name='sdot' convertTo='$\\cdot$' />
	  <char num='8968' name='rceil' convertTo='$\\rceil$' />
	  <char num='8969' name='lceil' convertTo='$\\lceil$' />
	  <char num='8970' name='lfloor' convertTo='$\\lfloor$' />
	  <char num='8971' name='rfloor' convertTo='$\\rfloor$' />
	  <char num='9001' name='rang' convertTo='$\\rangle$' />

	  <char num='9002' name='lang' convertTo='$\\langle$' />
	  <char num='9674' name='loz' convertTo='$\\lozenge$' package='amssymb' /> <!-- only AMS -->
	  <char num='9824' name='spades' convertTo='$\\spadesuit$' />
	  <char num='9827' name='clubs' convertTo='$\\clubsuit$' />
	  <char num='9829' name='hearts' convertTo='$\\heartsuit$' />
	  <char num='9830' name='diams' convertTo='$\\diamondsuit$' />                                     
	  <char num='38' name='amp' convertTo='\\@AMP' />    
<!--	  <char num='34' name='quot' convertTo='\\@DOUBLEQUOT' />  XXX -->
	<char num='34' name='quot' convertTo='\"' /> 
	<char num='39' name='apos' convertTo=\"'\" /> 
	  <char num='169' name='copy' convertTo='\\copyright' />

	  <char num='60' name='lt' convertTo='$@LT$' />
	  <char num='62' name='gt' convertTo='$@GT$' />
	  <char num='338' name='OElig' convertTo='\\OE' />
	  <char num='339' name='oelig' convertTo='\\oe' />
	  <char num='352' name='Scaron' convertTo='\\v{S}' />
	  <char num='353' name='scaron' convertTo='\\v{s}' />
	  <char num='376' name='Yuml' convertTo='\\\"Y' />
	  <char num='710' name='circ' convertTo='\\textasciicircum' />
	  <char num='732' name='tilde' convertTo='\\textasciitilde' />

	  <char num='8211' name='ndash' convertTo='--' />
	  <char num='8212' name='mdash' convertTo='---' />
	  <char num='8216' name='lsquo' convertTo='`' />
	  <char num='8217' name='rsquo' convertTo=\"'\" /> <!-- XXXX -->
	  <char num='8220' name='ldquo' convertTo='``' />
	  <char num='8221' name='rdquo' convertTo=\"''\" /> <!-- XXXX -->
	  <char num='8224' name='dagger' convertTo='\\dag' />
	  <char num='8225' name='Dagger' convertTo='\\ddag' />
	  <char num='8240' name='permil' convertTo='\\permil' package='wasysym' /> <!-- wasysym package -->

	  <char num='8364' name='euro' convertTo='\\euro' package='eurosym' /> <!-- eurosym package -->
	  <char num='8249' name='lsaquo' convertTo='\\guilsinglleft' package='aeguill'/>
	  <char num='8250' name='rsaquo' convertTo='\\guilsinglright' package='aeguill' />
<!--	  <char num='160' name='nbsp' convertTo='\\nolinebreak' />-->
	  <char num='160' name='nbsp' convertTo='~' />
	  <char num='161' name='iexcl' convertTo='\\textexclamdown' />
	  <char num='163' name='pound' convertTo='\\pounds' />
	  <char num='164' name='curren' convertTo='\\currency' package='wasysym' /> <!-- wasysym package -->
	  <char num='165' name='yen' convertTo='\\textyen' package='textcomp'/> <!-- textcomp -->

	  <char num='166' name='brvbar' convertTo='\\brokenvert' /> <!-- wasysym -->
	  <char num='167' name='sect' convertTo='\\S' />
	  <char num='171' name='laquo' convertTo='\\guillemotleft' package='aeguill'/>
	  <char num='187' name='raquo' convertTo='\\guillemotright' package='aeguill'/>
	  <char num='174' name='reg' convertTo='\\textregistered' />
	  <char num='170' name='ordf' convertTo='\\textordfeminine' />
	  <char num='172' name='not' convertTo='$\\neg$' />
	<!--  <char num='176' name='deg' convertTo='$\\degree$' /> --><!-- mathabx -->
	  <char num='176' name='deg' convertTo='\\textdegree' package='textcomp'/>

	  <char num='177' name='plusmn' convertTo='$\\pm$' />
	  <char num='180' name='acute' convertTo='@QUOT' />
	  <char num='181' name='micro' convertTo='$\\mu$' />
	  <char num='182' name='para' convertTo='\\P' />
	  <char num='183' name='middot' convertTo='$\\cdot$' />
	  <char num='186' name='ordm' convertTo='\\textordmasculine' />
	  <char num='162' name='cent' convertTo='\\cent' package='wasysym' /> 
	  <char num='185' name='sup1' convertTo='$^1$' />

	  <char num='178' name='sup2' convertTo='$^2$' />
	  <char num='179' name='sup3' convertTo='$^3$' />
	  <char num='189' name='frac12' convertTo='$\\frac{1}{2}$' />
	  <char num='188' name='frac14' convertTo='$\\frac{1}{4}$' />
	  <char num='190' name='frac34' convertTo='$\\frac{3}{4}$' />
	  <char num='192' name='Agrave' convertTo='\\`A' />
	  <char num='193' name='Aacute' convertTo='\\@QUOTA' />
	  <char num='194' name='Acirc' convertTo='\\^A' />
	  <char num='195' name='Atilde' convertTo='\\~A' />

	  <char num='196' name='Auml' convertTo='\\@DOUBLEQUOTA' />
	  <char num='197' name='Aring' convertTo='\\AA' />
	  <char num='198' name='AElig' convertTo='\\AE' />
	  <char num='199' name='Ccedil' convertTo='\\c{C}' />
	  <char num='200' name='Egrave' convertTo='\\`E' />
	  <char num='201' name='Eacute' convertTo='\\@QUOTE' />
	  <char num='202' name='Ecirc' convertTo='\\^E' />
	  <char num='203' name='Euml' convertTo='\\@DOUBLEQUOTE' />
	  <char num='204' name='Igrave' convertTo='\\`I' />
	  <char num='205' name='Iacute' convertTo='\\@QUOTI' />
	  <char num='206' name='Icirc' convertTo='\\^I' />
	  <char num='207' name='Iuml' convertTo='\\\"I' />
	  <char num='208' name='ETH' convertTo='$\\eth$' /> <!-- AMS -->
	  <char num='209' name='Ntilde' convertTo='\\~N' />    
	  <char num='210' name='Ograve' convertTo='\\`O' />
	  <char num='211' name='Oacute' convertTo='\\@QUOT O' />
	  <char num='212' name='Ocirc' convertTo='\\^O' />
	  <char num='213' name='Otilde' convertTo='\\~O' />
	  <char num='214' name='Ouml' convertTo='\\@DOUBLEQUOTO' />
	  <char num='215' name='times' convertTo='$\\times$' />
	  <char num='216' name='Oslash' convertTo='\\O' />
	  <char num='217' name='Ugrave' convertTo='\\`U' />
	  <char num='218' name='Uacute' convertTo='\\@QUOTU' />
	  <char num='219' name='Ucirc' convertTo='\\^U' />
	  <char num='220' name='Uuml' convertTo='\\@DOUBLEQUOTU' />
	  <char num='221' name='Yacute' convertTo='\\@QUOTY' />
	  <char num='223' name='szlig' convertTo='\\ss' />
	  <char num='224' name='agrave' convertTo='\\`a' />
	  <char num='225' name='aacute' convertTo='\\@QUOTa' />
	  <char num='226' name='acirc' convertTo='\\^a' />
	  <char num='227' name='atilde' convertTo='\\~a' />
	  <char num='228' name='auml' convertTo='\\@DOUBLEQUOTa' />
	  <char num='229' name='aring' convertTo='\\aa' />
	  <char num='230' name='aelig' convertTo='\\ae' />
	  <char num='231' name='ccedil' convertTo='\\c{c}' />
	  <char num='232' name='egrave' convertTo='\\`e' />
	  <char num='233' name='eacute' convertTo='\\@QUOTe' />
	  <char num='234' name='ecirc' convertTo='\\^e' />
	  <char num='235' name='euml' convertTo='\\@DOUBLEQUOTe' />    
	  <char num='236' name='igrave' convertTo='\\`i' />
	  <char num='237' name='iacute' convertTo='\\@QUOTi' />
	  <char num='238' name='icirc' convertTo='\\^i' />
	  <char num='239' name='iuml' convertTo='\\@DOUBLEQUOTi' />
	  <char num='240' name='eth' convertTo='$\\eth$' package='amssymb'/> <!-- -->
	  <char num='241' name='ntilde' convertTo='\\~n' />
	  <char num='242' name='ograve' convertTo='\\`o' />
	  <char num='243' name='oacute' convertTo='\\@QUOTo' />
	  <char num='244' name='ocirc' convertTo='\\^o' />
	  <char num='245' name='otilde' convertTo='\\~o' />
	  <char num='246' name='ouml' convertTo='\\@DOUBLEQUOTo' />
<!--   <char num='247' name='divide' convertTo='$\\divide$' />       -->
	  <char num='248' name='oslash' convertTo='\\o' /> 
	  <char num='249' name='ugrave' convertTo='\\`u' />
	  <char num='250' name='uacute' convertTo='\\@QUOTu' />
	  <char num='251' name='ucirc' convertTo='\\^u' />
	  <char num='252' name='uuml' convertTo='\\@DOUBLEQUOTu' />
	  <char num='253' name='yacute' convertTo='\\@QUOTy' />

	  <char num='255' name='yuml' convertTo='\\@DOUBLEQUOTy' />                  

		<char num='222' name='THORN' convertTo='\\Thorn' package='wasysym' /> 
		<char num='254' name='thorn' convertTo='\\thorn' package='wasysym' />
	</chars>"
	

end end end

