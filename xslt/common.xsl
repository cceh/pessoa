<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:template match="/">
        <style type="text/css">
            .item {margin: 10px 0; position: relative;}
            .subst {position: relative;}
            .del {text-decoration: line-through;}
            .subst .add.above {position: absolute; top: -0.8em; left: 0; font-size: smaller;}
            .add.above {position: relative; top: -0.8em; font-size: smaller;}
        </style>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="teiHeader">
        <h2>
            <xsl:value-of select="//msIdentifier/idno/substring-after(., 'BNP/E3 ')"/>
        </h2>
        <p>
            <xsl:value-of select="//origin//origDate"/>
        </p>
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
    <xsl:template match="list/head">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="list">
        <div class="list">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="item">
        <div class="item">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="lb">
        <br/>
    </xsl:template>
    
    <!-- Hervorhebungen -->
    <xsl:template match="hi[@rend='underline']">
        <span style="text-decoration: underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='superscript']">
        <span style="position:relative;top:-4px; font-size: smaller;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='ditto']">
        _______
    </xsl:template>
    <xsl:template match="metamark[@rend='line'][@function='distinct']">
        ______________________________________
    </xsl:template>
    
    <!-- Ersetzungen, Löschungen, Hinzufügungen von Pessoa -->
    <xsl:template match="subst[del][add]">
        <span class="subst">
            <span class="del">
                <xsl:apply-templates select="del"/>
            </span>
            <span class="add above">
                <xsl:apply-templates select="add"/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="add[not(@resp)]">
        <span class="add above">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="del[gap]">
        <span class="del">
            <xsl:value-of select="for $c in (1 to gap/@quantity) return 'x'"/>
        </span>
    </xsl:template>
    <xsl:template match="gap[@reason='selection']">[...]</xsl:template>
</xsl:stylesheet>