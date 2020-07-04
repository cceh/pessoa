<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <xsl:for-each select="collection('../../data/pre1913')//TEI">
            <!--<xsl:value-of select="tokenize(base-uri(.),'/')[last()]"/>-->
            <!--<xsl:value-of select=".//titleStmt/title/normalize-space(.)"/>-->
            <xsl:value-of select=".//availability/@status"/>
            <!--<xsl:text>0</xsl:text>-->
            <xsl:if test="position() != last()">
                <xsl:text>
</xsl:text>
            </xsl:if>
        </xsl:for-each> 
        
        <!--<xsl:value-of select="count(collection('../../data/doc')//TEI)"/>-->
    </xsl:template>
    
    
</xsl:stylesheet>