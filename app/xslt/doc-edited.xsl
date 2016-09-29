<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- Author: Ulrike Henny -->
    
    <xsl:import href="doc.xsl"/>
    
    <!-- externer Parameter lb: yes|no
    (Zeilenumbrüche anzeigen oder nicht) -->
    <xsl:param name="lb" />
    <!-- externer Parameter abbr: yes|no
    (Abkürzungen anzeigen oder nicht) -->
    <xsl:param name="abbr" />
    
    <!-- Choices -->
    <!-- Abkürzungen und Auflösungen: Darstellung der aufgelösten Form -->
    <xsl:template match="choice[abbr and expan[ex]]" mode="#default deletion">
        <xsl:choose>
            <xsl:when test="$abbr = 'no'">
                <xsl:apply-templates select="abbr/text() | abbr/child::*" />
                <xsl:if test="following-sibling::choice[1]">
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>           
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="abbr/metamark[@function='ditto']">
                        <span class="ditto">
                            <xsl:apply-templates select="expan/text() | expan/child::*"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="expan/text() | expan/child::*"/>                     
                        <xsl:if test="following-sibling::choice[1]">
                            <xsl:text>&#160;</xsl:text>
                        </xsl:if>     
                    </xsl:otherwise>
                </xsl:choose>            
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="choice[abbr and expan[not(ex)]]" mode="#default deletion">
        <span class="expan">[<xsl:apply-templates select="expan/text() | expan/child::*"/>]</span>
    </xsl:template>
    
    <xsl:template match="abbr" mode="#default deletion"/>
    
    <xsl:template match="ex" mode="#default deletion">
        <span class="ex">[<xsl:apply-templates />]</span>
    </xsl:template>
    
    <!-- Zeilenumbrüche:
    wenn es ein Silbentrennzeichen gibt, dann nichts ausgeben
    wenn es kein Silbentrennzeichen gibt, dann ein Leerzeichen ausgeben
    -->
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])][not(ancestor::add)]" mode="#default deletion">
        <xsl:choose>
            <xsl:when test="$lb = 'yes'">
                <br />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="lb[preceding-sibling::*[1][local-name()='pc']]" mode="#default deletion">
        <xsl:if test="$lb = 'yes'">
            <br />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="pc" mode="#default deletion">
        <xsl:if test="$lb = 'yes'">
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>
    
    <!-- editorische Ergänzungen anzeigen -->
    <xsl:template match="supplied" mode="#default deletion">
        <span class="supplied" title="lacuna no original">
            <xsl:choose>
                <xsl:when test="not(node()) or note">□</xsl:when>
                <xsl:otherwise>
                    &lt;<xsl:apply-templates />&gt;
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <!-- Randnotizen -->
    <xsl:template match="metamark[@rend='curly-bracket'][@function='grouping']" mode="#default deletion">
        <xsl:choose>
            <xsl:when test="parent::note[@place='margin-right']"><xsl:apply-templates/></xsl:when>
            <xsl:when test="parent::note[@place='margin-left']"><xsl:apply-templates/></xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="note[@place='margin-right']" mode="#default deletion">
        <span class="note">
            [<xsl:apply-templates/>]
        </span>
    </xsl:template>
    
    <xsl:template match="label" mode="#default deletion">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
</xsl:stylesheet>
    
