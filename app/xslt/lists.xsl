<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://localhost"
    version="2.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <!-- author: Ulrike Henny -->
    
    <xsl:param name="lang">pt</xsl:param>
    <xsl:param name="host">http://pessoadigital.pt</xsl:param>
    
    <xsl:template match="/">
        <xsl:apply-templates select=".//body"/>
    </xsl:template>
    
    <xsl:template match="body">
        <div>
            <script type="text/javascript">
                function highlight(key){
                    els = document.getElementsByClassName(key);
                    for (var i=0; i &lt; els.length; i++){
                        els[i].style.color="#009999";
                    }
                }
                function clearH(key){
                    els = document.getElementsByClassName(key);
                    for (var i=0; i &lt; els.length; i++){
                        els[i].style.color="";
                    }
                }
            </script>
            <style type="text/css">
                #index h2 {
                    margin-top: 30px;
                    text-align: left;
                    }
                .indexImg {
                    width: 16px;
                    height: auto;
                    vertical-align: bottom;
                    position: relative;
                    bottom: 2px;
                    margin-left: 5px;
                    }
                .typeB {
                    width: 12px;
                    margin-left: 7px;
                }
            </style>
            <xsl:if test=".//rs[@type='name']">
                <xsl:variable name="title">
                    <xsl:choose>
                        <xsl:when test="$lang='en'">name index</xsl:when>
                        <xsl:when test="$lang='de'">Index Namen</xsl:when>
                        <xsl:otherwise>índice de nomes</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Names</xsl:when>
                    <xsl:when test="$lang='de'">Namen</xsl:when>
                    <xsl:otherwise>Nomes</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each-group select=".//rs[@type='name']" group-by="@key">
                        <xsl:sort select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=current-grouping-key()]/persName[@type='main']"/>
                        <xsl:variable name="key" select="current-grouping-key()"/>
                        <xsl:variable name="name" select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=$key]/persName[@type='main']"/>
                        <li onmouseenter="highlight('person {$key}');" onmouseleave="clearH('{$key}');"><xsl:value-of select="$name"/> <a href="../../index/names#{$key}" title="{$title}"><img class="indexImg" src="{string-join(($host,'resources/images/glyphicons-35-old-man.png'),'/')}"/></a></li>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='title']">
                <xsl:variable name="title">
                    <xsl:choose>
                        <xsl:when test="$lang='en'">index of titles</xsl:when>
                        <xsl:when test="$lang='de'">Index Titel</xsl:when>
                        <xsl:otherwise>índice de títulos</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Titles</xsl:when>
                    <xsl:when test="$lang='de'">Titel</xsl:when>
                    <xsl:otherwise>Títulos</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each-group select=".//rs[@type='title']" group-by="lower-case(normalize-space(replace(.,'[“”()]','')))">
                        <xsl:sort select="current-grouping-key()"/>
                        <xsl:variable name="key" select="current-grouping-key()"/>
                        <li onmouseenter="highlight('text {$key}');" onmouseleave="clearH('{$key}');"><xsl:apply-templates select="current-group()[1]" /> <a href="../../index/titles#{$key}" title="{$title}"><img class="indexImg typeB" src="{string-join(($host,'resources/images/glyphicons-40-notes.png'),'/')}"/></a></li>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='periodical']">
                <xsl:variable name="title">
                    <xsl:choose>
                        <xsl:when test="$lang='en'">index of periodicals</xsl:when>
                        <xsl:when test="$lang='de'">Index Zeitschriften</xsl:when>
                        <xsl:otherwise>índice de periódicos</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Periodicals</xsl:when>
                    <xsl:when test="$lang='de'">Zeitschriften</xsl:when>
                    <xsl:otherwise>Periódicos</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each-group select=".//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='periodical']/item[@xml:id=current-grouping-key()]"/>
                        <xsl:variable name="name"  select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='periodical']/item[@xml:id=current-grouping-key()]"/>
                        <li onmouseenter="highlight('journal {current-grouping-key()}');" onmouseleave="clearH('{current-grouping-key()}');"><xsl:value-of select="$name"/> <a href="../../index/periodicals#{$name}" title="{$title}"><img class="indexImg" src="{string-join(($host,'resources/images/glyphicons-609-newspaper.png'),'/')}"/></a></li>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template match="choice[abbr][expan]">
        <xsl:apply-templates select="expan"/>
    </xsl:template>
    
    <xsl:template match="choice[seg[@n='1'] and seg[@n='2']]">
        <xsl:apply-templates select="seg[@n='2']"/>
    </xsl:template>
    
    <xsl:template match="lb">
            <xsl:if test="not(preceding-sibling::*[1][name() = 'pc'])">
                <xsl:text> </xsl:text>
            </xsl:if>
    </xsl:template>
    
    <xsl:template match="pc|del"/>
    
    <xsl:template match="text()">
        <xsl:variable name="str1" select="replace(.,'^[.“”]*(.+?)[.“”]*$','$1')" />
        <xsl:value-of select="$str1" />
    </xsl:template>
    
</xsl:stylesheet>