<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:text>ficheiro,aspas</xsl:text>
        <xsl:text>
            
</xsl:text>
        <xsl:for-each select="collection('../../data/pub')//tei:TEI">
            <xsl:if test="contains(.//tei:text[@type='orig'],'&quot;')">
                <xsl:value-of select=".//tei:idno[@type='filename']"/>
                <xsl:text>,duplos
</xsl:text>
            </xsl:if>
            <xsl:if test='contains(.//tei:text[@type="orig"],"&#39;")'>
                <xsl:value-of select=".//tei:idno[@type='filename']"/>
                <xsl:text>,simples
</xsl:text>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
    
    
</xsl:stylesheet>