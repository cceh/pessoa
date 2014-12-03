<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:import href="http://papyri.uni-koeln.de:8080/rest/db/apps/pessoa/xslt/doc.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    
    
    <!-- choices -->
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
    <xsl:template match="add[@n='2']"/>
    <xsl:template match="subst[del/@n and add/@n]">
        <xsl:apply-templates select="del/text()"/>
    </xsl:template>
</xsl:stylesheet>