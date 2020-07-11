<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" />
    
    <!-- copy all, but -->
    <xsl:template match="node() | @* | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="fileDesc">
        <xsl:copy>
            <xsl:copy-of select="titleStmt"/>
            <xsl:copy-of select="publicationStmt"/>
            <notesStmt xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="//note[@type='summary']"/>
                <xsl:copy-of select="//note[@type='genre']"/>
            </notesStmt>
            <sourceDesc xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="//list[@type='work-index']"/>
                <xsl:for-each select="sourceDesc/biblStruct">
                    <xsl:choose>
                        <xsl:when test="not(.//note)">
                            <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <biblStruct xmlns="http://www.tei-c.org/ns/1.0">
                                <xsl:copy-of select="analytic"/>
                                <xsl:copy-of select="monogr"/>
                                <xsl:copy-of select=".//comment()"/>
                            </biblStruct>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </sourceDesc>
        </xsl:copy>
        <xsl:if test="not(parent::teiHeader/encodingDesc)">
            <encodingDesc xmlns="http://www.tei-c.org/ns/1.0">
                <variantEncoding xmlns="http://www.tei-c.org/ns/1.0" method="parallel-segmentation" location="internal"/>
            </encodingDesc>
        </xsl:if>
    </xsl:template>
    
    
</xsl:stylesheet>