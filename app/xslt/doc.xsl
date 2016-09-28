<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Authors: Ulrike Henny, Alena Geduldig -->
    
    <xsl:template match="/">
        <xsl:apply-templates />       
    </xsl:template>
    
    <!-- Header & Text -->
    <xsl:template match="teiHeader"/>
    <xsl:template match="text">
        <div class="text">
            <xsl:apply-templates />
        </div>
        <xsl:apply-templates select="//msDesc[@type='prose']"/>
    </xsl:template>
    
    <!-- Editorial notes and interventions -->
    <xsl:template match="msDesc[@type='prose']">
        <div class="editorial-note">
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <xsl:template match="ref[@target]">
        <xsl:variable name="id" select="@target"/>
        <a href="../data/doc/{$id}"> <xsl:apply-templates/></a>     
    </xsl:template>
    <xsl:template match="supplied"/>
    
    <!-- Structure of the text -->
    <xsl:template match="head">
        <h2>
            <xsl:apply-templates />
        </h2>
    </xsl:template>
    
    <xsl:template match="list">
        <div class="list">
            <xsl:apply-templates />
        </div>                   
    </xsl:template>
    
    <xsl:template match="item">
        <div>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">item <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">item</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    
    <xsl:template match="label">
        <span class="label">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- Metamarks -->
    <!-- Lines -->
    <xsl:template match="metamark[@rend='line-14'][@function=('distinct','end')]" >
        <hr class="line line-14" />
    </xsl:template>
    <xsl:template match="metamark[@rend='line-24'][@function=('distinct','end')]" >
        <hr class="line line-24" />
    </xsl:template>
    <xsl:template match="metamark[@rend='line-34'][@function=('distinct','end')]" >
        <hr class="line line-34" />
    </xsl:template>
    <xsl:template match="metamark[@rend='line-44'][@function=('distinct','end')]" >
        <hr class="line line-44" />
    </xsl:template>
    <!-- Quotes -->
    <xsl:template match="metamark[@rend='quotes'][@function='ditto']" >
        <span class="metamark quotes ditto"> " </span>
    </xsl:template>
    
    <!-- Highlighting -->
    <xsl:template match="hi[@rend='underline']" >
        <span class="underline">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='italic']" >
        <span class="italic">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend='circled']" >
        <span class="circled">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- Entities -->
    <xsl:template match="rs[@type='person']" >
        <span class="person {@key}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='place']" >
        <span class="place">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='journal']" >
        <span class="journal {@key}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type='work']" >
        <span class="work {@key}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="rs[@type='text']" >
        <span class="text {replace(.,'[“”.\s]','')}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- Breaks -->
    <xsl:template match="lb" >
        <br/>
    </xsl:template>
    <xsl:template match="pb"/>
    
    <!-- Abbreviations -->
    <xsl:template match="expan"/>
    
    <!-- Gaps -->
    <xsl:template match="gap[@reason='selection']"/>
    <xsl:template match="gap[@reason='illegible']"><span title="ilegível">†</span></xsl:template>
    
</xsl:stylesheet>