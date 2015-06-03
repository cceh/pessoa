<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:import href="doc.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:preserve-space elements="*"/>
    <xsl:strip-space elements="rs"/>
    <!-- externer Parameter lb: yes|no
    (Zeilenumbrüche anzeigen oder nicht) -->
    <xsl:param name="lb" />
    <!-- externer Parameter abbr: yes|no
    (Abkürzungen anzeigen oder nicht) -->
    <xsl:param name="abbr" />

   <!-- Trotz Aufhebung der lb's soll am Rand genug Platz für Notes bleiben --> 
    <xsl:template match="text">
       <div class="text">          
               <xsl:if test="@xml:id">
                   <xsl:attribute name="id">
                       <xsl:value-of select="@xml:id"/>
                   </xsl:attribute>
               </xsl:if> 
           <xsl:attribute name="style">
               <xsl:if test="//note[contains(@place,'left')]">
                 padding-left: 150px;  
               </xsl:if>
               <xsl:if test="//note[contains(@place,'right')]">
                   padding-right:150px;
               </xsl:if>
           </xsl:attribute>   
               <xsl:apply-templates/>         
       </div>
    </xsl:template>
    
    <!-- Anzeige von Zeilenumbrüchen -->
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])][not(ancestor::note)][not(ancestor::add)]">
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
    
    <xsl:template match="pc">
        <xsl:if test="$lb = 'yes'">
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>
     
    <!-- Anzeige von Abkürzungen -->
    <xsl:template match="choice[abbr and expan]">
        <xsl:choose>
            <xsl:when test="$abbr = 'yes'">
                <xsl:apply-templates select="abbr/text() | abbr/child::*" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="expan/text() | expan/child::*"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="abbr"/>
    <xsl:template match="ex">
        <span class="ex"><xsl:apply-templates /></span>
    </xsl:template>
   
   <!-- Einrückungen aufheben wenn lb's entfernt werden-->
    <xsl:template match="seg[@rend='indent']">
        <span>
            <xsl:if test="$lb='yes'">
              <xsl:attribute name="class">indent</xsl:attribute>  
            </xsl:if>
            <xsl:apply-templates/>
        </span>   
    </xsl:template>
    
    <xsl:template match="ab[@rend='indent']">
        <span class="ab">
            <xsl:if test="$lb='yes'">
                <xsl:attribute name="style">margin-left:2em;</xsl:attribute>  
            </xsl:if>
            <xsl:apply-templates/>
        </span>   
    </xsl:template>
    
    
   
</xsl:stylesheet>