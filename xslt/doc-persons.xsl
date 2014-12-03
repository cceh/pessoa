<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="http://papyri.uni-koeln.de:8080/rest/db/apps/pessoa/xslt/common.xsl"/>
    <xsl:template match="expan"/>
    <xsl:template match="add[@resp]"/>
    <xsl:template match="rs[@type='person']">
        <span class="expan" style="color: blue;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="supplied"/>
</xsl:stylesheet>