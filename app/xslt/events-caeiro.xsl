<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:param name="language"/>
    <xsl:param name="basepath"/>
    <xsl:param name="host">http://pessoadigital.pt</xsl:param>

    <xsl:output method="xml"/>

    <!-- author: Ulrike Henny -->
    
    <xsl:template match="/">
        <data>
            <xsl:for-each select="//TEI//rs[@type = 'work']">
                
                <xsl:sort select="if (@n) then @n else normalize-space(string-join(text(), ''))" data-type="number"/>
                <xsl:sort select="if (not(@n)) then normalize-space(string-join(text(), '')) else ()" data-type="text"/>
                <xsl:variable name="work-id" select="@key"/>
                
                <!-- check if it is the right author -->
                <xsl:if
                    test="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'works']/item[@xml:id = $work-id]/name[@type = 'author'][@key = 'AC']">
                    <xsl:variable name="doc-title"
                        select="replace(ancestor::TEI//titleStmt/title/normalize-space(.), '/E3', '')"/>
                    <xsl:variable name="title-id"
                        select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'works']/item[@xml:id = $work-id]/title/@key"/>
                    <xsl:variable name="work-title"
                        select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'titles']/item[@xml:id = $title-id]/title/text()"/>
                    <xsl:variable name="origDate" select="ancestor::TEI//origDate"/>
                    <!-- if there are several publication dates, take only the first one: -->
                    <xsl:variable name="imprintDate" select="(ancestor::TEI//imprint)[1]/date"/>
                    <xsl:variable name="filename" select="ancestor::TEI//idno[@type = 'filename']"/>
                    <xsl:variable name="genre" select="ancestor::TEI//note[@type = 'genre']/rs"/>
                    <xsl:variable name="link">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with($filename, 'CP') or starts-with($filename, 'BNP')">
                                <xsl:value-of
                                    select="concat(substring-before($basepath, '/pessoa'), '/', $language, '/doc/', substring-before($filename, '.xml'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="concat(substring-before($basepath, '/pessoa'), '/', $language, '/pub/', substring-before($filename, '.xml'))"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <events>
                        <xsl:attribute name="title">
                            <xsl:value-of select="$work-title"/>
                        </xsl:attribute>
                        <xsl:for-each select="$origDate | $imprintDate">
                            <xsl:attribute name="start">
                                <xsl:value-of select="@from | @when | @notAfter | @notBefore"/>
                            </xsl:attribute>
                        </xsl:for-each>
                        <xsl:if test="$origDate/@to or $imprintDate/@to">
                            <xsl:attribute name="end">
                                <xsl:value-of select="$origDate/@to | $imprintDate/@to"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if
                            test="($origDate/@from and $origDate/@to) or ($imprintDate/@from and $imprintDate/@to)">
                            <xsl:attribute name="durationEvent">
                                <xsl:text>false</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when
                                test="($origDate/@from and $origDate/@to) or ($imprintDate/@from and $imprintDate/@to)">
                                <xsl:choose>
                                    <xsl:when
                                        test="starts-with($filename, 'BNP') or starts-with($filename, 'CP')">
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
                                    <xsl:when
                                        test="starts-with($filename, 'BNP') or starts-with($filename, 'CP')">
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
                            <xsl:value-of
                                select="concat($host, '/resources/images/circle_event.png')"/>
                        </xsl:attribute> &lt;a href="<xsl:value-of select="$link"
                            />"&gt;<xsl:value-of select="$doc-title"/>&lt;/a&gt;&lt;br/&gt;
                            <xsl:value-of select="(ancestor::TEI//author)[1]/rs"/><xsl:text>, </xsl:text>
                        <xsl:value-of select="$origDate | $imprintDate"/><xsl:text>, </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$language = 'pt'">
                                <xsl:value-of select="string-join($genre, '/')"/>
                            </xsl:when>
                            <xsl:when test="$language = 'de'">
                                <xsl:for-each select="$genre">
                                    <xsl:choose>
                                        <xsl:when test="@key = 'lista_editorial'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_list']/term[@xml:lang = 'de']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'nota_editorial'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_note']/term[@xml:lang = 'de']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'plano_editorial'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_plan']/term[@xml:lang = 'de']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'poesia'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'poetry']/term[@xml:lang = 'de']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'prosa'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'prose']/term[@xml:lang = 'de']"
                                            />
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:if test="position() != last()"
                                        ><xsl:text>, </xsl:text></xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="$language = 'en'">
                                <xsl:for-each select="$genre">
                                    <xsl:choose>
                                        <xsl:when test="@key = 'lista_editorial'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_list']/term[@xml:lang = 'en']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'nota_editorial'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_note']/term[@xml:lang = 'en']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'plano_editorial'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_plan']/term[@xml:lang = 'en']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'poesia'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'poetry']/term[@xml:lang = 'en']"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@key = 'prosa'">
                                            <xsl:value-of
                                                select="doc('xmldb:exist:///db/apps/pessoa/data/lists.xml')//list[@type = 'genres']/item[@xml:id = 'prose']/term[@xml:lang = 'en']"
                                            />
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:if test="position() != last()"
                                        ><xsl:text>, </xsl:text></xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise> </xsl:otherwise>
                        </xsl:choose><xsl:text>.</xsl:text>
                    </events>
                </xsl:if>
            </xsl:for-each>
        </data>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
