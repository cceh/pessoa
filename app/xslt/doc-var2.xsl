<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <!-- Authors: Ulrike Henny-Krahmer, Alena Geduldig -->

    <xsl:import href="doc-edited.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>

    <xsl:template match="text" mode="#default deletion addition">
        <div class="text last" id="{//idno[@type='filename']/substring-before(.,'.')}">
            <xsl:apply-templates/>
        </div>
        <xsl:apply-templates select="//summary"/>
    </xsl:template>

    <!-- choices -->
    <!-- Alternativen von Pessoa selbst 
        (etwas ist hinzugefügt, aber nichts gestrichen, die beiden Varianten schließen sich aber aus)
    hier: 2. Alternative anzeigen -->
    <xsl:template match="choice[seg and seg[2]/add/@place = 'below']"
        mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant">
                <xsl:apply-templates select="seg[2]/add"/>
                <!-- war: text() -->
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place = 'above']"
        mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant" title="variant">
                <xsl:apply-templates select="seg[2]/add"/>
                <!-- war: text() -->
            </span>
        </span>
    </xsl:template>

    <!-- Ergänzung von Pessoa selbst
    (alternativ: nichts  - das Hinzugefügte)
    hier: das Hinzugefügte anzeigen -->
    
    
    <xsl:template match="seg/add[@n = '2']" mode="#default deletion addition">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template
        match="add[@place = 'above'][@n = '2'][not(parent::seg)] | add[@place = 'above'][parent::seg[@n = '2']]"
        mode="#default deletion addition">
        <xsl:apply-templates select="text() | child::*"/>
    </xsl:template>

    <xsl:template match="add[@place = 'below'][parent::seg[@n = '2']]"
        mode="#default deletion addition">
        <xsl:apply-templates select="text() | child::*"/>
    </xsl:template>


    <!-- Gelöschtes, das nur in der ersten Version ist, hier nicht anzeigen -->
    <xsl:template match="del[@n='1']" mode="#default deletion addition"/>

    <!-- Ersetzung von Pessoa selbst: etwas wird gelöscht, etwas anderes hinzugefügt
    hier: Anzeigen des Hinzugefügten -->
    <xsl:template match="subst[del and add/@n]" mode="#default deletion addition">
        <xsl:apply-templates select="add/text() | add/child::*"/>
    </xsl:template>


    <!-- einzublendende Spans -->
    <xsl:template match="addSpan[@n = '2']">
        <xsl:variable name="anchorID" select="@spanTo/substring-after(., '#')"/>
        <xsl:apply-templates select="following-sibling::*[following::anchor[@xml:id = $anchorID]]"
            mode="addition"/>
    </xsl:template>

    <!-- einzublendende Notes -->
    <!-- Notes -->
    <xsl:template match="note[@place = 'margin-right'][@n = '2']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-right"/>
    </xsl:template>

    <xsl:template match="note[@place = 'margin-left'][@n = '2']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-left"/>
    </xsl:template>
    
    <!-- transpositions -->
    <xsl:template match="metamark[@function='transposition'][@n='2']" mode="#default deletion addition">
        <xsl:variable name="target" select="@target"/>
        <xsl:variable name="target-1" select="following-sibling::*[@xml:id=substring-after(substring-before($target,' '),'#')]"/>
        <xsl:variable name="target-2" select="following-sibling::*[@xml:id=substring-after(substring-after($target,' '),'#')]"/>
        <xsl:variable name="between-targets" select="$target-1/following-sibling::*[following-sibling::*[@xml:id=substring-after(substring-after($target,' '),'#')]]"/>
        
        <xsl:apply-templates select="$target-2" mode="addition"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="$between-targets" mode="addition"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="$target-1" mode="addition"/>
    </xsl:template>
    
    <xsl:template match="*[concat('#',@xml:id)=preceding-sibling::metamark[@function='transposition']/@target/tokenize(.,'\s')]" mode="#default" priority="100"/>
    <xsl:template match="*[preceding-sibling::*[@xml:id=preceding-sibling::metamark[@function='transposition']/@target/substring-after(substring-before(.,' '),'#')]][following-sibling::*[@xml:id=preceding-sibling::metamark[@function='transposition']/@target/substring-after(substring-after(.,' '),'#')]]" mode="#default" priority="100"/>
    
</xsl:stylesheet>
