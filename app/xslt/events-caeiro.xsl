<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:param name="language"/>
    <xsl:param name="basepath"/>
    <xsl:param name="host">http://pessoadigital.pt</xsl:param>
    
    <xsl:output method="xml"/>
    
    <xsl:template match="/">
        <data>
            <xsl:for-each select="//TEI//rs[@type='work'][@key='O2']">
                <xsl:variable name="doc-title" select="replace(ancestor::TEI//titleStmt/title/normalize-space(.),'/E3','')"/>
                <xsl:variable name="work-title-style" select="@style"/>
                <xsl:variable name="work-title" select="doc('/db/apps/pessoa/data/lists.xml')//list[@type='works']/item[@xml:id='O2']/title[@subtype=$work-title-style]/text()"/>
                <xsl:variable name="origDate" select="ancestor::TEI//origDate"/>
                <xsl:variable name="imprintDate" select="ancestor::TEI//imprint/date"/>
                <xsl:variable name="filename" select="ancestor::TEI//idno[@type='filename']"/>
                <xsl:variable name="genre" select="ancestor::TEI//note[@type='genre']"/>
                <xsl:variable name="link">
                    <xsl:choose>
                        <xsl:when test="starts-with($filename, 'CP') or starts-with($filename, 'BNP')">
                            <xsl:value-of select="concat(substring-before($basepath,'/pessoa'), '/', $language, '/doc/', substring-before($filename,'.xml'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(substring-before($basepath,'/pessoa'), '/', $language, '/pub/', substring-before($filename,'.xml'))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="title-names">
                    <xsl:choose>
                        <xsl:when test="$language='en'">name index</xsl:when>
                        <xsl:when test="$language='de'">Index Namen</xsl:when>
                        <xsl:otherwise>índice de nomes</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <events>
                    <xsl:attribute name="title">
                        <xsl:value-of select="$work-title"/>
                    </xsl:attribute>
                    <xsl:for-each select="$origDate | $imprintDate">
                        <xsl:attribute name="start">
                            <xsl:value-of select="@from|@when|@notAfter|@notBefore"/>
                        </xsl:attribute>
                    </xsl:for-each>
                    <xsl:if test="$origDate/@to or $imprintDate/@to">
                        <xsl:attribute name="end">
                            <xsl:value-of select="$origDate/@to | $imprintDate/@to"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="($origDate/@from and $origDate/@to) or ($imprintDate/@from and $imprintDate/@to)">
                        <xsl:attribute name="durationEvent">
                            <xsl:text>false</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="($origDate/@from and $origDate/@to) or ($imprintDate/@from and $imprintDate/@to)">
                            <xsl:choose>
                                <xsl:when test="starts-with($filename,'BNP') or starts-with($filename, 'CP')">
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
                                <xsl:when test="starts-with($filename,'BNP') or starts-with($filename, 'CP')">
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
                        <xsl:value-of select="$doc-title"/>
                    </xsl:attribute>
                    <xsl:attribute name="icon">
                        <xsl:text>resources/images/circle_event.png</xsl:text>
                    </xsl:attribute>
                    &lt;a href="<xsl:value-of select="$link"/>"&gt;<xsl:value-of select="$doc-title"/>&lt;/a&gt;&lt;br/&gt;
                    <xsl:value-of select="(ancestor::TEI//author)[1]/rs"/><xsl:text>, </xsl:text>
                    <xsl:value-of select="$origDate | $imprintDate"/><xsl:text>, </xsl:text>
                    <xsl:choose>
                        <xsl:when test="$language='pt'">
                            <xsl:value-of select="string-join(.//note[@type='genre']/rs, '/')"/>
                        </xsl:when>
                        <xsl:when test="$language='de'">
                            <xsl:if test="$genre/rs[@key='lista_editorial']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='editorial_list']/term[@xml:lang='de']"/>
                            </xsl:if>
                            <xsl:if test="$genre/rs[@key='nota_editorial']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='editorial_note']/term[@xml:lang='de']"/>
                            </xsl:if>
                            <xsl:if test="$genre/rs[@key='plano_editorial']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='editorial_plan']/term[@xml:lang='de']"/>
                            </xsl:if>
                            <xsl:if test="$genre/rs[@key='poesia']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='poetry']/term[@xml:lang='de']"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$language='en'">
                            <xsl:if test="$genre/rs[@key='lista_editorial']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='editorial_list']/term[@xml:lang='en']"/>
                            </xsl:if>
                            <xsl:if test="$genre/rs[@key='nota_editorial']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='editorial_note']/term[@xml:lang='en']"/>
                            </xsl:if>
                            <xsl:if test="$genre/rs[@key='plano_editorial']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='editorial_plan']/term[@xml:lang='en']"/>
                            </xsl:if>
                            <xsl:if test="$genre/rs[@key='poesia']">
                                <xsl:value-of select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type='genres']/item[@xml:id='poetry']/term[@xml:lang='en']"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                        </xsl:otherwise>
                    </xsl:choose><xsl:text>.</xsl:text>
                    &lt;br/&gt;
                    &lt;p&gt;<xsl:choose>
                        <xsl:when test="$language='de'">Erwähnte Namen:</xsl:when>
                        <xsl:when test="$language='en'">Mencioned names:</xsl:when>
                        <xsl:otherwise>Nomes mencionados:</xsl:otherwise>
                    </xsl:choose>&lt;/p&gt;
                    &lt;ul&gt;
                    <xsl:for-each-group select="ancestor::TEI/text//rs[@type='name']" group-by="@key">
                        <xsl:sort select="doc('/db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=current-grouping-key()]/persName[1]"/>
                        <xsl:variable name="key" select="current-grouping-key()"/>
                        <xsl:choose>
                            <xsl:when test="@style">
                                <xsl:for-each-group select="current-group()" group-by="@style">
                                    <xsl:variable name="name" select="doc('/db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=$key or substring-after(@corresp,'#')=$key]/persName[@type=current-grouping-key()]"/>
                                    &lt;li&gt;<xsl:value-of select="$name/text()"/> &lt;a href="../../index/names#<xsl:value-of select="$name/text()"/>" title="<xsl:value-of select="$title-names"/>"&gt;&lt;img class="timelineImg" src="<xsl:value-of select="string-join(($host,'resources/images/glyphicons-35-old-man.png'),'/')"/>"/&gt;&lt;/a&gt;&lt;/li&gt;
                                </xsl:for-each-group>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="name" select="doc('/db/apps/pessoa/data/lists.xml')//listPerson/person[@xml:id=$key]/persName"/>
                                &lt;li&gt;<xsl:value-of select="$name/text()"/> &lt;a href="../../index/names#<xsl:value-of select="$name/text()"/>" title="<xsl:value-of select="$title-names"/>"&gt;&lt;img class="timelineImg" src="<xsl:value-of select="string-join(($host,'resources/images/glyphicons-35-old-man.png'),'/')"/>"/&gt;&lt;/a&gt;&lt;/li&gt;
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                    &lt;/ul&gt;
                    &lt;p&gt;Erwähnte Titel: tbd &lt;/p&gt;
                    &lt;p&gt;Erwähnte Zeitschriften: tbd &lt;/p&gt;
                    
                </events>
            </xsl:for-each>
        </data>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>