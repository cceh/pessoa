<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:template match="/">
        <docs>
            <xsl:for-each select="collection('../data/doc')//TEI">
                <doc>
                    <filename_1><xsl:value-of select="tokenize(base-uri(root(.)),'/')[last()]"/></filename_1>
                    <filename_2><xsl:value-of select=".//idno[@type='filename']"/></filename_2>
                </doc>
            </xsl:for-each>
        </docs>
    </xsl:template>
    
    
</xsl:stylesheet>