<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:for-each select="collection('../../data/pub')">
            <xsl:if test=".//titlePage">
                <xsl:value-of select=".//idno[@type='filename']"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>