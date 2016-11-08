<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">

    <!-- Authors: Ulrike Henny, Alena Geduldig -->

    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Header & Text -->
    <xsl:template match="teiHeader" mode="#default deletion addition"/>
    <xsl:template match="text" mode="#default deletion addition">
        <div class="text">
            <xsl:apply-templates/>
        </div>
        <xsl:apply-templates select="//msDesc[@type = 'prose']"/>
    </xsl:template>

    <!-- Editorial notes and interventions -->
    <xsl:template match="msDesc[@type = 'prose']" mode="#default deletion addition">
        <div class="editorial-note">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="ref[@target]" mode="#default deletion addition">
        <a class="link">
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="starts-with(@target, 'http://')">
                        <xsl:value-of select="@target"/>
                    </xsl:when>
                    <xsl:otherwise>../data/doc/<xsl:value-of select="@target"/></xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="supplied" mode="#default deletion addition"/>

    <!-- Structure of the text -->
    <xsl:template match="head" mode="#default deletion addition">
        <h2>
            <xsl:if test="@rend">
                <xsl:attribute name="class" select="@rend"/>
            </xsl:if>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <!-- Listen -->
    <xsl:template match="list" mode="#default deletion addition">
        <div>
            <xsl:choose>
                <xsl:when test="(preceding-sibling::*[1][name() = 'label'] and @rend = 'indent') or @rend = 'indent'">
                    <xsl:attribute name="class">list indent</xsl:attribute>
                </xsl:when>
                <xsl:when test="preceding-sibling::*[1][name() = 'label'] or @rend = 'inline'">
                    <xsl:attribute name="class">list inline</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">list</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="item" mode="#default deletion addition">
        <div>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:variable name="rend">
                        <xsl:choose>
                            <xsl:when
                                test="contains(@rend, 'indent-2') and following-sibling::label">
                                <xsl:value-of select="replace(@rend, 'indent-2', 'indent-2-label')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@rend"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:attribute name="class">item <xsl:value-of select="$rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">item</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="label" mode="#default deletion addition">
        <span>
            <xsl:choose>
                <xsl:when test="following-sibling::*[1][name() = 'list']">
                    <xsl:attribute name="class"><xsl:value-of select="string-join(('label','inline',@rend),' ')"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class"><xsl:value-of select="string-join(('label',@rend),' ')"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Tabellen -->
    <xsl:template match="table" mode="#default deletion addition">
        <table>
            <xsl:if test="@rend">
                <xsl:attribute name="class" select="@rend"/>
            </xsl:if>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xsl:template match="row" mode="#default deletion addition">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="cell" mode="#default deletion addition">
        <td>
            <xsl:if test="@rend">
                <xsl:attribute name="class" select="@rend"/>
            </xsl:if>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <!-- Table structure for divs in columns / floating divs -->
    <xsl:template match="div[div[@rend = ('left', 'center', 'right')]]"
        mode="#default deletion addition">
        <table>
            <tr>
                <xsl:for-each select="child::*">
                    <xsl:choose>
                        <xsl:when test="name() = 'div' and @rend">
                            <td>
                                <xsl:apply-templates/>
                            </td>
                        </xsl:when>
                        <xsl:when test="name() = 'metamark' and @rend = 'line-vertical'">
                            <td class="line-vertical"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </tr>
        </table>
    </xsl:template>

    <xsl:template match="p" mode="#default deletion addition">
        <p>
            <xsl:if test="@rend">
                <xsl:attribute name="class" select="@rend"/>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="ab" mode="#default deletion addition">
        <p>
            <xsl:if test="@rend">
                <xsl:attribute name="class" select="@rend"/>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Metamarks -->
    <!-- Lines -->
    <xsl:template match="metamark[@rend = 'line-14'][@function = ('distinct', 'end')]"
        mode="#default deletion addition">
        <hr class="line line-14"/>
    </xsl:template>
    <xsl:template match="metamark[@rend = 'line-14'][@function = ('placeholder')]"
        mode="#default deletion addition">
        <hr class="line line-14 inline"/>
    </xsl:template>
    
    <xsl:template match="metamark[@rend = 'line-24'][@function = ('distinct', 'end')]"
        mode="#default deletion addition">
        <hr class="line line-24"/>
    </xsl:template>
    <xsl:template match="metamark[@rend = 'line-24'][@function = ('placeholder')]"
        mode="#default deletion addition">
        <hr class="line line-24 inline"/>
    </xsl:template>
    
    <xsl:template match="metamark[@rend = 'line-34'][@function = ('distinct', 'end')]"
        mode="#default deletion addition">
        <hr class="line line-34"/>
    </xsl:template>
    <xsl:template match="metamark[@rend = 'line-34'][@function = ('placeholder')]"
        mode="#default deletion addition">
        <hr class="line line-34 inline"/>
    </xsl:template>
    
    <xsl:template match="metamark[@rend = 'line-44'][@function = ('distinct', 'end')]"
        mode="#default deletion addition">
        <hr class="line line-44"/>
    </xsl:template>
    <xsl:template match="metamark[@rend = 'line-44'][@function = ('placeholder')]"
        mode="#default deletion addition">
        <hr class="line line-44 inline"/>
    </xsl:template>
    

    <!-- Quotes -->
    <xsl:template match="metamark[@rend = 'quotes'][@function = 'ditto']"
        mode="#default deletion addition">
        <span class="metamark quotes ditto">"</span>
    </xsl:template>
    <xsl:template match="metamark[@rend = 'quotes-14'][@function = 'ditto']"
        mode="#default deletion addition">
        <span class="metamark quotes-14 ditto">"</span>
    </xsl:template>
    <xsl:template match="metamark[contains(@rend, 'line')][@function = 'ditto']"
        mode="#default deletion addition">
        <span class="metamark line ditto">
            <xsl:choose>
                <xsl:when test="@rend = 'line-18'">
                    <hr class="line line-18 inline"/>
                </xsl:when>
                <xsl:when test="@rend = 'line-14'">
                    <hr class="line line-14 inline"/>
                </xsl:when>
                <xsl:when test="@rend = 'line-24'">
                    <hr class="line line-24 inline"/>
                </xsl:when>
                <xsl:when test="@rend = 'line-34'">
                    <hr class="line line-34 inline"/>
                </xsl:when>
                <xsl:when test="@rend = 'line-44'">
                    <hr class="line line-44 inline"/>
                </xsl:when>
            </xsl:choose>
        </span>
    </xsl:template>

    <!-- Space -->
    <xsl:template match="metamark[@rend = 'space'][@function = 'distinct'][parent::item or parent::head]"
        mode="#default deletion addition"> &#x2003; </xsl:template>
    <xsl:template
        match="metamark[@rend = 'space'][@function = 'distinct'][parent::list | parent::div]"
        mode="#default deletion addition">
        <br/>
    </xsl:template>

    <!-- Brackets -->
    <xsl:template match="metamark[@rend = 'curly-bracket'][@function = 'grouping']"
        mode="#default deletion addition">
        <xsl:choose>
            <xsl:when test="parent::note[@place = 'margin-right']">
                <span class="grouping-right">
                    <xsl:if test="parent::note[@target[contains(., 'range')]]">
                        <xsl:variable name="target" select="parent::note/@target"/>
                        <xsl:variable name="items"
                            select="tokenize(substring-before(substring-after($target, 'range('), ')'), ',')"/>
                        <xsl:variable name="range"
                            select="number(substring-after($items[2], 'I')) - number(substring-after($items[1], 'I')) + 1"/>
                        <xsl:attribute name="style"> font-size: <xsl:value-of select="$range * 2"
                            />em; </xsl:attribute>
                    </xsl:if> }<xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="parent::note[@place = 'margin-left']">
                <span class="grouping-left">
                    <xsl:if test="parent::note[@target[contains(., 'range')]]">
                        <xsl:variable name="target" select="parent::note/@target"/>
                        <xsl:variable name="items"
                            select="tokenize(substring-before(substring-after($target, 'range('), ')'), ',')"/>
                        <xsl:variable name="range"
                            select="number(substring-after($items[2], 'I')) - number(substring-after($items[1], 'I')) + 1"/>
                        <xsl:attribute name="style"> font-size: <xsl:value-of select="$range * 2"
                            />em; </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>{ </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="metamark/label" mode="#default deletion addition">
        <span>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">label <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">label</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Notes -->
    <!--<xsl:template match="note[@n='2']" mode="#default deletion addition">
        
    </xsl:template>-->
    
    <xsl:template match="note[@place = 'margin-right']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-right"/>
    </xsl:template>

    <xsl:template match="note[@place = 'margin-left']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-left"/>
    </xsl:template>

    <xsl:template match="note[@place = 'center']" mode="#default deletion addition">
        <div class="note center">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="note[@type='addition'][not(@place)][ancestor::item]" mode="#default deletion addition">
        <span>
            <xsl:if test="@rend">
                <xsl:attribute name="class" select="concat('note ', @rend)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template name="note-margin-right">
        <span class="note margin-right">
            <xsl:if test="@target[contains(., 'range')]">
                <xsl:variable name="target" select="@target"/>
                <xsl:variable name="items"
                    select="tokenize(substring-before(substring-after($target, 'range('), ')'), ',')"/>
                <xsl:variable name="range"
                    select="number(substring-after($items[2], 'I')) - number(substring-after($items[1], 'I')) + 1"/>
                <xsl:attribute name="style"> top: -<xsl:value-of select="$range"/>em;
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template name="note-margin-left">
        <span>
            <xsl:choose>
                <xsl:when test="@target[contains(., 'range')]">
                    <xsl:variable name="target" select="@target"/>
                    <xsl:variable name="items"
                        select="tokenize(substring-before(substring-after($target, 'range('), ')'), ',')"/>
                    <xsl:variable name="range"
                        select="number(substring-after($items[2], 'I')) - number(substring-after($items[1], 'I')) + 1"/>
                    <xsl:attribute name="style"> top: -<xsl:value-of select="$range"/>em;
                    </xsl:attribute>
                    <xsl:attribute name="class">note margin-left range</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">note margin-left</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Highlighting -->
    <xsl:template match="hi[@rend = 'underline']" mode="#default deletion addition">
        <span class="underline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'italic']" mode="#default deletion addition">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'circled']" mode="#default deletion addition">
        <span class="circled">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rend = 'superscript']" mode="#default deletion addition">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>

    <!-- Entities -->
    <xsl:template match="rs[@type = 'person']" mode="#default deletion addition">
        <span class="person {@key}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="rs[@type = 'place']" mode="#default deletion addition">
        <span class="place">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="rs[@type = 'journal']" mode="#default deletion addition">
        <span class="journal {@key}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="rs[@type = 'work']" mode="#default deletion addition">
        <span class="work {@key}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="rs[@type = 'text']" mode="#default deletion addition">
        <span class="text {replace(.,'[“”.\s]','')}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Breaks -->
    <xsl:template match="lb" mode="#default deletion addition">
        <br/>
    </xsl:template>
    <xsl:template match="pb" mode="#default deletion addition"/>

    <!-- Abbreviations -->
    <xsl:template match="expan" mode="#default deletion addition"/>

    <!-- Gaps -->
    <xsl:template match="gap[@reason = 'selection']" mode="#default deletion addition"/>
    <xsl:template match="gap[@reason = 'illegible']" mode="#default deletion addition">
        <span title="ilegível">†</span>
    </xsl:template>

    <!-- Additions -->
    <xsl:template match="add[@n = '2'][@place = 'above']" mode="#default deletion addition">
        <span class="above">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="add[@place='below']" mode="#default deletion addition">
        <span class="below">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="seg[@type = 'anchor']" mode="#default deletion addition">
        <span class="anchor">
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!-- Deletions -->
    <xsl:template match="delSpan">
        <xsl:variable name="anchorID" select="@spanTo/substring-after(., '#')"/>
        <div class="delSpan">
            <xsl:apply-templates
                select="following-sibling::*[following::anchor[@xml:id = $anchorID]]"
                mode="deletion"/>
        </div>
    </xsl:template>

    <xsl:template
        match="*[preceding-sibling::delSpan][following::anchor[@xml:id = current()/preceding-sibling::delSpan/@spanTo/substring-after(., '#')]]"
        mode="#default" priority="100"/>
    <xsl:template
        match="*[preceding-sibling::addSpan][following::anchor[@xml:id = current()/preceding-sibling::addSpan/@spanTo/substring-after(., '#')]]"
        mode="#default" priority="100"/>

    <!-- einzublendende Spans -->
    <xsl:template match="addSpan[@n='2']">
        <xsl:variable name="anchorID" select="@spanTo/substring-after(.,'#')" />
        <xsl:apply-templates select="following-sibling::*[following::anchor[@xml:id=$anchorID]]" mode="addition" />
    </xsl:template>

    <xsl:template match="del[@rend = 'overstrike'] | seg[@rend = 'overstrike']"
        mode="#default deletion addition">
        <span class="deletion overstrike">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="del[@rend = 'overtyped'] | seg[@rend = 'overtyped']"
        mode="#default deletion addition">
        <span class="deletion overtyped">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Choices -->
    <xsl:template match="choice[seg[@n='1'] and seg[@n='2']]" mode="#default deletion addition">
        <span class="choice">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>
