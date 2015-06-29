<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="/">
        <div>
            <style type="text/css">
                .lg {margin: 15px 0;}
                h2.center {text-align: center;}
                div.poem {margin: 20px 0;}
            </style>
            <xsl:apply-templates select="//teiHeader//titleStmt/author | //text" />
        </div>
    </xsl:template>
    
    <xsl:template match="head">
        <h2>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </h2>
    </xsl:template>
    
    <xsl:template name="rend">
        <xsl:choose>
            <xsl:when test="@rend='right'">
                <xsl:attribute name="class">right</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='center'">
                <xsl:attribute name="class">center</xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@type='poem']">
        <div class="poem" id="">
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="lg">
        <div class="lg">
            <xsl:apply-templates />
        </div>
    </xsl:template>
    
    <xsl:template match="l">
        <xsl:apply-templates /><br />
    </xsl:template>
    
    <xsl:template match="dateline">
        <p class="dateline"><xsl:apply-templates /></p>
    </xsl:template>
    
    <xsl:template match="signed">
        <p class="signed"><xsl:apply-templates /></p>
    </xsl:template>
    
</xsl:stylesheet>