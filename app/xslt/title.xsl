<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- @author: Ulrike Henny-Krahmer -->
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="rs[@type='title']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="choice[abbr][expan]">
        <xsl:apply-templates select="expan"/>
    </xsl:template>
    
    <xsl:template match="ex">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="abbr[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="am[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="choice[seg[@n='1'] and seg[@n='2']]">
        <xsl:apply-templates select="seg[@n='2']"/>
    </xsl:template>
    
    <xsl:template match="subst[del][add]">
        <xsl:apply-templates select="add"/>
    </xsl:template>
    
    <xsl:template match="del[not(parent::subst)]"/>
    
    <xsl:template match="lb[preceding-sibling::*[1][name()='pc']]"/>
    
    <xsl:template match="lb[not(preceding-sibling::*[1][name()='pc'])]">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="pc"/>
    
    <xsl:template match="rs[@type=('place','work','name','periodical')]|hi|add|abbr|am|seg">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    
</xsl:stylesheet>