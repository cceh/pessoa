<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:import href="doc-edited.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    
    <!-- choices -->
    <!-- Alternativen von Pessoa selbst 
        (etwas ist hinzugefügt, aber nichts gestrichen, die beiden Varianten schließen sich aber aus)
    hier: 2. Alternative anzeigen -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']" mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant">
                <xsl:apply-templates select="seg[2]/add"/><!-- war: text() -->
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place='above']" mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant" title="variant">
                <xsl:apply-templates select="seg[2]/add"/><!-- war: text() -->
            </span>
        </span>
    </xsl:template>
    
    <!-- Ergänzung von Pessoa selbst
    (alternativ: nichts  - das Hinzugefügte)
    hier: das Hinzugefügte anzeigen -->
    <xsl:template match="seg/add[@n='2']" mode="#default deletion addition">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="add[@place='above'][@n='2'][not(parent::seg)]" mode="#default deletion addition">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
    <xsl:template match="add[@place='below'][parent::seg[@n='2']]" mode="#default deletion addition">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
    <!-- Ersetzung von Pessoa selbst: etwas wird gelöscht, etwas anderes hinzugefügt
    hier: Anzeigen des Hinzugefügten -->
    <xsl:template match="subst[del and add/@n]" mode="#default deletion addition">
        <xsl:apply-templates select="add/text()"/>
    </xsl:template>
    
    
    <!-- einzublendende Spans -->
    <xsl:template match="addSpan[@n='2']">
        <xsl:variable name="anchorID" select="@spanTo/substring-after(.,'#')" />
        <xsl:apply-templates select="following-sibling::*[following::anchor[@xml:id=$anchorID]]" mode="addition" />
    </xsl:template>
    
    <!-- einzublendende Notes -->
    <!-- Notes -->
    <xsl:template match="note[@place = 'margin-right'][@n='2']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-right"/>
    </xsl:template>
    
    <xsl:template match="note[@place = 'margin-left'][@n='2']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-left"/>
    </xsl:template>
    
    
    
    
    <!-- special case MN246 -->
    <xsl:template match="text[@xml:id='mn246']//choice[seg[@n]]" mode="#default deletion addition">
                <xsl:value-of select="substring-after(seg[2],'ou')"/>  
    </xsl:template>
    
    
    
</xsl:stylesheet>