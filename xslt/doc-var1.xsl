<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:import href="http://localhost:8080/exist/rest/db/apps/pessoa/xslt/doc-edited.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    
    
    <!-- choices -->
    <!-- Alternativen von Pessoa selbst 
        (etwas ist hinzugefügt, aber nichts gestrichen, die beiden Varianten schließen sich aber aus)
    hier: 1. Alternative anzeigen -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[1]/text()"/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place='above']">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[1]/text()"/>
            </span>
        </span>
    </xsl:template>
    <!-- Ergänzung von Pessoa selbst
    (alternativ: nichts  - das Hinzugefügte)
    hier: das Hinzugefügte nicht anzeigen -->
    <xsl:template match="seg/add[@n='2']"/>
    
    <!-- Ersetzung von Pessoa selbst: etwas wird gelöscht, etwas anderes hinzugefügt
    hier: Anzeigen des Gelöschten (wenn es zwei Textstufen sind) -->
    <xsl:template match="subst[del/@n and add/@n]">
        <xsl:apply-templates select="del/text()"/>
    </xsl:template>
</xsl:stylesheet>