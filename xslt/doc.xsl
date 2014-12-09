<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    <xsl:template match="/">
        <style type="text/css">
            h3 {margin-bottom: 5px;}
            div.text {display: inline-block; position: relative;}
            div.text.bnp-e3-180r {margin: 10px 130px;}
            .item {margin: 10px 0; position: relative;}
            .list .item .list .item {margin-left: 2em;}
            .ab {display: inline-block;}
            .ab.right {float: right;}
            .seg {position: relative;}
            
            .choice {position: relative;}
            .choice .add.below {position: absolute; top: 1em; left: 0; font-size: smaller;}
            .choice .add.above {position: absolute; top: -0.8em; left: 0; font-size: smaller;}
            
            .subst {position: relative;}
            .subst .add.above {position: absolute; top: -0.5em; left: 0; font-size: smaller;}
            .seg .add.above {position: absolute; top: -0.5em; left: 0; font-size: smaller; white-space: nowrap;}
            .add {top: 0;}
            
            .note.addition {position: absolute;}
            .note.addition.margin.top.right {top: 20px; right: -100px; font-size: smaller;}
            .bnp-e3-180r.note.addition.margin.left {left: -130px; font-size: smaller; vertical-align: middle; display: inline-block; width: 130px; text-align: right;}
            .bnp-e3-180r.note.addition.margin.right {right: -140px; font-size: smaller; vartical-align: middle; display: inline-block; width: 130px;}
            .note, .note .label, .note .metamark {vertical-align: middle;}
            
            /* special case 180r */
            .bnp-e3-180r.note.addition.margin.left .label {text-align: left;}
            .bnp-e3-180r.note.addition.margin.left .metamark {text-align: right;}
            .bnp-e3-180r.note.addition.margin.left.r1-3 {top: 70px;}
            .bnp-e3-180r.note.addition.margin.left.r4-6 {top: 240px;}
            .bnp-e3-180r.note.addition.margin.right.r1 {top: 80px;}
            .bnp-e3-180r.note.addition.margin.right.r2-3 {top: 140px;}
            .bnp-e3-180r.note.addition.margin.right.r4-5 {top: 250px;}
            .bnp-e3-180r.note.addition.margin.right.r6 {top: 330px;}
            .bnp-e3-180r.r1-3 .metamark.curly-bracket.left, .bnp-e3-180r.r4-6 .metamark.curly-bracket.left {font-size: 90pt;}
            .bnp-e3-180r.r2-3 .metamark.curly-bracket.right, .bnp-e3-180r.r4-5 .metamark.curly-bracket.right {font-size: 50pt;}
            .bnp-e3-180r.r6 .metamark.bracket.right {font-size: 32pt;}
            .text.edited .note.addition {position: relative; display: block;}
            
            
            .del {text-decoration: line-through;}
            .gap {cursor: pointer;}
            .supplied {cursor: pointer;}
            .metamark {cursor: pointer;}
            
            /* special case 180r */
            .bnp-e3-180r.metamark.curly-bracket.left, .metamark.bracket.left {margin-left: 5px; text-align: right;}
            .bnp-e3-180r.metamark.curly-bracket.right, .metamark.bracket.right {margin-right: 5px; text-align: left;}
            
            .offset {margin-left: 2em;}
            .indent {margin-left: 2em;}
            .right {text-align: right;}
        </style>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Header & Text -->
    <xsl:template match="teiHeader">
        <h2>
            <xsl:apply-templates select="//titleStmt/title"/>
        </h2>
        <p>
            <xsl:value-of select="//origin//origDate"/>
        </p>
    </xsl:template>
    <xsl:template match="text">
        <div class="text">
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Textstruktur -->
    <xsl:template match="head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <xsl:template match="list/head">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="list">
        <div class="list">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="item">
        <div class="item">
            <xsl:apply-templates/>
        </div>
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
                <xsl:otherwise>
                    <xsl:attribute name="class">seg</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="note[@type='addition'][@place='margin top right']">
        <span class="note addition margin top right">
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
    <xsl:template match="note[@type='addition'][@place='margin right']">´
        <xsl:variable name="range">
            <xsl:choose>
                <xsl:when test="@target = 'i1'">r1</xsl:when>
                <xsl:when test="@target = 'range(i2,i3)'">r2-3</xsl:when>
                <xsl:when test="@target = 'range(i4,i5)'">r4-5</xsl:when>
                <xsl:when test="@target = 'i6'">r6</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <span class="note addition margin right {ancestor::text/@xml:id} {$range}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
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
        <span style="position:relative;top:-4px; font-size: smaller;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="label">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- hier nicht weiter zu berücksichtigen -->
    <xsl:template match="expan"/>
    <xsl:template match="add[@resp]"/>
    <xsl:template match="supplied"/>
    
    
    <!-- metamarks -->
    <xsl:template match="metamark[@function='end'][@rend='line']">
        <div class="metamark line end" title="end">___________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='ditto']">
        <span class="metamark line ditto" title="ditto">_______</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='distinct']">
        <div class="metamark line distinct" title="distinct">______________________________________</div>
    </xsl:template>
    <xsl:template match="metamark[@rend='curly bracket'][@function='grouping'][parent::note/contains(@place, 'margin left')]">
        <span class="metamark curly-bracket grouping left {ancestor::text/@xml:id}" title="grouping">{</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='curly bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]">
        <span class="metamark curly-bracket grouping right {ancestor::text/@xml:id}" title="grouping">}</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='bracket'][@function='grouping'][parent::note/contains(@place, 'margin left')]">
        <span class="metamark bracket grouping left {ancestor::text/@xml:id}" title="grouping">[</span>
    </xsl:template>
    <xsl:template match="metamark[@rend='bracket'][@function='grouping'][parent::note/contains(@place, 'margin right')]">
        <span class="metamark bracket grouping right {ancestor::text/@xml:id}" title="grouping">]</span>
    </xsl:template>
    
    <!-- choices -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[1]"/>
            </span>
            <span class="add below">
                <xsl:apply-templates select="seg[2]/add"/>
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
    
    <!-- subst -->
    <xsl:template match="subst[del and add/@place='above'] | subst[del and add]">
        <span class="subst">
            <span class="del">
                <xsl:apply-templates select="del/text()"/>
            </span>
            <span class="add above">
                <xsl:apply-templates select="add/text()"/>
            </span>
        </span>
    </xsl:template>
    
    <!-- add -->
    <xsl:template match="add[@place='above']">
        <span class="add above">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Personen, Orte, etc. -->
    <xsl:template match="rs[@type='person']">
        <span class="person">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='place']">
        <span class="place">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='journal']">
        <span class="journal">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='work']">
        <span class="work">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="rs[@type='work-part']">
        <span class="work-part">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>