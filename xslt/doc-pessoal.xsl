<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:import href="http://localhost:8080/exist/rest/db/apps/pessoa/xslt/doc.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    
    <!-- externer Parameter lb: yes|no
    (Zeilenumbrüche anzeigen oder nicht) -->
    <xsl:param name="lb" />
    <!-- externer Parameter abbr: yes|no
    (Abkürzungen anzeigen oder nicht) -->
    <xsl:param name="abbr" />
    
    <!-- Anzeige von Zeilenumbrüchen -->
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])]">
        <xsl:choose>
            <xsl:when test="$lb = 'yes'">
                <br />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="lb[preceding-sibling::*[1][local-name()='pc']]">
        <xsl:if test="$lb = 'yes'">
            <br />
        </xsl:if>
    </xsl:template>
    <!-- wenn Zeilenumbrüche angezeigt werden sollen, dann auch Satzzeichen anzeigen -->
    <xsl:template match="pc">
        <xsl:if test="$lb = 'yes'">
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>
    
    
    <!-- Anzeige von Abkürzungen -->
    <xsl:template match="choice[abbr and expan]">
        <xsl:choose>
            <xsl:when test="$abbr = 'yes'">
                <xsl:apply-templates select="abbr/text() | abbr/am/text()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="expan/text() | expan/ex/text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="abbr"/>
    <xsl:template match="ex">
        <span class="ex"><xsl:apply-templates /></span>
    </xsl:template>
    
</xsl:stylesheet>