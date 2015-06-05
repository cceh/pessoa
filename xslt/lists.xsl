<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://localhost"
    version="2.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:param name="lang">pt</xsl:param>
    
    <xsl:template match="/">
        <xsl:apply-templates select="//body"/>
    </xsl:template>
    
    <xsl:template match="//body">
        <div>
            <script type="text/javascript">
                function highlight(id){
                    $("."+id).css("color","orange");
                };
                function clear(id){
                    $("."+id).css("color","black");
                };
            </script>
            <xsl:if test=".//rs[@type='person']">
                <xsl:variable name="persons">
                    <local:persons>
                    <xsl:for-each-group select=".//rs[@type='person'][@key]" group-by="@key">
                        <xsl:sort select="current-grouping-key()" />
                        <xsl:variable name="key" select="current-grouping-key()" />
                        <xsl:for-each-group select="current-group()" group-by="@role">
                            <xsl:sort select="current-grouping-key()" />
                            <local:person key="{$key}" role="{@role}">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson[@type='authors']/person[@xml:id=$key]/persName" /> (<xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='roles'][@xml:lang=$lang]/item[@xml:id=current()/@role or @corresp=concat('#',current()/@role)]" />)
                                <!--<a href="#" title="show index"><img src="../../resources/images/list-48.png" width="16" height="auto" style="vertical-align:middle;" /></a>-->
                            </local:person>
                        </xsl:for-each-group>
                    </xsl:for-each-group>
                        <xsl:for-each select=".//rs[@type='person'][not(@key)]">
                            <xsl:sort select="."/>
                            <local:person><xsl:value-of select="." /></local:person>
                            <!-- <a onmouseover="highlight('{@xml:id}');" onmouseout="clear('{@xml:id}');" href="#"> -->
                        </xsl:for-each>
                    </local:persons>
                </xsl:variable>
                <h2><xsl:choose>
                    <xsl:when test="$lang='en'">Persons</xsl:when>
                    <xsl:otherwise>Pessoas</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                   <xsl:for-each select="$persons//local:person">
                       <xsl:sort/>
                       <li style="display:block;"><xsl:value-of select="." /></li>
                   </xsl:for-each>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='text']">
                <xsl:variable name="texts">
                    <local:texts>
                    <xsl:for-each select=".//rs[@type='text']">
                        <xsl:sort select="." order="ascending" />
                        <local:text><xsl:apply-templates /></local:text>
                    </xsl:for-each>
                    </local:texts>
                </xsl:variable>
                <h2 style="margin-top: 20px;"><xsl:choose>
                    <xsl:when test="$lang='en'">Texts</xsl:when>
                    <xsl:otherwise>Textos</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each select="$texts//local:text">
                        <li style="display:block;"><xsl:value-of select="."/></li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='journal']">
                <xsl:variable name="journals">
                    <local:journals>
                        <xsl:for-each-group select=".//rs[@type='journal']" group-by="@key">
                            <xsl:sort select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='journal']/item[@xml:id=current()/@key]" />
                            <xsl:variable name="key" select="@key" />
                            <journal key="{$key}">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='journal']/item[@xml:id=$key]" /><!-- Mehrsprachigkeit -->
                                <!--<a href="#" title="show index"><img src="../../resources/images/list-48.png" width="16" height="auto" style="vertical-align:middle;" /></a>-->
                            </journal>
                        </xsl:for-each-group>
                    </local:journals>
                </xsl:variable>
                <h2 style="margin-top: 20px;"><xsl:choose>
                    <xsl:when test="$lang='en'">Journals</xsl:when>
                    <xsl:otherwise>Journais</xsl:otherwise>
                </xsl:choose></h2>
                <ul>
                    <xsl:for-each select="$journals//local:journal">
                        <li style="display: block;"><xsl:value-of select="."/></li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template match="subst">
        <xsl:apply-templates select="add" />
    </xsl:template>
    
    <xsl:template match="del" />
    
</xsl:stylesheet>