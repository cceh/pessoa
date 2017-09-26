<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    
    <!-- written by Ulrike Henny-Krahmer, 2017 -->

    <xsl:template match="/">

        <xsl:call-template name="network-basis-all"/>
        <!--<xsl:call-template name="network-basis-years"/>-->

    </xsl:template>


    <xsl:template name="network-basis-years">
        <xsl:variable name="years"
            select="
                for $i in 1921 to 1935
                return
                    string($i)"/>
        <!-- 1913-1935 -->

        <xsl:for-each select="$years">
            <xsl:result-document href="networks/network-basis-{.}.xml">
                <xsl:variable name="year" select="."/>
                <persons>
                    <!-- Alle Personen/Namen durchgehen -->
                    <xsl:for-each select="doc('../data/lists.xml')//listPerson/person[@xml:id]">
                        <xsl:variable name="person-id" select="@xml:id"/>
                        <person>
                            <id>
                                <xsl:value-of select="$person-id"/>
                            </id>
                            <name>
                                <xsl:value-of select="persName[1]"/>
                            </name>
                            <count>
                                <xsl:value-of
                                    select="
                                    count(collection('../data/doc')[(string(ceiling(((number(//origDate/substring(@to, 1, 4)) + number(//origDate/substring(@from, 1, 4))) div 2))) = $year)
                                    or
                                        (//origDate/substring(@notBefore, 1, 4) = $year)
                                        or (//origDate/substring(@notAfter, 1, 4) = $year)
                                        or (//origDate/substring(@when, 1, 4) = $year)]//body//rs[@type = 'name'][@key = $person-id])"
                                />
                            </count>
                            <status>
                                <xsl:value-of select="note[@type = 'ontological-status']"/>
                            </status>
                            <documents>
                                <!-- Alle Dokumente durchgehen; kommt die aktuelle Person in dem Dokument überhaupt vor? -->
                                <xsl:for-each
                                    select="
                                        collection('../data/doc')[(//origDate/substring(@when, 1, 4) = $year) or
                                        (//origDate/substring(@notBefore, 1, 4) = $year)
                                        or (//origDate/substring(@notAfter, 1, 4) = $year)
                                        or (string(ceiling(((number(//origDate/substring(@to, 1, 4)) + number(//origDate/substring(@from, 1, 4))) div 2))) = $year)]//body[exists(.//rs[@type = 'name'][@key = $person-id])]">
                                    <document>
                                        <filename>
                                            <xsl:value-of
                                                select="ancestor::TEI//idno[@type = 'filename']"/>
                                        </filename>
                                        <date when="{ancestor::TEI//origDate/@when}"
                                            from="{ancestor::TEI//origDate/@from}"
                                            to="{ancestor::TEI//origDate/@to}"
                                            notBefore="{ancestor::TEI//origDate/@notBefore}"
                                            notAfter="{ancestor::TEI//origDate/@notAfter}">
                                            <xsl:value-of select="ancestor::TEI//origDate"/>
                                        </date>
                                        <self>
                                            <id>
                                                <xsl:value-of select="$person-id"/>
                                            </id>
                                            <count>
                                                <xsl:value-of
                                                  select="count(.//rs[@type = 'name'][@key = $person-id])"
                                                />
                                            </count>
                                        </self>
                                        <!-- Welche anderen Personen kommen vor? Jede davon nur einmal berücksichtigen
                                   (deshalb for-each-group). Anschließend zählen, wie oft die Person auf dem 
                                    Dokument vorkommt. -->
                                        <xsl:for-each-group
                                            select=".//rs[@type = 'name'][not(@key = $person-id)]"
                                            group-by="@key">
                                            <person>
                                                <id>
                                                  <xsl:value-of select="@key"/>
                                                </id>
                                                <count>
                                                  <xsl:value-of select="count(current-group())"/>
                                                </count>
                                            </person>
                                        </xsl:for-each-group>
                                    </document>
                                </xsl:for-each>
                            </documents>
                        </person>
                    </xsl:for-each>
                </persons>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="network-basis-all">
        <xsl:result-document href="network-basis.xml">
            <persons>
                <!-- Alle Personen/Namen durchgehen -->
                <xsl:for-each select="doc('../data/lists.xml')//listPerson/person[@xml:id]">
                    <xsl:variable name="person-id" select="@xml:id"/>
                    <person>
                        <id>
                            <xsl:value-of select="$person-id"/>
                        </id>
                        <name>
                            <xsl:value-of select="persName[1]"/>
                        </name>
                        <count>
                            <xsl:value-of
                                select="count(collection('../data/doc')//body//rs[@type = 'name'][@key = $person-id])"
                            />
                        </count>
                        <status>
                            <xsl:value-of select="note[@type = 'ontological-status']"/>
                        </status>
                        <documents>
                            <!-- Alle Dokumente durchgehen; kommt die aktuelle Person in dem Dokument überhaupt vor? -->
                            <xsl:for-each
                                select="collection('../data/doc')//body[exists(.//rs[@type = 'name'][@key = $person-id])]">
                                <document>
                                    <filename>
                                        <xsl:value-of
                                            select="ancestor::TEI//idno[@type = 'filename']"/>
                                    </filename>
                                    <date when="{ancestor::TEI//origDate/@when}"
                                        from="{ancestor::TEI//origDate/@from}"
                                        to="{ancestor::TEI//origDate/@to}"
                                        notBefore="{ancestor::TEI//origDate/@notBefore}"
                                        notAfter="{ancestor::TEI//origDate/@notAfter}">
                                        <xsl:value-of select="ancestor::TEI//origDate"/>
                                    </date>
                                    <self>
                                        <id>
                                            <xsl:value-of select="$person-id"/>
                                        </id>
                                        <count>
                                            <xsl:value-of
                                                select="count(.//rs[@type = 'name'][@key = $person-id])"
                                            />
                                        </count>
                                    </self>
                                    <!-- Welche anderen Personen kommen vor? Jede davon nur einmal berücksichtigen
                                   (deshalb for-each-group). Anschließend zählen, wie oft die Person auf dem 
                                    Dokument vorkommt. -->
                                    <xsl:for-each-group
                                        select=".//rs[@type = 'name'][not(@key = $person-id)]"
                                        group-by="@key">
                                        <person>
                                            <id>
                                                <xsl:value-of select="@key"/>
                                            </id>
                                            <count>
                                                <xsl:value-of select="count(current-group())"/>
                                            </count>
                                        </person>
                                    </xsl:for-each-group>
                                </document>
                            </xsl:for-each>
                        </documents>
                    </person>
                </xsl:for-each>
            </persons>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
