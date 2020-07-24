<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:template match="/">
        <list xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="collection('../../data/pub')//TEI">
                <xsl:variable name="filename" select=".//idno[@type='filename']"/>
                <xsl:for-each select="text//rs[@key=('FP','AC','AdC','RR','BS')][not(@role)]">
                    <item type="{$filename}" xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="."/>
                    </item>
                </xsl:for-each>
            </xsl:for-each>
        </list>
    </xsl:template>
    
</xsl:stylesheet>