<xsl:stylesheet xmlns:xsl="http://wwwc.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    <xsl:strip-space elements="rs"/>
   
    <xsl:template match="/">
        <style type="text/css">
            /*Textstruktur*/
             div.text {display: inline-block; position: relative; line-height: 1.8;}
             .text h2 {margin-bottom: 20px; margin-top: 20px; text-align:left; line-height: 1.5;}
            .item {margin-bottom: 20px; margin-top: 10px; position: relative;}
            .item .label {padding-right: 1em;display: inline-table;}
            .list .item .list .item {margin-left: 2em;}
             p {font-size: 16px;}
            
            /*notes*/
            .note {position: absolute; font-size: small; vertical-align: middle;}
            .note.right {right: -50px;}
            .note.margin.left {left: 5em;}
            .note.addition.margin.right {right: -120px;}
            .note.addition.margin.top.right {right: -120px;}
            .note.addition.margin.left {left: -35px;;}
            .note-label.margin.left {padding: 0px; float: none;}
            .editorial-note {text-align: justify;}
            
            
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
            
           /* .red {color: red;} */
            .offset {margin-left: 2em;}
            .indent {margin-left: 2em;}
            .right {float: right;}   
            .left {float: left;}
            .center {text-align: center;}
            .above { position: absolute; top: -0.8em; left: 0px;; font-size: small; width:205%;}
            .below{position: absolute; top: 1.5em; left: 0px; font-size: small; width:200%}
            .ab {display: inline-block;}
            .seg {position: relative;}          
            .choice {position: relative;}
            .subst {position: relative;}
            /*.add {top: 0;}*/
            .del {text-decoration: line-through;}
            .gap {cursor: pointer;}
            .supplied {cursor: pointer;}           
            /*  .ex, .supplied {color: purple;} */
            
            .delSpan{background: -webkit-canvas(lines); background: -moz-element(lines);}
            .verticalLine {background: -webkit-canvas(verticalLine); background: -moz-element(verticalLine); display: inline-table; margin-left:110px; width:10px; height:60px;}
            .circled {background: -webkit-canvas(circle); background: -moz-element(circle);  width:25px; height:25px;}

            /*special case 71A-2V*/
            #bnp-e3-71a-2v .below{left: -40px;}   
            #bnp-e3-71a-2v .note {position: relative;}
            
        </style>
        <xsl:apply-templates />       
    </xsl:template>
    
    <!-- Header & Text -->
    <xsl:template match="teiHeader"/>
    <xsl:template match="text" >
        <xsl:choose>
            <xsl:when test="//note[@place='margin left']">
                <div class="text" style="padding-left:100px;">
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>                   
                    <xsl:apply-templates /> 
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="text">
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if> 
                    <xsl:apply-templates />
                </div>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="//msDesc[@type='prose']"/>
    </xsl:template>
    
    <!-- editorial notes -->
    <xsl:template match="msDesc[@type='prose']">
        <div class="editorial-note">
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <xsl:template match="ref[@target]">
        <xsl:variable name="id" select="@target"/>
        <a href="../data/doc/{$id}"> <xsl:apply-templates/></a>     
    </xsl:template>
    
    
    <xsl:template match="div[@rend='text-center']" >
        <div class ="div center">
            <xsl:apply-templates  />
        </div>
    </xsl:template>
   
   
    <!-- Textstruktur -->
    <xsl:template match="head" >
        <h2>
            <xsl:if test="ancestor::*[@rend='text-center']">
                <xsl:attribute name="style">text-align: center;</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates  />
        </h2>
    </xsl:template>
    <xsl:template match="head[hi[@rend='underline center']]" >
       <h2 style="text-align: center;">
           <xsl:apply-templates />
       </h2> 
    </xsl:template>
    <xsl:template match="list/head" >
        <h2>
            <xsl:if test="name(../preceding-sibling::node()[1])='label' and name(../parent::node())='item'">
                <xsl:attribute name="style">display: inline;</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </h2> 
    </xsl:template>
    
    <xsl:template match="list" >
        <div class="list">
        <xsl:if test="name(preceding-sibling::node()[1])='label' and name(..)='item'">
            <xsl:attribute name="style">display: inline;</xsl:attribute>
        </xsl:if>
        <xsl:if test="following-sibling::list[1]">
            <xsl:attribute name="style">padding-bottom: 20px;</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates />
        </div>                   
    </xsl:template>
    
    <xsl:template match="item" >
        <div class="item">
            <xsl:if test="@xml:id">
                <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </div>
    </xsl:template> 
    <xsl:template match="label[seg[add[@place]]]" >
        <span class="label" style="margin-bottom: 10px;">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- zusätzliche Bemerkungen am Rand -->
    
    <!--notes-->
    <xsl:template match="note[@type='addition'][@place='margin top right']" >
        <span class="note addition margin top right">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type='addition'][@place='margin left']" >
        <xsl:variable name="target">
            <xsl:choose>
                <xsl:when test="contains(@target, 'range')">
                    <xsl:value-of select="concat(substring-before(substring-after(@target, 'range('), ','),'-',substring-before(substring-after(@target,','),')'))"/>       
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@target" />
                </xsl:otherwise>
            </xsl:choose> 
        </xsl:variable>
        <span class="note addition margin left target-{$target}">
            <xsl:attribute name="style">
                <xsl:if test="contains(@target,'range')">
                    <xsl:variable name="from" select="substring-after(substring-before($target,'-'),'I')"/>
                    <xsl:variable name="to" select ="substring-after($target,'-I')"/>
                    <xsl:if test="number($to)-number($from) > 1"> 
                       top: -2em;   
                    </xsl:if>                 
                </xsl:if>
            <xsl:if test="child::label[1]">
                left: -100px;
            </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type='addition'][@place='right']" >
        <span class="note addition right">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type='addition'][@place='margin right']" >
        <xsl:variable name="target">
            <xsl:choose>
                <xsl:when test="contains(@target, 'range')">
                    <xsl:value-of select="concat(substring-before(substring-after(@target, 'range('), ','),'-',substring-before(substring-after(@target,','),')'))"/>       
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
            <xsl:if test="contains(@target,'range')">
                <xsl:variable name="from" select="substring-after(substring-before($target,'-'),'I')"/>
                <xsl:variable name="to" select ="substring-after($target,'-I')"/>
                    <xsl:if test="number($to)-number($from) > 1"> 
                        <xsl:attribute name="style">top: -2em;</xsl:attribute>   
                    </xsl:if>                 
            </xsl:if>
            <xsl:apply-templates />
        </span>     
    </xsl:template>
    
    <xsl:template match="note[not(@type)][@place='margin left']" >
        <span class="note margin left">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="note[@place='right'][not(@type)]" >
        <span class="note right">
            <xsl:if test="@target='#I2' and ancestor::text[@xml:id='bnp-e3-87-39r']">
                <xsl:attribute name="style">top: -20px;</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    
    <!--note-labels-->
    
    <xsl:template match="label[parent::note[@place='margin left']]" >
        <span class="note-label margin left">
            <xsl:apply-templates /> 
        </span>
    </xsl:template>
    
    <!-- metamarks -->
    <!--brackets-->
    <xsl:template match="metamark[@rend='curly-bracket'][@function='grouping'][parent::note/contains(@place, 'margin left')]" >
        <span class="metamark curly-bracket grouping left {ancestor::text/@xml:id}" title="grouping">{</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='curly-bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]" >
        <span class="metamark curly-bracket grouping right {ancestor::text/@xml:id}" title="grouping">}</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]" >
        <span class="metamark bracket grouping right {ancestor::text/@xml:id}" title="grouping">]</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='curly-bracket'][@place='margin right'][@function='grouping']" >
        <span class="metamark curly-bracket grouping right {ancestor::text/@xml:id}" title="grouping" style="position: absolute; right: -150px;">}</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='curly-bracket'][@function='assignment'][parent::note[@place='right']]" >
        <div class="metamark curly-bracket assignment right">
            <xsl:if test="following-sibling::*">
                <xsl:attribute name="style">display: inline;</xsl:attribute>
            </xsl:if>            
            }</div>
    </xsl:template>
    
    <!--lines-->
    <xsl:template match="metamark[@rend='line'][@function='end']" >
        <div class="metamark line end">_______________________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='assignment']" >
        <div class="metamark line assignment">   ______ </div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='distinct']" >
        <xsl:choose>
            <xsl:when test="label[@place='right'][@rend='red']">
                <xsl:variable name="label" select="label/data(.)"/>
                <div class="metamark line distinct">_______________________<xsl:value-of select="$label"/></div> 
            </xsl:when>
            <xsl:otherwise>
                <div class="metamark line distinct">_______________________</div>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:template>  
    <xsl:template match="choice/abbr/metamark[@rend='line'][@function='ditto']" >
        <xsl:variable name="expan" select="following::expan[1]/data(.)"/>
        <xsl:variable name="size" select='string-length($expan)'/>
        <span class="metamark line ditto">
            <xsl:for-each select="0 to $size">_</xsl:for-each>
        </span>
    </xsl:template>
    <!--<xsl:template match="metamark[@rend='line'][@function='ditto']">
        <span class="metamark line ditto">_______</span>
    </xsl:template> -->
    <xsl:template match="metamark[@rend='line red'][@function='distinct']" >
        <div class="metamark line distinct red">_______________________</div>
    </xsl:template> 
    <xsl:template match="metamark[@rend='line'][@function='highlight']" >
        <div class="metamark line highlight">_______________________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@place='left']" >
        <div class="verticalLine" title="left">      </div>
    </xsl:template>
    <xsl:template match="metamark[@rend='underline'][@function='distinct']" >
        <div class="metamark underline" title="distinct">_______________________</div>
    </xsl:template> 
    <xsl:template match="metamark[@rend='double-line'][@function='distinct']" >
        <div class="metamark double line" title="distinct">
            _______________________<br/>
            _______________________
        </div>
    </xsl:template>
    
    <!--quotes-->
    <xsl:template match="metamark[@rend='quotes'][@function='ditto']" >
        <div class="metamark quotes ditto"> " </div>
    </xsl:template>
    
    <!--Pfeile-->
    
    
    <!-- Hervorhebungen -->
    <xsl:template match="hi[@rend='underline']" >
        <span style="text-decoration: underline;">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='underline center']" >
        <span style="text-decoration: underline; text-align: center;">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='superscript']" >
        <span style="position:relative;top:-4px; font-size: small;">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='red']" >
        <span>
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='underline red']" >
        <span style="text-decoration: underline; ">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='underline-red']" >
        <span style="text-decoration: underline;">
            <xsl:apply-templates />         
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='italic']" >
        <span style="font-style: italic;">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='encircled']" >
        <span class="circled">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- Personen, Orte, etc. -->
    <xsl:template match="rs[@type='person']" >
        <span class="person {@key}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='place']" >
        <span class="place">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='journal']" >
        <span class="journal {@key}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='work']" >
        <span class="work {@key}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="rs[@type='text']" >
        <span class="text {replace(.,'[“”.\s]','')}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- Zeilenumbrüche anzeigen -->
    <xsl:template match="lb" >
        <br/>
    </xsl:template>
    <!-- Seitenumbrüche -->
    <xsl:template match="pb"/>
    
    <!-- editorische Ergänzungen nicht anzeigen -->
    <xsl:template match="supplied" />
    
    <!-- Einrückungen / Ausrichtungen berücksichtigen -->
        <xsl:template match="hi[@rend='indent']" >
        <span class="indent">
            <xsl:apply-templates />
        </span>
    </xsl:template>
        <xsl:template match="ab[@rend='offset']" >
        <span class="ab offset">
            <xsl:apply-templates />
        </span>
    </xsl:template>
        <xsl:template match="ab[@rend='indent']" >
        <span class="ab indent">
            <xsl:apply-templates />
        </span>
    </xsl:template>
        <xsl:template match="ab[@rend='right']" >
        <span class="ab right">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- choices -->
        <xsl:template match="choice[seg and seg[2]/add/@place='below']" >
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates  select="seg[1]"/>
            </span>
            <span class="add below">
                <xsl:apply-templates  select="seg[2]/add/text()"/>
            </span>
        </span>
    </xsl:template>
        <xsl:template match="choice[abbr/gap and expan[@resp]]" >
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
        <xsl:template match="choice[seg and seg[2]/add/@place='above']" >
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates  select="seg[1]"/>
            </span>
            <span class="add above">
                <xsl:apply-templates  select="seg[2]/add/text()"/>
            </span>
        </span>
    </xsl:template>
    
        <xsl:template match="choice//abbr" >
        <span class ="abbr">
            <xsl:apply-templates />
            <xsl:if test="following-sibling::choice[1]">
                <xsl:text>&#160;</xsl:text>
            </xsl:if>           
        </span>
    </xsl:template>
    
    <!-- Auflösungen von Abkürzungen nicht anzeigen -->
        <xsl:template match="expan" >
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- gaps -->
    <xsl:template match="gap[@reason='selection']"/>
    <xsl:template match="gap[@reason='illegible']"/>
    
    <!-- del - -->
        <xsl:template match="del[gap]" >
        <span class="del">
            [<xsl:value-of select="for $c in (1 to gap/@quantity) return '?'"/>]
        </span>
    </xsl:template>
        <xsl:template match="del" >
        <span class="del">
            <xsl:apply-templates />          
        </span>
    </xsl:template>
        <xsl:template match="del[following-sibling::add[1][@place ='superimposed']]" >
        <span class="del superimposed">
            <xsl:apply-templates />
        </span>
    </xsl:template>
        <xsl:template match="del[@rend='overtyped' and following-sibling::add[1][not(@*)]]" >
        <span class="del overtyped">
            <xsl:apply-templates />
        </span>
    </xsl:template>
        <xsl:template match="del[@rend='overwritten']" >
        <span class="del overwritten">
            <xsl:apply-templates />
        </span>
    </xsl:template> 
    
    <!-- subst -->
        <xsl:template match="subst[del and add]" >
        <span class="subst">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    
    
    <!-- tabellen  z.B. 48G-33r--> 
        <xsl:template match="text//table" >
            <xsl:apply-templates />     
    </xsl:template>
        <xsl:template match="table/row" >
        <div class="item">
            <xsl:apply-templates />
        </div>
    </xsl:template>
        <xsl:template match="cell" >
            <xsl:apply-templates /> 
        <xsl:text> </xsl:text>
    </xsl:template>
    
        <xsl:template match="label" >
        <span class="label">
            <xsl:apply-templates />
        </span>
    </xsl:template>
   
    
        <xsl:template match="seg" >         
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
                <xsl:when test="@type='add above'">
                    <xsl:attribute name="class">seg add above</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">seg</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:apply-templates />
        </span>
    </xsl:template>
   
    
        <xsl:template match="delSpan" >
        <xsl:variable name="anchorID" select="@spanTo/substring-after(.,'#')" />
        <div class="delSpan">
            <xsl:apply-templates  select="following-sibling::*[following::anchor[@xml:id=$anchorID]]" ><xsl:with-param name="param" select="."/></xsl:apply-templates>       
        </div>   
        </xsl:template> 
    
   <xsl:template match="*[preceding-sibling::delSpan][following::anchor[@xml:id=current()/preceding-sibling::delSpan/@spanTo/substring-after(.,'#')]]" priority="100" >
        <xsl:param name="param" />
      <xsl:choose>
          <xsl:when test="$param">
              <xsl:apply-templates />
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
      </xsl:choose> 
        
    </xsl:template>
 
    <!-- add -->
   
        <xsl:template match="add[@place='below'][not(ancestor::choice)][not(ancestor::subst)]" >
        <span class="add below">
            <xsl:apply-templates />
        </span>
    </xsl:template>
        <xsl:template match="add" >
      <span class="add">
          <xsl:apply-templates />
      </span>
  </xsl:template>
        <xsl:template match="add[@place='above']" >
        <span class=" add above">
            <xsl:if test="not(ancestor::subst) and not(ancestor::choice) and not(ancestor::seg)"> 
                 <xsl:attribute name="style">position:relative;</xsl:attribute>             
            </xsl:if>  
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
        <xsl:template match="add[@resp]"  />

            <xsl:template match="p" >
    <p>
        <xsl:apply-templates />
    </p>
</xsl:template>
    
            <xsl:template match="p[@rend='indent']" >
        <p style="margin-left: 2em;">
            <xsl:apply-templates />
        </p>
</xsl:template>
    
            <xsl:template match="p[@rend='text-center']" >
    <p style="text-align: center;">
        <xsl:apply-templates />
    </p>
</xsl:template>
            <xsl:template match="p[@rend='position-center']" >
     <p style="text-align: center;">
         <xsl:apply-templates />
     </p>
 </xsl:template>   

<!-- special case 87-68r-->
    <xsl:template match="text[@xml:id='bnp-e3-87-68r']//ab[@rend='right']" priority="1">
        <div class ="ab right">
            <xsl:apply-templates />
        </div><br/>
    </xsl:template>
    
  
</xsl:stylesheet>
