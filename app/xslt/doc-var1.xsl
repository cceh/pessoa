<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">

    <!-- Authors: Ulrike Henny-Krahmer, Alena Geduldig -->

    <xsl:import href="doc-edited.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>

    <xsl:template match="text" mode="#default deletion addition">
        <div class="text first" id="{//idno[@type='filename']/substring-before(.,'.')}">
            <xsl:apply-templates/>
        </div>
        <xsl:apply-templates select="//summary"/>
    </xsl:template>

    <!-- Choices -->
    <!-- Alternativen von Pessoa selbst 
        (etwas ist hinzugefügt, aber nichts gestrichen, die beiden Varianten schließen sich aber aus)
    hier: 1. Alternative anzeigen -->
    <xsl:template match="choice[seg and seg[2]/add/@place = 'below']"
        mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant" title="variant">
                <xsl:apply-templates select="seg[1]"/>
                <!-- war: seg[1]/text() -->
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place = 'above']"
        mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant">
                <xsl:apply-templates select="seg[1]"/>
                <!-- war: seg[1]/text() -->
            </span>
        </span>
    </xsl:template>


    <!-- Notes -->

    <xsl:template match="note[@place = 'margin-right'][@n = '2']" mode="#default deletion addition"
        priority="2"> </xsl:template>

    <xsl:template match="note[@place = 'margin-left'][@n = '2']" mode="#default deletion addition"
        priority="2"> </xsl:template>

    <!-- addSpan -->
    <xsl:template match="addSpan[@n = '2']" mode="#default deletion addition"/>

    <!-- add -->
    <xsl:template match="add[@n = '2']" mode="#default deletion addition"/>

    <xsl:template match="mod[@n = '2']" mode="#default deletion addition">
        <span class="mod">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Ergänzung von Pessoa selbst
    (alternativ: nichts  - das Hinzugefügte)
    hier: das Hinzugefügte nicht anzeigen 
    <xsl:template match="seg/add[@n='2']"/> -->
    
    <!-- Tilgung von Pessoa selbst. Anzeigen des Gelöschten (wenn es mehrere Textstufen gibt) -->
    <xsl:template match="del[not(parent::subst)][@n]" mode="#default deletion addition">
        <xsl:apply-templates select="text() | child::*"/>
    </xsl:template>

    <!-- Ersetzung von Pessoa selbst: etwas wird gelöscht, etwas anderes hinzugefügt
    hier: Anzeigen des Gelöschten (wenn es zwei Textstufen sind) -->
    <xsl:template match="subst[del/@n and add/@n]" mode="#default deletion addition">
        <xsl:apply-templates select="del/text()"/>
    </xsl:template>


    <xsl:template match="note[@type = 'addition'][@n = '2'] | note[@n = '2']"
        mode="#default deletion addition"/>



    <!-- metamarks -->
    <xsl:template match="metamark[@n = '2']" mode="#default deletion addition"/>
    
    
    
    <!-- do not display anchors of arrows added in the 2nd version: -->
    <xsl:template match="anchor[@xml:id=preceding::metamark[@rend='arrow-down'][@n='2']/@target/substring-after(.,'#') or @xml:id=following::metamark[@rend='arrow-down'][@n='2']/@target/substring-after(.,'#')]" mode="#default deletion addition" priority="1"/>
        
    
    <xsl:template match="anchor[@xml:id=preceding::metamark[@rend='arrow-right-curved-up'][@n='2']/@target/substring-after(.,'#') or @xml:id=following::metamark[@rend='arrow-right-curved-up'][@n='2']/@target/substring-after(.,'#')]" mode="#default deletion addition" priority="1"/>
        
    
    <xsl:template match="anchor[@xml:id=preceding::metamark[@rend='arrow-right-curved-down'][@n='2']/@target/substring-after(.,'#') or @xml:id=following::metamark[@rend='arrow-right-curved-down'][@n='2']/@target/substring-after(.,'#')]" mode="#default deletion addition" priority="1"/>
        
    

</xsl:stylesheet>
