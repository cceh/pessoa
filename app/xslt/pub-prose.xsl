<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <!-- Author: Ulrike Henny-Krahmer -->
    
    <xsl:import href="pub.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="text">
        <div class="text prose">
            <xsl:if test="@corresp">
                <xsl:attribute name="id" select="substring-after(@corresp,'#')"/>
            </xsl:if>
            <style type="text/css">
                .lg {margin: 15px 0;}
                h2.center {text-align: center;}
                div.poem {margin: 20px 0;}
                p.indent {display: inline-block; text-indent: 1em; margin: 0;}
                div.ab-right {text-align: right;}
                div.prose {padding-right: 20px;}
            </style>
            <xsl:apply-templates />
            <xsl:apply-templates select="//note[@type='summary']"/>
        </div>
    </xsl:template>
    
    
    
    
    
</xsl:stylesheet>