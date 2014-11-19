<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="teiHeader">
        <h2>
            <xsl:choose>
                <xsl:when test="//msIdentifier/idno/substring-after(., 'BNP/E3 ')">
                    <xsl:value-of select="//msIdentifier/idno/substring-after(., 'BNP/E3 ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="//titleStmt/title"/>
                </xsl:otherwise>
            </xsl:choose>
        </h2>
        <xsl:choose>
            <xsl:when test="//origin//origDate">
                <p>
                    <xsl:value-of select="//origin//origDate"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:value-of select="//imprint/date/@when"/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="//teiCorpus/TEI/text/group or //teiCorpus/TEI/text[not(group)]">
            <xsl:call-template name="group"/>
        </xsl:if>
    </xsl:template>
    <!-- Gruppen -->
    <xsl:template name="group">
        <!--<ul>-->
        <xsl:for-each select="//teiCorpus/TEI/text/group/text | //teiCorpus/TEI/text[not(group)]">
                <!--<li>-->
            <a href="#{@xml:id}">
                <xsl:value-of select=".//head"/>
            </a>
                <!--</li>-->
        </xsl:for-each>
        <!--</ul>-->
    </xsl:template>
    <xsl:template match="text">
        <div>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- Textstruktur -->
    <xsl:template match="head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <xsl:template match="list">
       <!-- <ol style="list-style-type: none;">-->
        <xsl:apply-templates/>
        <!--     </ol>-->
    </xsl:template>
    <xsl:template match="item">
        <!--<li>-->
        <div>
            <xsl:value-of select="label"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </div>
            <!--</li>-->
    </xsl:template>
    <xsl:template match="lg">
        <div class="lg app:highlight-matches?sel=text">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="l">
        <xsl:apply-templates/>
        <br/>
    </xsl:template>
    <xsl:template match="lb">
        <br/>
    </xsl:template>
    <xsl:template match="label"/>
    <xsl:template match="hi[@rend='underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='superscript']">
        <span style="position:relative;top:-4px;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="metamark[@rend='line']">
        _______
    </xsl:template>
    <xsl:template match="expan"/>
</xsl:stylesheet>