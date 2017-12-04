<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:param name="language"/>
    <xsl:param name="basepath"/>
    <xsl:output method="xml"/>
    <xsl:template match="/">
        <data>
            <xsl:for-each select="//TEI">
                <events>
                    <xsl:attribute name="title">
                        <xsl:value-of select="replace(.//titleStmt/title/normalize-space(.),'/E3','')"/>
                    </xsl:attribute>
                    <xsl:for-each select=".//origDate | .//imprint/date">
                        <xsl:attribute name="start">
                            <xsl:value-of select="@from|@when|@notAfter|@notBefore"/>
                        </xsl:attribute>
                    </xsl:for-each>
                    <xsl:if test=".//origDate/@to or .//imprint/date/@to">
                        <xsl:attribute name="end">
                            <xsl:value-of select=".//origDate/@to | .//imprint/date/@to"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="(.//origDate/@from and .//origDate/@to) or (.//imprint/date/@from and .//imprint/date/@to)">
                        <xsl:attribute name="durationEvent">
                            <xsl:text>false</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="(.//origDate/@from and .//origDate/@to) or (.//imprint/date/@from and .//imprint/date/@to)">
                            <xsl:choose>
                                <xsl:when test="starts-with(.//idno[@type='filename'],'BNP') or starts-with(.//idno[@type='filename'], 'CP')">
                                    <xsl:attribute name="classname">
                                        <xsl:text>special_event document</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="classname">
                                        <xsl:text>special_event publication</xsl:text>
                                    </xsl:attribute>     
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="starts-with(.//idno[@type='filename'],'BNP') or starts-with(.//idno[@type='filename'], 'CP')">
                                    <xsl:attribute name="classname">
                                        <xsl:text>document</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="classname">
                                        <xsl:text>publication</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="caption">
                        <xsl:value-of select=".//origDate | .//imprint/date"/>
                    </xsl:attribute>
                    <xsl:attribute name="link">
                        <xsl:variable name="filename" select=".//idno[@type='filename']"/>
                        <xsl:choose>
                            <xsl:when test="starts-with($filename, 'MN') or starts-with($filename, 'BNP')">
                                <xsl:value-of select="concat(substring-before($basepath,'/pessoa'), '/', $language, '/doc/', substring-before($filename,'.xml'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(substring-before($basepath,'/pessoa'), '/', $language, '/pub/', substring-before($filename,'.xml'))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="icon">
                        <xsl:text>resources/images/circle_event.png</xsl:text>
                    </xsl:attribute>
                    <xsl:text>Fernando Pessoa, </xsl:text>
                    <xsl:value-of select=".//origDate | .//imprint/date"/>
                    <xsl:text>, </xsl:text>
                    <xsl:choose>
                        <xsl:when test="$language='pt'">
                            <xsl:value-of select="string-join(.//note[@type='genre']/rs, '/')"/>
                        </xsl:when>
                        <xsl:when test="$language='en'">
                            <xsl:if test=".//note[@type='genre']/rs[@key='lista_editorial'] ">
                                <xsl:value-of select="substring-after(doc('/db/apps/pessoa/data/lists.xml')//list[@type='genres' and @xml:lang='en']/item[@corresp='#lista_editorial'],'#lista_editorial')"/>
                            </xsl:if>
                            <xsl:if test=".//note[@type='genre']/rs[@key='nota_editorial']">
                                <xsl:value-of select="substring-after(doc('/db/apps/pessoa/data/lists.xml')//list[@type='genres' and @xml:lang='en']/item[@corresp='#nota_editorial'],'#nota_editorial')"/>
                            </xsl:if>
                            <xsl:if test=".//note[@type='genre']/rs[@key='plano_editorial']">
                                <xsl:value-of select="substring-after(doc('/db/apps/pessoa/data/lists.xml')//list[@type='genres' and @xml:lang='en']/item[@corresp='#plano_editorial'],'#plano_editorial')"/>
                            </xsl:if>
                            <xsl:if test=".//note[@type='genre']/rs[@key='poesia']">
                                <xsl:value-of select="substring-after(doc('/db/apps/pessoa/data/lists.xml')//list[@type='genres' and @xml:lang='en']/item[@corresp='#poesia'], '#poesia')"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                        </xsl:otherwise>
                    </xsl:choose>
                </events>
            </xsl:for-each>
        </data>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>