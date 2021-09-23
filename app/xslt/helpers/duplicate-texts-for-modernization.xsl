<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/" priority="2">
        <!-- go through the TEI files for published prose
        check if the text still needs to be duplicated for modernization 
        if yes, do so
        remove <rs> elements from the duplicated part -->
        
        <xsl:for-each select="collection('../../data/pub')">
            <!-- are we in a prose text? -->
            <xsl:if test=".//notesStmt//rs[@type='genre'][@key='prosa']">
                <!-- is the text for modernization still missing? -->
                <xsl:if test="not(.//text[@type='reg'])">
                    <xsl:result-document href="/home/ulrike/Schreibtisch/archives/pessoa/{.//idno[@type='filename']}" method="xml" encoding="UTF-8" indent="yes">
                        <xsl:copy-of select="processing-instruction()"/>
                        <TEI>
                            <xsl:copy-of select=".//teiHeader"/>
                            <xsl:copy-of select=".//facsimile"/>
                            <xsl:variable name="text" select=".//text"/>
                            <text type="orig">
                                <xsl:apply-templates select="$text/node() | $text/@* | $text/comment() | $text/processing-instruction()"/>
                            </text>
                            <text type="reg">
                                <xsl:apply-templates select="$text/node() | $text/@* | $text/comment() | $text/processing-instruction()" mode="reg"/>
                            </text>
                        </TEI>
                    </xsl:result-document>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="node() | @* | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @* | comment() | processing-instruction()" mode="reg">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="rs" mode="reg">
        <xsl:apply-templates select="node() | @* | comment() | processing-instruction()" mode="reg"/>
    </xsl:template>
    
</xsl:stylesheet>