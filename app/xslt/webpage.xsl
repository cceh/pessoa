<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml">

    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>

    <xsl:param name="res"/>


    <xsl:template match="div">
        <div>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id" select="@xml:id"/>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="ref">
        <a href="{@target}" class="pLink">
            <xsl:if test="@type[.='external']">
                <xsl:attribute name="target">_blank</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <xsl:template match="ptr">
        <xsl:variable name="doc" select="@target"/>
        <div class="tei-odd simple" id="TOP">
            <iframe src="{concat($res, @url)}"></iframe>
            <!--<xsl:copy-of select="doc($doc)//xhtml:link[@rel='stylesheet']"/>-->
            <xsl:copy-of select="doc($doc)//xhtml:body/child::*"/>
        </div>
    </xsl:template>

    <xsl:template match="graphic[not(parent::figure)]">
        <img src="{concat($res,@url)}" class="logos" title="{child::desc/text()}"
            alt="{child::desc/text()}"/>
    </xsl:template>

    <xsl:template match="figure/graphic">
        <div class="figure">
            <img src="{concat($res,@url)}" title="{child::desc/text()}" alt="{child::desc/text()}">
                <xsl:if test="@width">
                    <xsl:attribute name="width" select="@width"/>
                </xsl:if>
            </img>
        </div>
    </xsl:template>

    <xsl:template match="head">
        <h1>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>

    <xsl:template match="head[@type = 'sub']">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <xsl:template match="list[not(@type)]">
        <ul style="list-style:none;">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="list[@type = 'ordered']">
        <ol>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>

    <xsl:template match="item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="label[not(ancestor::list[@type = 'ordered'])]">
        <seg style="display: inline-block; width: 40px;">
            <xsl:apply-templates/>
        </seg>
    </xsl:template>
    <xsl:template match="label[ancestor::list[@type = 'ordered']]"/>

    <xsl:template match="seg[@rend = 'smaller']">
        <span style="font-size: smaller;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="seg[@rend = 'italic']">
        <span style="font-style: italic;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="lb">
        <br/>
    </xsl:template>

    <xsl:template match="p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

</xsl:stylesheet>
