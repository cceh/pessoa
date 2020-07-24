<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <!-- Author: Ulrike Henny-Krahmer -->
    
    <xsl:import href="pub.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:param name="lang">pt</xsl:param>
    
    <xsl:template match="text">
        <div class="text prose">
            <xsl:if test="@corresp">
                <xsl:attribute name="id" select="substring-after(@corresp,'#')"/>
            </xsl:if>
            <style type="text/css">
                .lg {margin: 15px 0;}
                h2.center {text-align: center;}
                div.poem {margin: 20px 0;}
                div.ab-right {text-align: right;}
            </style>
            <xsl:apply-templates />
            <xsl:apply-templates select="//note[@type='summary']"/>
        </div>
    </xsl:template>
    
    <xsl:template match="titlePage">
        <div class="titlePage">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="docAuthor">
        <p class="docAuthor">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="titlePart">
        <xsl:choose>
            <xsl:when test="@type='main'">
                <h1><xsl:apply-templates/></h1>
            </xsl:when>
            <xsl:when test="@type='sub'">
                <h2><xsl:apply-templates/></h2>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="note[parent::titlePage]">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">note <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">note</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="argument">
        <div>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">argument <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">argument</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    
    <!-- notes that are comments on quotes or references, made by the editor -->
    <xsl:template match="quote[note[@type='comment'][@resp]] | rs[note[@type='comment'][@resp]] | seg[note[@type='comment'][@resp]]" priority="2">
        <span class="{name()} tooltip">
            <xsl:apply-templates select="child::*[name() != 'note'] | text()"/>
            <span class="tooltiptext"><xsl:apply-templates select="note"/></span>
        </span>
    </xsl:template>
    
    <xsl:template match="note[@type='comment'][@resp]">
        <span class="note editor">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- notes that are part of the text (see the corresponding JavaScript in page/prosa.html) -->
    <xsl:template match="note[not(@type)]">
        <span class="note">
            <span class="label"><xsl:apply-templates select="label"/></span>
            <span class="text"><xsl:apply-templates select="child::*[name() != 'label'] | text()"/></span>
        </span>
    </xsl:template>
    
    <!-- Entities -->
    <xsl:template match="rs[@type = 'name']">
        <span class="name {@key}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type = 'place']">
        <span class="place">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type = 'periodical']">
        <span class="journal {@key}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="rs[@type = 'work']">
        <span class="work {@key}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="rs[@type = 'title']">
        <span class="title {replace(.,'[“”.\s]','')}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- milestones -->
    <xsl:template match="milestone[@unit='section' or @unit='title']">
        <xsl:choose>
            <xsl:when test="@rend='asterisks'">
                <p class="milestone {@unit}">* * *</p>
            </xsl:when>
            <xsl:when test="@rend='asterisk'">
                <p class="milestone {@unit}">*</p>
            </xsl:when>
            <xsl:when test="@rend='space'">
                <p class="milestone {@unit}">&#x00A0;</p>
            </xsl:when>
            <xsl:when test="@rend='line'">
                <p class="milestone {@unit}">&#x2E3A;</p>
            </xsl:when>
            <xsl:when test="@rend='square'">
                <p class="milestone {@unit}">&#x25A0;</p>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- blocks -->
    <xsl:template match="ab[not(@type='formula')]">
        <p>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </p>
    </xsl:template>
    
    <xsl:template match="cit[parent::div and preceding-sibling::head]">
        <div>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">citation <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">citation</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/> 
        </div>
    </xsl:template>
    
    <!-- choice, corr, sic -->
    <!--<xsl:template match="choice[sic and corr]">
        <span class="corr tooltip">
            <xsl:apply-templates select="corr"/>
            <span class="tooltiptext">
                <strong>sic:</strong>&#x00A0;
                <em><xsl:apply-templates select="sic"/></em> <br/>
                <strong>corr:</strong>&#x00A0;
                <em><xsl:apply-templates select="corr"/></em>
            </span>
        </span>
    </xsl:template>-->
    
    <xsl:template match="choice[sic and corr]">
        <span class="corr">
            <xsl:apply-templates select="corr"/>
        </span>
    </xsl:template>
    
    <!-- additions -->
    <xsl:template match="add">
        <span class="addition">
            <xsl:apply-templates/>
            <span class="tooltiptext">
                <xsl:choose>
                    <xsl:when test="note[@type='comment'][@resp]">
                        <xsl:apply-templates select="note"/>
                    </xsl:when>
                    <xsl:otherwise>                        
                        <xsl:choose>
                            <xsl:when test="$lang = 'pt'">acréscimo</xsl:when>
                            <xsl:when test="$lang = 'de'">Ergänzung</xsl:when>
                            <xsl:otherwise>addition</xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </span>
    </xsl:template>
    
    <!-- abbreviation and expansion -->
    <xsl:template match="choice[abbr and expan]">
        <span class="abbreviation">
            <xsl:apply-templates select="abbr"/>
            <span class="tooltiptext">
                <xsl:apply-templates select="expan"/>
            </span>
        </span>
    </xsl:template>
    
    <xsl:template match="expan">
        <span class="expansion">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="ex">
        <xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
    </xsl:template>
    
    
    
    <!-- formulas -->
    <xsl:template match="ab[@type='formula']">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">formula <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">formula</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="seg[@type='division']">
        <span class="division">
            <xsl:apply-templates select="seg[@type='dividend' or @type='divisor']"/>
        </span>
    </xsl:template>

    <xsl:template match="seg[@type='dividend']">
        <span class="dividend">
            <xsl:apply-templates/>
        </span><br/>
    </xsl:template>
    
    <xsl:template match="seg[@type='divisor']">
        <span class="divisor">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- drama -->
    <xsl:template match="stage[parent::div][p]">
        <div>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">stage <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">stage</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="stage[parent::div][not(p)]">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">stage <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">stage</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="stage[parent::p or parent::sp]">
        <span>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">stage <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">stage</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="sp">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">speech <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">speech</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="speaker">
        <span class="speaker">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="p[parent::sp]">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>