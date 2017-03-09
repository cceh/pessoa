<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="rs[@type='title']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="choice[abbr][expan]">
        <xsl:apply-templates select="expan"/>
    </xsl:template>
    
    <xsl:template match="choice[seg[@n='1'] and seg[@n='2']]">
        <xsl:apply-templates select="seg[@n='2']"/>
    </xsl:template>
    
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:variable name="str1" select="replace(.,'^[.“”]*(.+?)[.“”]*$','$1')" />
        <xsl:value-of select="replace($str1, '[“”]', '')" />
    </xsl:template>
    
    
</xsl:stylesheet>