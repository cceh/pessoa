<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">
    
    <xsl:template match="/">
        <!--<xsl:for-each select="//text[@xml:lang='en']">
            <xsl:for-each select=".//p | .//head | .//item">
                <xsl:text>
                    
                </xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            </xsl:for-each>
        </xsl:for-each>-->
        
        <xsl:for-each select="//term[@xml:lang='en']">
                <xsl:text>
                    
                </xsl:text>
                <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>