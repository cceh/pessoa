<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:param name="language"/>
    <xsl:param name="basepath"/>
    <xsl:param name="host">http://pessoadigital.pt</xsl:param>

    <xsl:output method="xml"/>

    <!-- author: Ulrike Henny -->

    <xsl:template match="/">
        <data>
            <xsl:for-each select="//TEI//rs[@type = 'collection']">
                <xsl:sort/>
                <xsl:variable name="coll-id" select="@key"/>
                <xsl:variable name="doc-title"
                    select="replace(ancestor::TEI//titleStmt/title/normalize-space(.), '/E3', '')"/>
                <xsl:variable name="title-id"
                    select="doc('xmldb:exist:///db/apps/pessoa/data/indices.xml')//list[@type = 'collections']/item[@xml:id = $coll-id]/ptr[@type = 'title']/substring-after(@target, '#')"/>
                <xsl:variable name="coll-title"
                    select="doc('xmldb:exist:///db/apps/pessoa/data/indices.xml')//list[@type = 'titles']/item[@xml:id = $title-id]/title/text()"/>
                <xsl:variable name="journal-id" select="doc('xmldb:exist:///db/apps/pessoa/data/indices.xml')//list[@type = 'collections']/item[@xml:id = $coll-id]/ptr[@type = 'journal']/substring-after(@target, '#')"/>
                <xsl:variable name="journal-title" select="doc('xmldb:exist:///db/apps/pessoa/data/indices.xml')//list[@type = 'periodical']/item[@xml:id = $journal-id]"/>
                <xsl:variable name="origDate" select="ancestor::TEI//origDate"/>
                <xsl:variable name="imprintDate" select="ancestor::TEI//imprint/date"/>
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
                <xsl:variable name="title-names">
                    <xsl:choose>
                        <xsl:when test="$language = 'en'">name index</xsl:when>
                        <xsl:when test="$language = 'de'">Index Namen</xsl:when>
                        <xsl:otherwise>índice de nomes</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="title-titles">
                    <xsl:choose>
                        <xsl:when test="$language = 'en'">index of titles</xsl:when>
                        <xsl:when test="$language = 'de'">Index Titel</xsl:when>
                        <xsl:otherwise>índice de títulos</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="title-periodicals">
                    <xsl:choose>
                        <xsl:when test="$language = 'en'">index of periodicals</xsl:when>
                        <xsl:when test="$language = 'de'">Index Zeitschriften</xsl:when>
                        <xsl:otherwise>índice de periódicos</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <events>
                    <xsl:attribute name="title">
                        <xsl:value-of select="if ($coll-title) then $coll-title else $journal-title"/>
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
                    </xsl:attribute> &lt;a href="<xsl:value-of select="$link"/>"&gt;<xsl:value-of
                        select="$doc-title"/>&lt;/a&gt;&lt;br/&gt; <xsl:value-of
                        select="(ancestor::TEI//author)[1]/rs"/><xsl:text>, </xsl:text>
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
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_list']/term[@xml:lang = 'de']"
                                        />
                                    </xsl:when>
                                    <xsl:when test="@key = 'nota_editorial'">
                                        <xsl:value-of
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_note']/term[@xml:lang = 'de']"
                                        />
                                    </xsl:when>
                                    <xsl:when test="@key = 'plano_editorial'">
                                        <xsl:value-of
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_plan']/term[@xml:lang = 'de']"
                                        />
                                    </xsl:when>
                                    <xsl:when test="@key = 'poesia'">
                                        <xsl:value-of
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'poetry']/term[@xml:lang = 'de']"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$language = 'en'">
                            <xsl:for-each select="$genre">
                                <xsl:choose>
                                    <xsl:when test="@key = 'lista_editorial'">
                                        <xsl:value-of
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_list']/term[@xml:lang = 'en']"
                                        />
                                    </xsl:when>
                                    <xsl:when test="@key = 'nota_editorial'">
                                        <xsl:value-of
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_note']/term[@xml:lang = 'en']"
                                        />
                                    </xsl:when>
                                    <xsl:when test="@key = 'plano_editorial'">
                                        <xsl:value-of
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'editorial_plan']/term[@xml:lang = 'en']"
                                        />
                                    </xsl:when>
                                    <xsl:when test="@key = 'poesia'">
                                        <xsl:value-of
                                            select="doc('xmldb:exist:///db/apps/pessoa/resources/lists.xml')//list[@type = 'genres']/item[@xml:id = 'poetry']/term[@xml:lang = 'en']"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise> </xsl:otherwise>
                    </xsl:choose><xsl:text>.</xsl:text> &lt;br/&gt; <!--<xsl:if
                        test="ancestor::TEI//rs[@type = 'name']"> &lt;p&gt;<xsl:choose>
                            <xsl:when test="$language = 'de'">Erwähnte Namen:</xsl:when>
                            <xsl:when test="$language = 'en'">Mencioned names:</xsl:when>
                            <xsl:otherwise>Nomes mencionados:</xsl:otherwise>
                        </xsl:choose>&lt;/p&gt; &lt;ul&gt; <xsl:for-each-group
                            select="ancestor::TEI/text//rs[@type = 'name']" group-by="@key">
                            <xsl:sort
                                select="doc('/db/apps/pessoa/resources/lists.xml')//listPerson/person[@xml:id = current-grouping-key()]/persName[1]"/>
                            <xsl:variable name="key" select="current-grouping-key()"/>
                            <xsl:choose>
                                <xsl:when test="@style">
                                    <xsl:for-each-group select="current-group()" group-by="@style">
                                        <xsl:variable name="name"
                                            select="doc('/db/apps/pessoa/resources/lists.xml')//listPerson/person[@xml:id = $key or substring-after(@corresp, '#') = $key]/persName[@type = current-grouping-key()]"
                                        /> &lt;li&gt;<xsl:value-of select="$name/text()"/> &lt;a
                                            href="../../index/names#<xsl:value-of
                                            select="$name/text()"/>" title="<xsl:value-of
                                            select="$title-names"/>"&gt;&lt;img class="timelineImg"
                                            src="<xsl:value-of
                                            select="string-join(($host, 'resources/images/glyphicons-35-old-man.png'), '/')"
                                        />"/&gt;&lt;/a&gt;&lt;/li&gt; </xsl:for-each-group>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="name"
                                        select="doc('/db/apps/pessoa/resources/lists.xml')//listPerson/person[@xml:id = $key]/persName"
                                    /> &lt;li&gt;<xsl:value-of select="$name/text()"/> &lt;a
                                        href="../../index/names#<xsl:value-of select="$name/text()"
                                    />" title="<xsl:value-of select="$title-names"/>"&gt;&lt;img
                                    class="timelineImg" src="<xsl:value-of
                                        select="string-join(($host, 'resources/images/glyphicons-35-old-man.png'), '/')"
                                    />"/&gt;&lt;/a&gt;&lt;/li&gt; </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group> &lt;/ul&gt; </xsl:if>
                    <xsl:if test="ancestor::TEI//rs[@type = 'title']"> &lt;p&gt;<xsl:choose>
                            <xsl:when test="$language = 'de'">Erwähnte Titel:</xsl:when>
                            <xsl:when test="$language = 'en'">Mencioned titles:</xsl:when>
                            <xsl:otherwise>Títulos mencionados:</xsl:otherwise>
                        </xsl:choose>&lt;/p&gt; &lt;ul&gt; <xsl:for-each-group
                            select="ancestor::TEI/text//rs[@type = 'title']" group-by="@key">
                            <xsl:sort
                                select="doc('/db/apps/pessoa/resources/lists.xml')//list[@type = 'titles']/item[@xml:id = current-grouping-key()]/title/text()"/>
                            <xsl:variable name="key" select="current-grouping-key()"/>
                            <xsl:variable name="title"
                                select="doc('/db/apps/pessoa/resources/lists.xml')//list[@type = 'titles']/item[@xml:id = $key]/title/text()"
                            /> &lt;li&gt;<xsl:value-of select="$title"/> &lt;a
                                href="../../index/titles#<xsl:value-of select="$title"/>"
                                title="<xsl:value-of select="$title-titles"/>"&gt;&lt;img
                            class="timelineImg" src="<xsl:value-of
                                select="string-join(($host, 'resources/images/glyphicons-40-notes.png'), '/')"
                            />"/&gt;&lt;/a&gt;&lt;/li&gt; </xsl:for-each-group> &lt;/ul&gt; </xsl:if>
                    <xsl:if test="ancestor::TEI//rs[@type = 'periodical']"> &lt;p&gt;<xsl:choose>
                            <xsl:when test="$language = 'de'">Erwähnte Zeitschriften:</xsl:when>
                            <xsl:when test="$language = 'en'">Mencioned periodicals:</xsl:when>
                            <xsl:otherwise>Periódicos mencionados:</xsl:otherwise>
                        </xsl:choose>&lt;/p&gt; &lt;ul&gt; <xsl:for-each-group
                            select="ancestor::TEI/text//rs[@type = 'periodical']" group-by="@key">
                            <xsl:sort
                                select="doc('/db/apps/pessoa/resources/lists.xml')//list[@type = 'periodical']/item[@xml:id = current-grouping-key()]/text()"/>
                            <xsl:variable name="key" select="current-grouping-key()"/>
                            <xsl:variable name="periodical"
                                select="doc('/db/apps/pessoa/resources/lists.xml')//list[@type = 'periodical']/item[@xml:id = $key]/text()"
                            /> &lt;li&gt;<xsl:value-of select="$periodical"/> &lt;a
                                href="../../index/names#<xsl:value-of select="$periodical"/>"
                                title="<xsl:value-of select="$title-periodicals"/>"&gt;&lt;img
                            class="timelineImg" src="<xsl:value-of
                                select="string-join(($host, 'resources/images/glyphicons-609-newspaper.png'), '/')"
                            />"/&gt;&lt;/a&gt;&lt;/li&gt; </xsl:for-each-group> &lt;/ul&gt;
                    </xsl:if>-->
                </events>
            </xsl:for-each>
        </data>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
