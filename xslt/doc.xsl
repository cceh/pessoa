<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    <xsl:strip-space elements="rs"/>
    <xsl:template match="/" mode="normal">
        <style type="text/css">
            /*Textstruktur*/
             div.text {display: inline-block; position: relative; }
            .text h2 {margin-bottom: 20px; margin-top: 20px; text-align:left;}
            .item {margin-bottom: 20px; position: relative;}
            .item .label {padding-right: 1em;display: inline-table;}
            .list .item .list .item {margin-left: 2em;}
            
            /*notes*/
            .note {position: absolute; font-size: small; vertical-align: middle;}
            .note.right {right: -50px;}
            .note.margin.left {left: 5em;}
            .note.addition.margin.right {right: -120px;}
            .note.addition.margin.top.right {right: -120px;}
            .note.addition.margin.left {left: -35em;}
            .note-label.margin.left {padding: 0px;}
            
            /*metamarks*/
            .metamark {cursor: pointer;}
            
            .metamark.bracket {font-size: 32pt; font-family: Times; vertical-align: middle; float:none;}
            .metamark.curly-bracket {font-size: 32pt; font-family: Times; vertical-align: middle; float: none;}
            .metamark.curly-bracket.grouping.right {float: none;  right: -150px vertical-align: middle;}
         
            .metamark.line.assignment {display:inline;}
            .metamark.line.highlight {margin: 0.5em;}
            .metamark.quotes.ditto {display: inline; padding-left: 15px; padding-right: 15px;}
            .metamark.line.distinct {margin-bottom:20px; text-align:center; line-height: 50%}
            .metamark.line.end {margin-bottom:20px; text-align:center; line-height:50%}
            .metamark.double.line{margin-bottom:20px; text-align:center; line-height: 50%;} 
            
            .red {color: red;}
            .offset {margin-left: 2em;}
            .indent {margin-left: 2em;}
            .right {float: right;}   
            .left {float: left;}
            .center {text-align: center;}
            
            .delSpan{background: -webkit-canvas(lines);  }
            .verticalLine {background: -webkit-canvas(verticalLine); display: inline-table; margin-left:110px; width:10px; height:60px;}
            .circled {background: -webkit-canvas(circle); width:25px; height:25px;}

            p {font-size: 16px;}
            
            .ab {display: inline-block;}
  
            .seg {position: relative;}
           /* .seg.add.below {position: absolute; top: -0.8em; left: 0; font-size: small; width:200%;} */
            
            .choice {position: relative;}
            /*.choice .add.below {position: absolute; top: 1.5em; left: 0; font-size: small;}*/
        
            .subst {position: relative;}
          
          /*  .add.below {position: absolute; top: 1.5em; left: -20px; font-size: small; width:200%} */
            .add {top: 0;}
    
            .above { position: absolute; top: -0.8em; left: 0; font-size: small; width:200%;}
            .below{position: absolute; top: 1.5em; left: 0px; font-size: small; width:200%}
            
           
           
            .del {text-decoration: line-through;}
            .gap {cursor: pointer;}
            .supplied {cursor: pointer;}           
          /*  .ex, .supplied {color: purple;} */
            
            
            

        </style>
        <xsl:apply-templates />       
    </xsl:template>

 
    <!-- "Eingangstemplate" --> 
    <xsl:template match="*" priority="5">
        <xsl:param name="special">no</xsl:param>
        <xsl:if test="$special='no'">
            <xsl:apply-templates select="." mode="normal"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Header & Text -->
    <xsl:template match="teiHeader" mode="normal" />
    <xsl:template match="text" mode="normal">
        <xsl:choose>
            <xsl:when test="//note[@place='margin left']">
                <div class="text" style="padding-left:100px;">
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>                   
                    <xsl:apply-templates/> 
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="text">
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if> 
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>         
    </xsl:template>
    
    <xsl:template match="div[@rend='text-center']">
        <div class ="div center">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
   
   
    <!-- Textstruktur -->
    <xsl:template match="head" mode="normal">
        <h2>
            <xsl:if test="ancestor::*[@rend='text-center']">
                <xsl:attribute name="style">text-align: center;</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <xsl:template match="head[hi[@rend='underline center']]" mode="normal">
       <h2 style="text-align: center;">
           <xsl:apply-templates/>
       </h2> 
    </xsl:template>
    <xsl:template match="list/head" mode="normal">
        <h2>
            <xsl:if test="name(../preceding-sibling::node()[1])='label' and name(../parent::node())='item'">
                <xsl:attribute name="style">display: inline;</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h2> 
    </xsl:template>
    
    <xsl:template match="list" mode="normal">
        <div class="list">
        <xsl:if test="name(preceding-sibling::node()[1])='label' and name(..)='item'">
            <xsl:attribute name="style">display: inline;</xsl:attribute>
        </xsl:if>
            <xsl:apply-templates/>
        </div>                   
    </xsl:template>
    
    <xsl:template match="item" mode="normal">
        <div class="item">
            <xsl:if test="@xml:id">
                <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template> 
    <xsl:template match="label[seg[add[@place]]]">
        <span class="label" style="margin-bottom: 10px;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- zusätzliche Bemerkungen am Rand -->
    
    <!--notes-->
    <xsl:template match="note[@type='addition'][@place='margin top right']" mode="normal">
        <span class="note addition margin top right">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type='addition'][@place='margin left']" mode="normal">
        <xsl:variable name="range">
            <xsl:choose>
                <xsl:when test="@target = 'range(i1,i3)'">r1-3</xsl:when>
                <xsl:when test="@target = 'range(i4,i6)'">r4-6</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <span class="note addition margin left {ancestor::text/@xml:id} {$range}">
            <xsl:if test="child::label[1]">
                <xsl:attribute name="style">left: -100px;</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
<<<<<<< Updated upstream
    <xsl:template match="note[@type='addition'][@place='right']">
        <span class="note addition right">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type='addition'][@place='margin right']">
=======
    <xsl:template match="note[@type='addition'][@place='margin right']" mode="normal">
>>>>>>> Stashed changes
        <xsl:variable name="target">
            <xsl:choose>
                <xsl:when test="contains(@target, 'range')">
                    <xsl:value-of select="substring-before(substring-after(@target, 'range('), ',')"/>       
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@target" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span class="note addition margin right target-{$target}">   
            <xsl:if test="parent::*[1][lb] or preceding-sibling::*[lb] and not(contains(@target,'range'))">
                <xsl:attribute name="style">bottom: 1em;</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>     
    </xsl:template>
    
    <xsl:template match="note[not(@type)][@place='margin left']" mode="normal">
        <span class="note margin left">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="note[@place='right'][not(@type)]" mode="normal">
        <span class="note right">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="note[@resp]" mode="normal">
        <div class="editorial note">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!--note-labels-->
    
    <xsl:template match="label[parent::note[@place='margin left']]" mode="normal">
        <span class="note-label margin left">
            <xsl:apply-templates/> 
        </span>
    </xsl:template>
    
    <!-- metamarks -->
    <!--brackets-->
    <xsl:template match="metamark[@rend='curly bracket'][@function='grouping'][parent::note/contains(@place, 'margin left')]" mode="normal">
        <span class="metamark curly-bracket grouping left {ancestor::text/@xml:id}" title="grouping">{</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='curly bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]" mode="normal">
        <span class="metamark curly-bracket grouping right {ancestor::text/@xml:id}" title="grouping">}</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]" mode="normal">
        <span class="metamark bracket grouping right {ancestor::text/@xml:id}" title="grouping">]</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='curly bracket'][@place='margin right'][@function='grouping']" mode="normal">
        <span class="metamark curly-bracket grouping right {ancestor::text/@xml:id}" title="grouping" style="position: absolute; right: -150px;">}</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='curly bracket'][@function='assignment'][parent::note[@place='right']]" mode="normal">
        <div class="metamark curly-bracket assignment right">
            <xsl:if test="following-sibling::*">
                <xsl:attribute name="style">display: inline;</xsl:attribute>
            </xsl:if>            
            }</div>
    </xsl:template>
    
    <!--lines-->
    <xsl:template match="metamark[@rend='line'][@function='end']" mode="normal">
        <div class="metamark line end">_______________________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='assignment']" mode="normal">
        <div class="metamark line assignment">   ______ </div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='distinct']" mode="normal">
        <xsl:choose>
            <xsl:when test="label[@place='right'][@rend='red']">
                <xsl:variable name="label" select="label/data(.)"/>
                <div class="metamark line distinct">_______________________<span style="color: red;"><xsl:value-of select="$label"/></span></div> 
            </xsl:when>
            <xsl:otherwise>
                <div class="metamark line distinct">_______________________</div>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:template>  
<<<<<<< Updated upstream
    <xsl:template match="choice/abbr/metamark[@rend='line'][@function='ditto']">
        <xsl:variable name="expan" select="following::expan[1]/data(.)"/>
        <xsl:variable name="size" select='count($expan)'/>
        <span class="metamark line ditto">
            <xsl:for-each select="0 to string-length($expan)">_</xsl:for-each>
        </span>
    </xsl:template>
    <!--<xsl:template match="metamark[@rend='line'][@function='ditto']">
        <span class="metamark line ditto">_______</span>
    </xsl:template> -->
    <xsl:template match="metamark[@rend='line red'][@function='distinct']">
=======
    <xsl:template match="metamark[@rend='line'][@function='ditto']" mode="normal">
        <span class="metamark line ditto">_______</span>
    </xsl:template> 
    <xsl:template match="metamark[@rend='line red'][@function='distinct']" mode="normal">
>>>>>>> Stashed changes
        <div class="metamark line distinct red">_______________________</div>
    </xsl:template> 
    <xsl:template match="metamark[@rend='line'][@function='highlight']" mode="normal">
        <div class="metamark line highlight">_______________________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@place='left']" mode="normal">
        <div class="verticalLine" title="left">      </div>
    </xsl:template>
    <xsl:template match="metamark[@rend='underline'][@function='distinct']" mode="normal">
        <div class="metamark underline" title="distinct">_______________________</div>
    </xsl:template> 
    <xsl:template match="metamark[@rend='double line'][@function='distinct']" mode="normal">
        <div class="metamark double line" title="distinct">
            _______________________<br/>
            _______________________
        </div>
    </xsl:template>
    
    <!--quotes-->
    <xsl:template match="metamark[@rend='quotes'][@function='ditto']" mode="normal">
        <div class="metamark quotes ditto"> " </div>
    </xsl:template>
    <xsl:template match="metamark[@rend='quotation marks'][@function='ditto']">
        <div class="metamark quotes ditto"> " </div>
    </xsl:template>
    
    <!--Pfeile-->

    
    
    <!-- Hervorhebungen -->
    <xsl:template match="hi[@rend='underline']" mode="normal">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='underline center']" mode="normal">
        <span style="text-decoration: underline; text-align: center;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='superscript']" mode="normal">
        <span style="position:relative;top:-4px; font-size: small;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='red']" mode="normal">
        <span style="color: red;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='underline red']" mode="normal">
        <span style="text-decoration: underline; color: red;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='underline-red']" mode="normal">
        <span style="text-decoration: underline; color: red;">
            <span style="color: black;">
            <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='italic']" mode="normal">
        <span style="font-style: italic;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='circled']" mode="normal">
        <div class="circled">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Personen, Orte, etc. -->
    <xsl:template match="rs[@type='person']" mode="normal">
        <span class="person {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='place']" mode="normal">
        <span class="place {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='journal']" mode="normal">
        <span class="journal {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='work']" mode="normal">
        <span class="work {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="rs[@type='text']" mode="normal">
        <span class="text {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Zeilenumbrüche anzeigen -->
    <xsl:template match="lb" mode="normal">
        <br/>
    </xsl:template>
    
    <!-- editorische Ergänzungen nicht anzeigen -->
    <xsl:template match="supplied" mode="normal"/>
    
    <!-- Einrückungen / Ausrichtungen berücksichtigen -->
    <xsl:template match="hi[@rend='indent']" mode="normal">
        <span class="indent">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ab[@rend='offset']" mode="normal">
        <span class="ab offset">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ab[@rend='indent']" mode="normal">
        <span class="ab indent">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ab[@rend='right']" mode="normal">
        <span class="ab right">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- choices -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']" mode="normal">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[1]"/>
            </span>
            <span class="add below">
                <xsl:apply-templates select="seg[2]/add/text()"/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[abbr/gap and expan[@resp]]" mode="normal">
        <span class="choice">
            <span class="abbr">
                <span class="gap" title="{abbr/gap/@reason}">
                    <xsl:if test="abbr/gap/@unit = 'character'">
                        [<xsl:for-each select="1 to abbr/gap/@quantity">?</xsl:for-each>]
                    </xsl:if>
                </span>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place='above']" mode="normal">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[1]"/>
            </span>
            <span class="add above">
                <xsl:apply-templates select="seg[2]/add/text()"/>
            </span>
        </span>
    </xsl:template>
    
    <!-- Auflösungen von Abkürzungen nicht anzeigen -->
<<<<<<< Updated upstream
    <xsl:template match="expan">
        <xsl:text> </xsl:text>
    </xsl:template>
=======
    <xsl:template match="expan" mode="normal" />
>>>>>>> Stashed changes
    
    <!-- gaps -->
    <xsl:template match="gap[@reason='selection']" mode="normal">
        <span class="gap" title="selection">[...]</span>
    </xsl:template>
    
<<<<<<< Updated upstream

        

    
    <!-- del - -->
    <xsl:template match="del[gap]">
=======
    <!-- del -->
    <xsl:template match="del[gap]" mode="normal">
>>>>>>> Stashed changes
        <span class="del">
            [<xsl:value-of select="for $c in (1 to gap/@quantity) return '?'"/>]
        </span>
    </xsl:template>
    <xsl:template match="del" mode="normal">
        <span class="del">
            <xsl:apply-templates/>          
        </span>
    </xsl:template>
    <xsl:template match="del[following-sibling::add[1][@place ='superimposed']]" mode="normal">
        <span class="del superimposed">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="del[@rend='overtyped' and following-sibling::add[1][not(@*)]]" mode="normal">
        <span class="del overtyped">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="del[@rend='overwritten']" mode="normal">
        <span class="del overwritten">
            <xsl:apply-templates/>
        </span>
    </xsl:template> 
    
    <!-- subst -->
    <xsl:template match="subst[del and add]">
        <span class="subst">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    
    
    <!-- tabellen  z.B. 48G-33r--> 
    <xsl:template match="text//table" mode="normal">
            <xsl:apply-templates/>     
    </xsl:template>
    <xsl:template match="table/row" mode="normal">
        <div class="item">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="cell" mode="normal">
                <xsl:apply-templates/> 
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="label" mode="normal">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
   

 

    
    <xsl:template match="seg" mode="normal">         
        <span>
            <xsl:choose>
                <xsl:when test="@rend='indent'">
                    <xsl:attribute name="class">seg indent</xsl:attribute>    
                </xsl:when>
                <xsl:when test="@rend='right'">
                    <xsl:attribute name="class">seg right</xsl:attribute>
                </xsl:when>
                <xsl:when test="@rend='left'">
                    <xsl:attribute name="class">seg left</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">seg</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
<<<<<<< Updated upstream
   

    
    
    

        
    
    
 
    

    
    <xsl:template match="delSpan">
=======
    
    <xsl:template match="delSpan" mode="normal">
>>>>>>> Stashed changes
        <xsl:variable name="anchorID" select="@spanTo/substring-after(.,'#')" />
        <div class="delSpan">
            <xsl:apply-templates select="following-sibling::*[following::anchor[@xml:id=$anchorID]]"/>
        </div>
        </xsl:template> 
    
   <xsl:template match="*[preceding-sibling::delSpan][following::anchor[@xml:id=current()/preceding-sibling::delSpan/@spanTo/substring-after(.,'#')]]" priority="3" mode="normal">
      <xsl:apply-templates select=".">
          <xsl:with-param name="special">yes</xsl:with-param>
      </xsl:apply-templates>
   </xsl:template>
    

<<<<<<< Updated upstream
   
   
    
   
   
    
    <!-- add -->
   
    <xsl:template match="add[@place='below'][not(ancestor::choice)][not(ancestor::subst)]">
=======
    <!-- subst -->
    <xsl:template match="subst[del and add/@place] | subst[del and add]" mode="normal">
        <xsl:variable name="place" select="add/@place"/>
        <span class="subst">
            <xsl:apply-templates/>
           <!-- <span class="del">
                <xsl:apply-templates select="del/text()"/>
            </span>
            <span class="add {$place}">
                <xsl:apply-templates select="add/text()"/>
            </span>-->
        </span>
    </xsl:template>
    

   
    
    <!-- add -->
    <xsl:template match="add[@place='above'][not(ancestor::choice)]" mode="normal">
        <span class="add above">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="add[@place='below'][not(ancestor::choice)]" mode="normal">
>>>>>>> Stashed changes
        <span class="add below">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="add" mode="normal">
      <span class="add">
          <xsl:apply-templates/>
      </span>
  </xsl:template>
    <xsl:template match="add[@place='above']">
        <span class=" add above">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="add[@resp]" mode="normal"/>

    
   

    <xsl:template match="p" mode="normal">
    <p>
        <xsl:apply-templates/>
    </p>
</xsl:template>
    
    <xsl:template match="p[@rend='indent']" mode="normal">
        <p style="indent">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
 <xsl:template match="p[@rend='text-center']" mode="normal">
    <p style="text-align: center;">
        <xsl:apply-templates/>
    </p>
</xsl:template>
    <xsl:template match="p[@rend='position-center']" mode="normal">
     <p style="text-align: center;">
         <xsl:apply-templates/>
     </p>
 </xsl:template>   

<<<<<<< Updated upstream
<!-- special case 87-68r-->
    <xsl:template match="text[@xml:id='bnp-e3-87-68r']//ab[@rend='right']" priority="1" >
        <div class ="ab right">
        <xsl:apply-templates/>
        </div><br/>
    </xsl:template>

  
=======

>>>>>>> Stashed changes
  
</xsl:stylesheet>

