<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:template match="node() | @* | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="list[@type='works']">
        <list type="works">
            <xsl:for-each select="item">
                <item>
                    <xsl:copy-of select="@xml:id"/>
                    <xsl:variable name="title-key" select="ptr[@type='title']/substring-after(@target,'#')"/>
                    <xsl:variable name="title-string" select="//list[@type='titles']/item[@xml:id=$title-key]/title"/>
                    <xsl:variable name="author-key" select="ptr[@type='author']/substring-after(@target,'#')"/>
                    <xsl:variable name="author-string" select="//person[@xml:id=$author-key]/persName"/>
                    <title key="{$title-key}"><xsl:value-of select="$title-string"/></title>
                    <name type="author" key="{$author-key}"><xsl:value-of select="$author-string"/></name>
                </item>
            </xsl:for-each>
        </list>
    </xsl:template>
    
    
</xsl:stylesheet>