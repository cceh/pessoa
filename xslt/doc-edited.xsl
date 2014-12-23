<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:import href="http://localhost:8080/exist/rest/db/apps/pessoa/xslt/doc.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="text">
        <div class="text edited">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Einrückungen werden hier nicht berücksichtigt -->
    <xsl:template match="ab[@rend='indent'] | ab[@rend='offset'] | seg[@rend='indent']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- choices -->
    <!-- Abkürzungen und Auflösungen: Darstellung der aufgelösten Form -->
    <xsl:template match="choice[abbr and expan]">
        <xsl:apply-templates select="expan/text() | expan/ex/text()"/>
    </xsl:template>
    <xsl:template match="abbr"/>
    <xsl:template match="ex">
        <span class="ex"><xsl:apply-templates /></span>
    </xsl:template>
    
    <!-- Ersetzung von Pessoa selbst: etwas wird gelöscht, etwas anderes hinzugefügt
    hier: Anzeigen des Hinzugefügten (wenn dies nicht 2 Textstufen sind) -->
    <xsl:template match="subst[del[not(@n)] and add[not(@n)]]">
        <xsl:apply-templates select="add/text()"/>
    </xsl:template>
    <!-- Löschungen nicht anzeigen -->
    <xsl:template match="del"/>
    
    <!-- zusätzliche Bemerkungen am Rand -> für Lesefassung unten ausgeben -->
    <xsl:template match="ab[note[@type='addition'][contains(@place, 'margin')]]">
        <div>
            <h4 style="font-style: italic;" title="editorial note">Marginal remarks <xsl:value-of select="@n"/>:</h4>
            <xsl:for-each select="note">
                <span style="font-style: italic;" title="editorial note">
                    <xsl:choose>
                        <xsl:when test="contains(@target, 'range')">
                            <xsl:value-of select="substring-before(substring-after(@target, 'range(i'), ',')"/>-<xsl:value-of select="substring-before(substring-after(@target, ',i'), ')')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring-after(@target, 'i')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>: <xsl:apply-templates select="child::*[not(self::metamark)] | text()"/>
                <br/>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <!-- Zeilenumbrüche:
    wenn es ein Silbentrennzeichen gibt, dann nichts ausgeben
    wenn es kein Silbentrennzeichen gibt, dann ein Leerzeichen ausgeben
    -->
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])]">
        <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:template>
    <xsl:template match="lb[preceding-sibling::*[1][local-name()='pc']]"/>
    <xsl:template match="pc"/>
</xsl:stylesheet>