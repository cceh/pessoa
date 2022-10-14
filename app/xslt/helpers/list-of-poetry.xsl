<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output method="text"/>
    <xsl:template match="/">
        <xsl:for-each select="collection('../../data/pub')//TEI">
            <xsl:sort select="//titleStmt/title"/>
            <xsl:if test="contains(.//note[@type='genre'],'Poesia')">
                <xsl:value-of select="//titleStmt/title"/>
                <xsl:text>
</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>