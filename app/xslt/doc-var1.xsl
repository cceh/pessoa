<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:import href="doc-edited.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    
    <!-- choices -->
    <!-- Alternativen von Pessoa selbst 
        (etwas ist hinzugefügt, aber nichts gestrichen, die beiden Varianten schließen sich aber aus)
    hier: 1. Alternative anzeigen -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']" mode="#default deletion">
        <span class="choice">
            <span class="seg variant" title="variant">
                <xsl:apply-templates select="seg[1]/text()"/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place='above']" mode="#default deletion">
        <span class="choice">
            <span class="seg variant">
                <xsl:apply-templates select="seg[1]/text()"/>
            </span>
        </span>
    </xsl:template>
    <!-- Ergänzung von Pessoa selbst
    (alternativ: nichts  - das Hinzugefügte)
    hier: das Hinzugefügte nicht anzeigen 
    <xsl:template match="seg/add[@n='2']"/> -->
    
    <!-- Ersetzung von Pessoa selbst: etwas wird gelöscht, etwas anderes hinzugefügt
    hier: Anzeigen des Gelöschten (wenn es zwei Textstufen sind) -->
    <xsl:template match="subst[del/@n and add/@n]" mode="#default deletion">
        <xsl:apply-templates select="del/text()"/>
    </xsl:template>
    
    <xsl:template match="*[@n='2']" mode="#default deletion"/>
        
    
    
    <!-- special case MN246 -->
    <xsl:template match="text[@xml:id='mn246']//choice[seg[@n]]" mode="#default deletion">
        <xsl:value-of select="seg[1]"/>       
    </xsl:template>
    
   
</xsl:stylesheet>