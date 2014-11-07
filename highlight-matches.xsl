<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:template match="node() | @* | processing-instruction() | comment()">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | processing-instruction() | comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="exist:match">
        <span xmlns="http://www.w3.org/1999/xhtml" class="match">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>