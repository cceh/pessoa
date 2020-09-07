<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml">
    
    <!-- author: Ulrike Henny-Krahmer -->

    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>

    <xsl:param name="res"/>
    <xsl:param name="docs-available"/>
    <xsl:param name="docs-restricted"/>
    <xsl:param name="pubs-available"/>
    <xsl:param name="pubs-restricted"/>


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
    
    <!--<xsl:template match="ptr">
        <xsl:variable name="doc" select="@target"/>
        <div class="tei-odd simple" id="TOP">
            <iframe src="{concat($res, @target)}" width="100%" height="auto"></iframe>
        </div>
    </xsl:template>-->

    <xsl:template match="graphic[not(parent::figure)]">
        <img src="{concat($res,@url)}" class="logos" title="{child::desc/text()/normalize-space(.)}"
            alt="{child::desc/text()/normalize-space(.)}"/>
    </xsl:template>

    <xsl:template match="figure/graphic">
        <div class="figure">
            <img src="{concat($res,@url)}" title="{child::desc/text()}" alt="{child::desc/text()}">
                <xsl:if test="@width">
                    <xsl:attribute name="width" select="@width"/>
                </xsl:if>
            </img>
            <xsl:if test="desc">
                <p class="figure-desc"><xsl:apply-templates select="desc"/></p>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="body/div/head">
        <h1>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>
    
    <xsl:template match="body/div/div/head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    
    <xsl:template match="body/div/div/div/head">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    
    <xsl:template match="body/div/div/div/div/head">
        <h4>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="head[@type = 'sub' and preceding-sibling::head]" priority="1">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    
    <xsl:template match="table">
        <table>
            <xsl:if test="@type='doc-overview'">
                <xsl:attribute name="class">doc-overview</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="@type='doc-overview'">
                <!-- if this is the overview table of available documents, count them and add the results as 
                a row to the table -->
                <tr>
                    <!-- available documents -->
                    <td><xsl:copy-of select="$docs-available"/></td>
                    <!-- documents work in progress -->
                    <td><xsl:copy-of select="$docs-restricted"/></td>
                    <!-- available publications -->
                    <td><xsl:copy-of select="$pubs-available"/></td>
                    <!-- publications work in progress -->
                    <td><xsl:copy-of select="$pubs-restricted"/></td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>
    
    <xsl:template match="row">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    
    <xsl:template match="cell">
        <td>
            <xsl:apply-templates/>
        </td>
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
            <xsl:if test="@xml:id">
                <xsl:attribute name="id" select="@xml:id"/>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="label[not(ancestor::list[@type = 'ordered'])][not(ancestor::text[@xml:id='network-documentation'])]">
        <seg style="display: inline-block; width: 40px;">
            <xsl:apply-templates/>
        </seg>
    </xsl:template>
    
    <xsl:template match="label[ancestor::text[@xml:id='network-documentation']]">
        <p>
            <strong><xsl:apply-templates/></strong>
        </p>
    </xsl:template>
    
    <xsl:template match="label[ancestor::list[@type = 'ordered']]"/>


    <xsl:template match="seg[@rend = 'smaller']">
        <span style="font-size: smaller;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="seg[@rend = 'bold']">
        <strong>
            <xsl:apply-templates/>
        </strong>
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
    
    <xsl:template match="trailer">
        <p class="trailer">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

</xsl:stylesheet>
