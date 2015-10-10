<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://localhost"
    version="2.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:param name="lang">pt</xsl:param>
    
    <xsl:template match="/">
        <xsl:apply-templates select=".//body"/>
    </xsl:template>
    
    <xsl:template match="body">
        <div>
            <style type="text/css">
                .indexLink {font-size:14pt;color:#08298A;margin-left:5px;}
            </style>
            <xsl:if test=".//rs[@type='person']">
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Persons</xsl:when>
                    <xsl:otherwise>Pessoas</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each-group select=".//rs[@type='person']" group-by="@key">
                        <xsl:sort select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=current-grouping-key()]/persName[1]"/>
                        <xsl:variable name="key" select="current-grouping-key()"/>
                        <xsl:choose>
                            <xsl:when test="@style">
                                <xsl:for-each-group select="current-group()" group-by="@style">
                                    <xsl:variable name="name" select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=$key]/persName[@type=current-grouping-key()]"/>
                                    <li><xsl:value-of select="$name"/> <a href="../../page/persons#{$name}" class="indexLink">→</a></li>
                                </xsl:for-each-group>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="name" select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=$key]/persName"/>
                                <li><xsl:value-of select="$name"/> <a href="../../page/persons#{$name}" class="indexLink">→</a></li>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='text']">
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Texts</xsl:when>
                    <xsl:otherwise>Textos</xsl:otherwise>
                </xsl:choose></h2>
            </xsl:if>
            <xsl:if test=".//rs[@type='journal']">
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Journals</xsl:when>
                    <xsl:otherwise>Jornais</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each-group select=".//rs[@type='journal']" group-by="@key">
                        <li><xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='journals']/item[@xml:id=current-grouping-key()]"/></li>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    
</xsl:stylesheet>