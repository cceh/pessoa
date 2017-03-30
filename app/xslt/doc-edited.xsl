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
    
    <xsl:template match="p[@rend='position-center']" mode="#default deletion addition">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <!-- Choices -->
    <!-- Abkürzungen und Auflösungen: Darstellung der aufgelösten Form -->
    <xsl:template match="choice[abbr and expan[ex]]" mode="#default deletion addition">
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
                    </xsl:otherwise>
                </xsl:choose>            
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="choice[abbr and expan[not(ex)]]" mode="#default deletion addition">
        <span class="expan">[<xsl:apply-templates select="expan/text() | expan/child::*"/>]</span>
    </xsl:template>
    
    <xsl:template match="subst" mode="#default deletion addition">
        <span class="subst">
            <xsl:apply-templates select="child::*[not(@n='2')]"/>
        </span>
    </xsl:template>
    
    <xsl:template match="add[@place='below' or @place='above']" mode="#default deletion addition" priority="2">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="abbr" mode="#default deletion addition">
        <xsl:choose>
            <xsl:when test="parent::choice"/>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ex" mode="#default deletion addition">
        <span class="ex">[<xsl:apply-templates />]</span>
    </xsl:template>
    
    <!-- Zeilenumbrüche:
    wenn es ein Silbentrennzeichen gibt, dann nichts ausgeben
    wenn es kein Silbentrennzeichen gibt, dann ein Leerzeichen ausgeben
    -->
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])][not(ancestor::add)]" mode="#default deletion addition">
        <xsl:choose>
            <xsl:when test="$lb = 'yes' or ancestor::body//note[@place='margin-right']">
                <br />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="lb[preceding-sibling::*[1][local-name()='pc']]" mode="#default deletion addition">
        <xsl:if test="$lb = 'yes' or ancestor::body//note[@place='margin-right']">
            <br />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="pc" mode="#default deletion addition">
        <xsl:if test="$lb = 'yes'">
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>
    
    <!-- editorische Ergänzungen anzeigen -->
    <xsl:template match="supplied" mode="#default deletion addition">
        <span class="supplied" title="lacuna no original">
            <xsl:choose>
                <xsl:when test="not(node()) or note">□</xsl:when>
                <xsl:otherwise>
                    &lt;<xsl:apply-templates />&gt;
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <!-- Gelöschtes nicht anzeigen -->
    <xsl:template match="del[@n='2']|del" mode="#default deletion addition"/>
    
    <!-- Certainty -->
    <xsl:template match="certainty" mode="#default deletion addition">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>
    
