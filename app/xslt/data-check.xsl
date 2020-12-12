<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:variable name="lists" select="doc('../data/lists.xml')"/>
    
    <xsl:template match="/">
        <pubs>
            <xsl:for-each select="collection('../data/pub')//TEI">
                <pub file="{.//idno[@type='filename']}">
                <xsl:for-each select=".//rs[@type='name']">
                    <xsl:variable name="key" select="@key"/>
                    <xsl:variable name="text" select="normalize-space(string-join(text(),' '))"/>
                    <xsl:variable name="lists-name">
                        <xsl:choose>
                            <xsl:when test="@key=('FP','AC','AdC','RR','BS')">
                                <xsl:value-of select="$lists//person[substring-after(@corresp,'#')=$key]/normalize-space(.)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$lists//person[@xml:id=$key]/persName/normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="not(contains($lists-name,$text))">
                        <error key="{$key}">
                            <name_in_pub><xsl:value-of select="$text"/></name_in_pub>
                            <name_in_lists.xml><xsl:value-of select="$lists-name"/></name_in_lists.xml>
                        </error>
                    </xsl:if>
                </xsl:for-each>
                </pub>
            </xsl:for-each>
        </pubs>
        
        
        <!--<docs>
            <xsl:for-each select="collection('../data/doc')//TEI">
                <doc>
                    <filename_1><xsl:value-of select="tokenize(base-uri(root(.)),'/')[last()]"/></filename_1>
                    <filename_2><xsl:value-of select=".//idno[@type='filename']"/></filename_2>
                </doc>
            </xsl:for-each>
        </docs>-->
    </xsl:template>
    
    
</xsl:stylesheet>