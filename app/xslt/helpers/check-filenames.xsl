<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:template match="/">
        <list>
        <xsl:for-each select="collection('../../data/doc')">
            <xsl:variable name="filename-in-TEI" select=".//idno[@type='filename']"/>
            <xsl:variable name="filename-file" select="tokenize(document-uri(.),'/')[last()]"/>
            <xsl:if test="$filename-file != $filename-in-TEI">
                <item>
                    <filename_TEI><xsl:value-of select="$filename-in-TEI"/></filename_TEI>
                    <filename_file><xsl:value-of select="$filename-file"/></filename_file>
                </item>
            </xsl:if>
        </xsl:for-each>
        </list>
    </xsl:template>
    
</xsl:stylesheet>