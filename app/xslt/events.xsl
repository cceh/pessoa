<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:param name="language"/>
    <xsl:param name="basepath"/>
    <xsl:output method="xml"/>

    <!-- 
        Collects events for the timeline of documents and publications.
        @author: Ulrike Henny 
    -->

    <xsl:template match="/">
        <data>
            <xsl:for-each select="//TEI">
                <xsl:variable name="title" select=".//titleStmt/title/normalize-space(.)"/>
                <xsl:variable name="author" select="(.//author)[1]/rs"/>
                <xsl:variable name="genre-text">
                    <xsl:variable name="genres" select=".//note[@type = 'genre']/rs"/>
                    <xsl:choose>
                        <xsl:when test="$language = 'pt'">
                            <xsl:value-of select="string-join(.//note[@type = 'genre']/rs, '/')"/>
                        </xsl:when>
                        <xsl:when test="$language = 'de'">
                            <xsl:for-each select="$genres">
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
                                <xsl:if test="position() != last()">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$language = 'en'">
                            <xsl:for-each select="$genres">
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
                                <xsl:if test="position() != last()">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise> </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <!-- documents: events per TEI file -->
                    <xsl:when test="contains($title, 'BNP') or contains($title, 'CP')">
                        <events>
                            <xsl:attribute name="title">
                                <xsl:value-of
                                    select="replace(.//titleStmt/title/normalize-space(.), '/E3', '')"/>
                            </xsl:attribute>
                            <xsl:for-each select=".//origDate">
                                <xsl:attribute name="start">
                                    <xsl:value-of select="@from | @when | @notAfter | @notBefore"/>
                                </xsl:attribute>
                            </xsl:for-each>
                            <xsl:if test=".//origDate/@to">
                                <xsl:attribute name="end">
                                    <xsl:value-of select=".//origDate/@to"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if
                                test=".//origDate/@from and .//origDate/@to">
                                <xsl:attribute name="durationEvent">
                                    <xsl:text>false</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when
                                    test=".//origDate/@from and .//origDate/@to">
                                    <xsl:attribute name="classname">
                                        <xsl:text>special_event document</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="classname">
                                        <xsl:text>document</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="link">
                                <xsl:variable name="filename" select=".//idno[@type = 'filename']"/>
                                <xsl:value-of
                                    select="concat(substring-before($basepath, '/pessoa'), '/', $language, '/doc/', substring-before($filename, '.xml'))"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="icon">
                                <xsl:text>resources/images/circle_event.png</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$author"/>
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select=".//origDate"/>
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="$genre-text"/>
                            <xsl:text>.</xsl:text>
                        </events>
                    </xsl:when>
                    <!-- publications: events per journal publication -->
                    <xsl:otherwise>
                        <xsl:variable name="link">
                            <xsl:variable name="filename" select=".//idno[@type = 'filename']"/>
                            <xsl:value-of
                                select="concat(substring-before($basepath, '/pessoa'), '/', $language, '/pub/', substring-before($filename, '.xml'))"
                            />
                        </xsl:variable>
                        <xsl:for-each select=".//sourceDesc/biblStruct">
                            <events>
                                <xsl:attribute name="title">
                                    <xsl:value-of
                                        select=".//title[@level='a']/normalize-space(.)"/>
                                </xsl:attribute>
                                <xsl:for-each select=".//imprint/date">
                                    <xsl:attribute name="start">
                                        <xsl:value-of select="@from | @when | @notAfter | @notBefore"/>
                                    </xsl:attribute>
                                </xsl:for-each>
                                <xsl:if test=".//imprint/date/@to">
                                    <xsl:attribute name="end">
                                        <xsl:value-of select=".//imprint/date/@to"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:if
                                    test=".//imprint/date/@from and .//imprint/date/@to">
                                    <xsl:attribute name="durationEvent">
                                        <xsl:text>false</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when
                                        test=".//imprint/date/@from and .//imprint/date/@to">
                                        <xsl:attribute name="classname">
                                            <xsl:text>special_event publication</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="classname">
                                            <xsl:text>publication</xsl:text>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="link">
                                    <xsl:value-of select="$link"/>
                                </xsl:attribute>
                                <xsl:attribute name="icon">
                                    <xsl:text>resources/images/circle_event.png</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$author"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select=".//imprint/date"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="$genre-text"/>
                                <xsl:text>.</xsl:text>
                            </events>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </data>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
