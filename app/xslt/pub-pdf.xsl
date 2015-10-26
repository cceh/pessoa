<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">
    
    <xsl:template match="/">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="poemM">
                    <fo:region-body page-height="29.7cm" page-width="21.0cm" margin-top="1.5cm" margin-bottom="1.5cm"
                    margin-left="2cm" margin-right="2cm" region-name="main"/>
                </fo:simple-page-master>
                <fo:page-sequence-master master-name="poem">
                    <fo:repeatable-page-master-reference master-reference="poemM"/>
                </fo:page-sequence-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="poem">
                <fo:flow flow-name="main" font-family="Times New Roman">
                    <fo:block><xsl:apply-templates select="//teiHeader//titleStmt/author | //teiHeader//sourceDesc | //text" /></fo:block>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>   
    
    <xsl:template match="head">
        <fo:block font-weight="bold" font-size="14pt">
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>
    
    <xsl:template name="rend">
        <xsl:choose>
            <xsl:when test="@rend='right'">
                <xsl:attribute name="text-align">right</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='center'">
                <xsl:attribute name="text-align">center</xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="lg">
        <fo:block font-size="12pt" text-align="center" margin-bottom="0.5cm" margin-top="0.5cm">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>
    
    <xsl:template match="l | dateline | signed">
        <fo:block text-align="center">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>
    
    <xsl:template match="sourceDesc">
        <fo:block-container font-size="10pt" margin-top="0.5cm" margin-bottom="1cm">
            <fo:block><xsl:value-of select=".//title[@level='j']" />, n° <xsl:value-of select=".//biblScope[@unit='issue']" />, <xsl:value-of select=".//imprint/date" />, p<xsl:if test="contains(.//biblScope[@unit='page'], '-')">p</xsl:if>. <xsl:value-of select=".//biblScope[@unit='page']" /></fo:block>
        </fo:block-container>
    </xsl:template>
    
</xsl:stylesheet>