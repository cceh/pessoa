<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:import href="http://localhost:8080/exist/rest/db/apps/pessoa/xslt/doc.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <xsl:template match="text">
        <div class="text edited">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="ab[@rend='indent'] | ab[@rend='offset'] | seg[@rend='indent']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="abbr"/>
    <xsl:template match="ex">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="supplied">
        <span class="supplied" title="{@reason}">
            <xsl:choose>
                <xsl:when test="not(node()) or note">□</xsl:when>
                <xsl:otherwise>
                    &lt;<xsl:apply-templates />&gt;
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <!-- choices -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[2]/add/text()"/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place='above']">
        <span class="choice">
            <span class="seg">
                <xsl:apply-templates select="seg[2]/add/text()"/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[abbr and expan]">
        <xsl:apply-templates select="expan/text() | expan/ex/text()"/>
    </xsl:template>
    <xsl:template match="seg/add[@n='2']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="subst[del/@n and add/@n]">
        <xsl:apply-templates select="add/text()"/>
    </xsl:template>
    <xsl:template match="subst[del[not(@n)] and add[not(@n)]]">
        <xsl:apply-templates select="add/text()"/>
    </xsl:template>
    <xsl:template match="del"/>
    
    <!-- notes addition -->
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
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])]">
        <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:template>
    <xsl:template match="lb[preceding-sibling::*[1][local-name()='pc']]"/>
    <xsl:template match="pc"/>
</xsl:stylesheet>