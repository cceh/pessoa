<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:import href="http://papyri.uni-koeln.de:8080/rest/db/apps/pessoa/xslt/common.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:template match="abbr"/>
    <xsl:template match="expan[@resp]">
        <span class="expan" style="color: green;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="add[@resp]">
        <span class="add" style="color: purple;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="supplied">
        <span class="supplied" style="color: red;">□</span>
    </xsl:template>
    <xsl:template match="subst[del][add]">
        <xsl:apply-templates select="add"/>
    </xsl:template>
    <xsl:template match="del[gap]"/>
</xsl:stylesheet>