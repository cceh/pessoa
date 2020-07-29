<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <!-- Author: Ulrike Henny-Krahmer -->
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    <xsl:template match="teiHeader"/>
    <xsl:template match="text">
        <div>
            <xsl:if test="@corresp">
                <xsl:attribute name="id" select="substring-after(@corresp,'#')"/>
            </xsl:if>
            <style type="text/css">
                .lg {margin: 15px 0;}
                h2.center {text-align: center;}
                div.poem {margin: 20px 0;}
                p.indent {display: inline-block; text-indent: 1em; margin: 0;}
                div.ab-right {text-align: right;}
            </style>
            <xsl:apply-templates />
        </div>
        <xsl:apply-templates select="//note[@type='summary']"/>
    </xsl:template>
    
    <!-- Editorial notes -->
    <xsl:template match="note[@type='summary']">
        <div class="editorial-note">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="ref[@target[not(contains(.,' '))]]">
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
    
    <!-- links with several destinations -->
    <xsl:template match="ref[@target[contains(.,' ')]]">
        <span class="links">
            <xsl:apply-templates/>
            <span class="tooltiptext">
                <xsl:for-each select="tokenize(normalize-space(@target),'\s')">
                    <a class="link" href="{.}"><xsl:value-of select="."/></a>
                    <xsl:if test="position() != last()"><br/></xsl:if>
                </xsl:for-each>
            </span>
        </span>
    </xsl:template>
    
    <xsl:template match="p">
        <p>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </p>
    </xsl:template>
    
    
    <xsl:template match="head[not(@type='sub')][not(ancestor::div[2])]">
        <h1>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </h1>
    </xsl:template>
    
    <xsl:template match="head[@type='sub'][not(ancestor::div[2])]">
        <h2>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </h2>
    </xsl:template>
    
    <xsl:template match="head[not(@type='sub')][ancestor::div[2]]">
        <h2>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </h2>
    </xsl:template>
    
    <xsl:template match="head[@type='sub'][ancestor::div[2]]">
        <h3>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </h3>
    </xsl:template>
    
    <xsl:template match="head[@type='sub'][ancestor::div[3]]">
        <h4>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </h4>
    </xsl:template>
    
    <xsl:template match="floatingText[@type='letter']">
        <div>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">letter <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">letter</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="opener">
        <div class="opener">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="closer">
        <div class="closer">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template name="rend">
        <xsl:choose>
            <xsl:when test="@rend='right'">
                <xsl:attribute name="class">right</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='center'">
                <xsl:attribute name="class">center</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='indent-first'">
                <xsl:attribute name="class">indent-first</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='indent-second'">
                <xsl:attribute name="class">indent-second</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='indent'">
                <xsl:attribute name="class">indent</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='small'">
                <xsl:attribute name="class">small</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='small indent'">
                <xsl:attribute name="class">small indent</xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="div[@type='poem']">
        <div class="poem">
            <xsl:if test="@corresp">
                <xsl:attribute name="id" select="substring-after(@corresp,'#')"/>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="div[not(@type)]">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="lg">
        <div>
            <xsl:choose>
                <!-- center the whole block of lines -->
                <xsl:when test="@rend='center'">
                    <xsl:attribute name="class">lg center</xsl:attribute>
                    <!-- estimate the width of the block -->
                    <xsl:variable name="width" select="max(.//l//string-length(string-join(text()[not(ancestor::note) and not(ancestor::app)],' '))) * 0.6"/>
                    <xsl:attribute name="style">width: <xsl:value-of select="$width"/>em;</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">lg</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    
    <xsl:template match="l">
        <xsl:apply-templates /><br />
    </xsl:template>
    
    <xsl:template match="l[@rend='indent']">
        <p class="indent">
            <xsl:apply-templates />
        </p>
        <br />
    </xsl:template>
    
    <xsl:template match="dateline">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">dateline <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">dateline</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </p>
    </xsl:template>
    
    <xsl:template match="salute">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">salute <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">salute</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </p>
    </xsl:template>
    
    <xsl:template match="signed">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">signed <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">signed</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </p>
    </xsl:template>
    
    <xsl:template match="bibl">
        <p>
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:attribute name="class">bibl <xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">bibl</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="ab[@rend='right'][not(@type)]">
        <div class="ab-right">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="ab[@rend='right'][@type]">
        <div class="ab-right">
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="hi[@rend='italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    
    <xsl:template match="hi[@rend='bold']">
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>
    
    <xsl:template match="hi[@rend='big']">
        <span class="big">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="hi[@rend='underline']">
        <span class="underline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="hi[@rend='superscript']">
        <span class="superscript">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="lb">
        <br/>
    </xsl:template>
    
    <!-- apparatus -->
    <xsl:template match="app">
        <span class="app-lemma"><xsl:apply-templates select="lem"/><span class="app-text">
            <span>
                <xsl:for-each select="rdg">
                    <span>
                        <xsl:variable name="rdg" select="."/>
                        <span class="wit">
                            <xsl:for-each select="$rdg/@wit/tokenize(.,' ')">
                                <xsl:value-of select="replace(substring-after(.,'#'),'_',', ')"/>
                                <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
                            </xsl:for-each><xsl:text>:</xsl:text>
                        </span>
                        <span class="rdg"><xsl:apply-templates select="$rdg"/></span>
                    </span>
                </xsl:for-each>
            </span>
        </span></span>
    </xsl:template>
    
    
</xsl:stylesheet>