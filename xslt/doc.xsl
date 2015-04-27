<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    <xsl:strip-space elements="rs"/>
    <xsl:template match="/">
        <style type="text/css">
            .text h3, .text.edited h3 {margin-bottom: 5px;}
            .text h2, .text.edited h3 {margin-bottom: 20px; text-align: left;}
            div.text {display: inline-block; position: relative; }
       
            
            
            .head.text{margin-left: 5px;}
            
            .delSpan{background: -webkit-canvas(lines);  }
           
            .item {margin: 15px 0; position: relative;}
            .item .label {padding-right: 1em;display: inline-table;}
            .list .item .list .item {margin-left: 2em;}
          
            .ab {display: inline-block;}
            .ab.right {float: right;}
            .seg {position: relative;}
            
            .choice {position: relative;}
            .choice .add.below {position: absolute; top: 1.5em; left: 0; font-size: small;}
            .choice .add.above {position: absolute; top: -0.8em; left: 0; font-size: small;}
            
            .subst {position: relative;}
            .subst .add.above {position: absolute; top: -1em; left: 0; font-size: small; width: 200px;}
            .seg .add.above {position: absolute; top: -0.3em; left: 0; font-size: small; white-space: nowrap; line-height: 0.9em;}
            .seg .add.below {position: absolute; top: 1.5em; left: 0; font-size: small; white-space: nowrap; line-height: 0.9em;}
            
            .add {top: 0;}
            
           
      
            .seg.variant {color: #47C285;}
            .above { position: relative; top: -0.8em; left: 0; font-size: small;}
            
            .note.margin.left {left: -60px; vertical-align: middle; display: inline-block; width: 130px; text-align: right; position: absolute;}
            .note.addition {position: absolute; font-size: small;}
           
            .note.addition.margin.top.right {top: 20px; right: -100px; vertical-align: middle; display: inline-block; width: 130px; text-align: right; font-size:small;}
            .note.addition.margin.left {left: -140px; vertical-align: middle; display: inline-block; width: 130px; text-align: right;}
            .note.addition.margin.right {right: -140px;  vertical-align: middle; display: inline-block; width: 130px;}
            .note, .note .label, .note .metamark {vertical-align: middle;}
          
            /* special case 180r */
           
            .note.addition.margin.left .label {text-align: left; padding:0px;}
            .note.addition.margin.left .metamark {text-align: right;}
            .note.addition.margin.left.r1-3 {top: 70px;}
            .note.addition.margin.left.r4-6 {top: 240px;}
            .note.addition.margin.right.r1 {top: 80px;}
            .note.addition.margin.right.r2-3 {top: 140px;}
            .note.addition.margin.right.r4-5 {top: 250px;}
            .note.addition.margin.right.r6 {top: 330px;}
            .r1-3 .metamark.curly-bracket.left, .r4-6 .metamark.curly-bracket.left {font-size: 90pt;}
            .r2-3 .metamark.curly-bracket.right, .r4-5 .metamark.curly-bracket.right {font-size: 50pt;}
            .r6 .metamark.bracket.right {font-size: 32pt;}
            .text.edited .note.addition {position: relative; display: block;}
            
            .metamark.line {margin: 2em;}
            
            
            .del {text-decoration: line-through;}
            .gap {cursor: pointer;}
            .supplied {cursor: pointer;}
            .metamark {cursor: pointer;}
            .ex, .supplied {color: purple;}
            
            /* special case 180r */
            .metamark.curly-bracket.left, .metamark.bracket.left {margin-left: 5px; text-align: right;}
            .metamark.curly-bracket.right, .metamark.bracket.right {margin-right: 5px; text-align: left;}
            
            .offset {margin-left: 2em;}
            .indent {margin-left: 2em;}
            .right {float: right;}
            .italic {font-style: italic;}
     

        </style>
        <xsl:apply-templates/>
       
    </xsl:template>

 
                
    
    
    <!-- Header & Text -->
    <xsl:template match="teiHeader" />
    <xsl:template match="text">
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
   
   
    <!-- Textstruktur -->
    <xsl:template match="head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
   
    
   
    <xsl:template match="list/head">
        <xsl:choose>
            <xsl:when test="name(../preceding-sibling::node()[1])='label' and name(../parent::node())='item'">
                <h3 style="display:inline;">
                    <xsl:apply-templates/>
                </h3>  
            </xsl:when>
            <xsl:otherwise>
                <h3>
                    <xsl:apply-templates/>
                </h3> 
            </xsl:otherwise>
        </xsl:choose>      
    </xsl:template>
    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="name(preceding-sibling::node()[1])='label' and name(..)='item'">
                <div class="list" style="display: inline;">  
                    <xsl:apply-templates/>
                </div>    
            </xsl:when>
            <xsl:otherwise>
                <div class="list">  
                    <xsl:apply-templates/>
                </div>  
            </xsl:otherwise>
        </xsl:choose>
                    
    </xsl:template>
    <xsl:template match="item">
        <div class="item" style="position: relative;">
            <xsl:if test="@xml:id">
                <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
            </xsl:if>
           <!--<xsl:choose>
                <xsl:when test="child::label">
                    <xsl:apply-templates select="label"/>
                    <div style="display: inline-table">
                        <xsl:apply-templates select="label/following-sibling::*"/>
                    </div>
                </xsl:when>
                <xsl:otherwise> -->
                    <xsl:apply-templates/>
              <!--  </xsl:otherwise>
            </xsl:choose> -->

        </div>
    </xsl:template>
    
    <!-- tabellen  z.B. 48G-33r--> 
    <xsl:template match="text//table">
            <xsl:apply-templates/>     
    </xsl:template>
    <xsl:template match="table/row">
        <div class="item">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="cell">
                <xsl:apply-templates/> 
        <xsl:text> </xsl:text>
    </xsl:template>
        <xsl:template match="label">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
   

 
    <!-- Einrückungen / Ausrichtungen berücksichtigen -->
    <xsl:template match="hi[@rend='indent']">
        <span class="indent">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ab[@rend='offset']">
        <span class="ab offset">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ab[@rend='indent']">
        <span class="ab indent">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ab[@rend='right']">
        <span class="ab right">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="seg">         
        <span>
            <xsl:choose>
                <xsl:when test="@rend='indent'">
                    <xsl:attribute name="class">seg indent</xsl:attribute>    
                </xsl:when>
                <xsl:when test="@rend='right'">
                    <xsl:attribute name="class">seg right</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">seg</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
   
 <!--  <xsl:template match="span[@rend='indent'][@to]">
       <xsl:variable name="anchorID" select="@to/substring-after(.,'#')" />
       <span class="span indent {$anchorID}">
           <xsl:apply-templates select="following::*[following::anchor[@xml:id=$anchorID][preceding::span[@to=$anchorID]]]"/>          
       </span>
   </xsl:template> -->
    
    
    
    <!-- zusätzliche Bemerkungen am Rand -->
  
    <xsl:template match="note[@type='addition'][@place='margin top right']">
        <span class="note addition margin top right">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="note[@type='addition'][@place='right']">
        <span class="note addition right">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="note[not(@type)][@place='margin left']">
        <span class="note margin left">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="note[@type='addition'][@place='margin left']">
        <xsl:variable name="range">
            <xsl:choose>
                <xsl:when test="@target = 'range(i1,i3)'">r1-3</xsl:when>
                <xsl:when test="@target = 'range(i4,i6)'">r4-6</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <span class="note addition margin left {ancestor::text/@xml:id} {$range}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="note[@type='addition'][@place='margin right']">
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
        <span class="note addition margin right target-{$target}" style="position: absolute; right: -100px;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    

 
    
    <!-- Zeilenumbrüche anzeigen -->
    <xsl:template match="lb">
        <br/>
    </xsl:template>
    
    <!-- Hervorhebungen -->
    <xsl:template match="hi[@rend='underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='superscript']">
        <span style="position:relative;top:-4px; font-size: small;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='red']">
        <span style="color: red;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='underline red']">
        <span style="text-decoration: underline; color: red;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    

    
    <!-- editorische Ergänzungen nicht anzeigen -->
    <xsl:template match="supplied"/>
    
    
    <!-- metamarks -->
    
    <xsl:template match="metamark[@rend='short line center'][@function='distinct']">
        <div class="metamark short line center distinct" style="margin: 2em; text-align:center;">_________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='assignment']">
        <div class="metamark line assignment" style="display: inline;">________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='curly bracket'][@function='assignment'][parent::note[@place='right']]">
        <div class="metamark curly-bracket right assignment" style="font-size: 32pt; font-family: Times; display: inline; margin-left:1em;">}</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='quotes'][@function='ditto']">
        <div class="metamark quotes ditto" title="ditto" style="display: inline; padding-left: 15px; padding-right: 15px;"> " </div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@place='left']">
        <!--TODO-->
    </xsl:template>
    <xsl:template match="metamark[@rend='arrow'][@function='move']">
        <xsl:variable name="target" select="@target/substring-after(.,'#')"/>
        <!--TODO-->
    </xsl:template>
    
    <xsl:template match="metamark[@function='end'][@rend='line']">
        <div class="metamark line end" title="end">___________</div>
    </xsl:template>
    <xsl:template match="metamark[@function='end'][@rend='short line center']">
        <div class="metamark line end" style="text-align:center;">___________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='ditto']">
        <span class="metamark line ditto" title="ditto">_______</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='distinct']">
        <xsl:choose>
            <xsl:when test="label[@rend='right']">
                <xsl:variable name="label" select="label/data(.)"/>
                <div class="metamark line distinct" title="distinct">______________________________________<xsl:value-of select="$label"/></div> 
            </xsl:when>
            <xsl:otherwise>
                <div class="metamark line distinct" title="distinct">______________________________________</div>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='highlight']">
        <div class="metamark line highlight" sytle="margin: 0.5em;">______________________________________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='underline'][@function='distinct']">
        <div class="metamark line distinct" title="distinct">______________________________________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='double line'][@function='distinct']">
        <div class="metamark line distinct" title="distinct">
            ______________________________________<br/>
            ______________________________________
        </div>
    </xsl:template>
    <xsl:template match="metamark[@rend='curly bracket'][@function='grouping'][parent::note/contains(@place, 'margin left')]">
        <span class="metamark curly-bracket grouping left {ancestor::text/@xml:id}" title="grouping" style="font-size: 32pt; font-family: Times">{</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='curly bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]">
        <span class="metamark curly-bracket grouping right {ancestor::text/@xml:id}" title="grouping" style="font-size: 32pt; font-family: Times">}</span>
    </xsl:template>
    <xsl:template match="metamark[@rend ='curly bracket'][@function='grouping'][@place='margin right']">
        <span class="metamark curly-bracket grouping right {ancestor::text/@xml:id}" title="grouping" style="font-size: 32pt; font-family: Times; position: absolute; right: -140px; top:45px;">}</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='bracket'][@function='grouping'][parent::note/contains(@place, 'margin left')]">
        <span class="metamark bracket grouping left {ancestor::text/@xml:id}" title="grouping" style="font-size: 32pt; font-family: Times">[</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]">
        <span class="metamark bracket grouping right {ancestor::text/@xml:id}" title="grouping" style="font-size: 32pt; font-family: Times">]</span>
    </xsl:template>
    
    <!-- choices -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[1]"/>
            </span>
            <span class="add below">
                <xsl:apply-templates select="seg[2]/add/text()"/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[abbr/gap and expan[@resp]]">
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
    <xsl:template match="choice[seg and seg[2]/add/@place='above']">
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
    <xsl:template match="expan" />
    
    <!-- gaps -->
    <xsl:template match="gap[@reason='selection']">
        <span class="gap" title="selection">[...]</span>
    </xsl:template>
   
    <!-- del -->
    <xsl:template match="del[gap]">
        <span class="del">
            [<xsl:value-of select="for $c in (1 to gap/@quantity) return '?'"/>]
        </span>
    </xsl:template>
    <xsl:template match="del">
        <span class="del">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="del[following-sibling::add[1][@place ='superimposed']]">
        <span class="del superimposed">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="del[@rend='overtyped' and following-sibling::add[1][not(@*)]]">
        <span class="del overtyped">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="del[@rend='overwritten']">
        <span class="del overwritten">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
   
    
    <xsl:template match="delSpan">
        <xsl:variable name="anchorID" select="@spanTo/substring-after(.,'#')" />
        <div class="delSpan">
            <xsl:apply-templates select="following-sibling::*[following::anchor[@xml:id=$anchorID]]">
                <xsl:with-param name="test"/>
            </xsl:apply-templates>
        </div>
        </xsl:template> 

    

   
   
    
    <!-- subst -->
    <xsl:template match="subst[del and add/@place] | subst[del and add]">
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
    <xsl:template match="add[@place='above'][not(ancestor::choice)]">
        <span class="add above">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="add[@place='below'][not(ancestor::choice)]">
        <span class="add below">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
  <xsl:template match="add">
      <span class="add">
          <xsl:apply-templates/>
      </span>
  </xsl:template>
    
    <xsl:template match="add[@resp]" />

    
    <!-- Personen, Orte, etc. -->
    <xsl:template match="rs[@type='person']">
        <span class="person {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='place']">
        <span class="place {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='journal']">
        <span class="journal {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='work']">
        <span class="work {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="rs[@type='text']">
        <span class="text {@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="p">
    <p>
        <xsl:apply-templates/>
    </p>
</xsl:template>
    
    <xsl:template match="p[@rend='indent']">
        <p class="p indent">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
<xsl:template match="p[@rend='text-center']">
    <p style="text-align: center;">
        <xsl:apply-templates/>
    </p>
</xsl:template>
 <xsl:template match="p[@rend='position-center']">
     <p style="text-align: center;">
         <xsl:apply-templates/>
     </p>
 </xsl:template>   

<xsl:template match="note[@resp]">
    <div class="editorial note">
        <xsl:apply-templates/>
    </div>
</xsl:template>
    <xsl:template match="hi[@rend='italic']">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

  
  
</xsl:stylesheet>