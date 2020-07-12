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
            <xsl:apply-templates select="//note[@type='summary']"/>
        </div>
    </xsl:template>
    
    <!-- Editorial notes -->
    <xsl:template match="note[@type='summary']">
        <div class="editorial-note">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="ref[@target]">
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
    
    <xsl:template match="p">
        <p>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </p>
    </xsl:template>
    
    
    <xsl:template match="head">
        <h2>
            <xsl:call-template name="rend" />
            <xsl:apply-templates />
        </h2>
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
    
    <xsl:template match="lg">
        <div>
            <xsl:choose>
                <!-- center the whole block of lines -->
                <xsl:when test="@rend='center'">
                    <xsl:attribute name="class">lg center</xsl:attribute>
                    <!-- estimate the width of the block -->
                    <xsl:variable name="width" select="max(//l//string-length(string-join(text()[not(ancestor::note)],' '))) * 0.5"/>
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
        <p class="dateline"><xsl:apply-templates /></p>
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
        <p type="bibl">
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
            <table>
                <tr>
                    <xsl:variable name="lem" select="lem"/>
                    <td class="wit">
                        <xsl:for-each select="$lem/@wit/tokenize(.,' ')">
                            <!--<xsl:variable name="witness" select="$lem/ancestor::TEI//biblStruct[@xml:id=$lem/@wit/substring-after(.,'#')]"/>
                            <xsl:variable name="witness_journal" select="$witness//rs[@type='periodical']"/>
                            <xsl:variable name="witness_date" select="$witness//date"/>
                            <xsl:variable name="witness_year">
                                <xsl:choose>
                                    <xsl:when test="$witness_date[@when]">
                                        <xsl:value-of select="$witness_date/@when/substring(.,1,4)"/>
                                    </xsl:when>
                                    <xsl:when test="$witness_date[@from and @to]">
                                        <xsl:value-of select="concat($witness_date/@from/substring(.,1,4),'-',$witness_date/@to/substring(.,1,4))"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:value-of select="concat($witness_journal, ' ', $witness_year)"/>-->
                            <xsl:value-of select="replace(substring-after(.,'#'),'_','. ')"/>
                            <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                        </xsl:for-each><xsl:text>:</xsl:text>
                    </td>
                    <td class="rdg"><xsl:value-of select="$lem"/></td>
                </tr>
                <xsl:for-each select="rdg">
                    <tr>
                        <xsl:variable name="rdg" select="."/>
                        <td class="wit">
                            <xsl:for-each select="$rdg/@wit/tokenize(.,' ')">
                                <!--<xsl:variable name="witness" select="$rdg/ancestor::TEI//biblStruct[@xml:id=substring-after(current(),'#')]"/>
                                <xsl:variable name="witness_journal" select="$witness//rs[@type='periodical']"/>
                                <xsl:variable name="witness_date" select="$witness//date"/>
                                <xsl:variable name="witness_year">
                                    <xsl:choose>
                                        <xsl:when test="$witness_date[@when]">
                                            <xsl:value-of select="$witness_date/@when/substring(.,1,4)"/>
                                        </xsl:when>
                                        <xsl:when test="$witness_date[@from and @to]">
                                            <xsl:value-of select="concat($witness_date/@from/substring(.,1,4),'-',$witness_date/@to/substring(.,1,4))"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:value-of select="concat($witness_journal, ' ', $witness_year)"/>-->
                                <xsl:value-of select="replace(substring-after(.,'#'),'_','. ')"/>
                                <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                            </xsl:for-each><xsl:text>:</xsl:text>
                        </td>
                        <td class="rdg"><xsl:value-of select="$rdg"/></td>
                    </tr>
                </xsl:for-each>
            </table>
        </span></span>
    </xsl:template>
    
    
</xsl:stylesheet>