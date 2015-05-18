<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="/">
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
                <h2>Persons</h2><!-- Mehrsprachigkeit -->
                <ul>
                    <xsl:for-each-group select=".//rs[@type='person'][@key]" group-by="@key">
                        <xsl:sort select="current-grouping-key()" />
                        <xsl:variable name="key" select="current-grouping-key()" />
                        <xsl:for-each-group select="current-group()" group-by="@role">
                            <xsl:sort select="current-grouping-key()" />
                            <li>
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//listPerson[@type='authors']/person[@xml:id=$key]/persName" /> (<xsl:value-of select="@role" />)<!-- Mehrsprachigkeit -->
                                <a href="#" title="show index"><img src="../../resources/images/list-48.png" width="16" height="auto" style="vertical-align:middle;" /></a>
                            </li>
                        </xsl:for-each-group>
                    </xsl:for-each-group>
                    <xsl:for-each select=".//rs[@type='person'][not(@key)]">
                        <xsl:sort select="."/>
                        <li><a onmouseover="highlight('{@xml:id}');" onmouseout="clear('{@xml:id}');" href="#"><xsl:value-of select="." /></a></li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='text']">
                <h2>Texts</h2><!-- Mehrsprachigkeit -->
                <ul>
                    <xsl:for-each select=".//rs[@type='text']">
                        <xsl:sort select="." order="ascending" />
                        <li><xsl:apply-templates /></li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
            <xsl:if test=".//rs[@type='journal']">
                <h2>Journals</h2><!-- Mehrsprachigkeit -->
                <ul>
                    <xsl:for-each-group select=".//rs[@type='journal']" group-by="@key">
                        <xsl:sort select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='journal']/item[@xml:id=current()/@key]" />
                        <xsl:variable name="key" select="@key" />
                        <li>
                            <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='journal']/item[@xml:id=$key]" /><!-- Mehrsprachigkeit -->
                            <a href="#" title="show index"><img src="../../resources/images/list-48.png" width="16" height="auto" style="vertical-align:middle;" /></a>
                       </li>
                    </xsl:for-each-group>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template match="subst">
        <xsl:apply-templates select="add" />
    </xsl:template>
    
    <xsl:template match="del" />
    
</xsl:stylesheet>