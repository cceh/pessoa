<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:import href="doc.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    <!-- externer Parameter lb: yes|no
    (Zeilenumbrüche anzeigen oder nicht) -->
    <xsl:param name="lb" />
    <!-- externer Parameter abbr: yes|no
    (Abkürzungen anzeigen oder nicht) -->
    <xsl:param name="abbr" />
    
    
    <!-- Einrückungen werden hier nicht berücksichtigt -->
    <xsl:template match="ab[@rend='indent'] | ab[@rend='offset'] | seg[@rend='indent']">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <!-- choices -->
    <!-- Abkürzungen und Auflösungen: Darstellung der aufgelösten Form -->
    <xsl:template match="choice[abbr and expan[ex]]">
        <xsl:choose>
            <xsl:when test="$abbr = 'yes'">
                <xsl:apply-templates select="abbr/text() | abbr/child::*" />
                <xsl:if test="following-sibling::choice[1]">
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>           
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="abbr/metamark[@function='ditto']">
                        <span class="ditto">
                            <xsl:apply-templates select="expan/text() | expan/child::*"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="expan/text() | expan/child::*"/>                     
                        <xsl:if test="following-sibling::choice[1]">
                            <xsl:text>&#160;</xsl:text>
                        </xsl:if>     
                    </xsl:otherwise>
                </xsl:choose>            
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
  
    <xsl:template match="choice[abbr and expan[not(ex)]]">
        <span class="expan">[<xsl:apply-templates select="expan/text() | expan/child::*"/>]</span>
    </xsl:template>
 
    
    <xsl:template match="abbr"/>
    <xsl:template match="ex">
        <span class="ex">[<xsl:apply-templates />]</span>
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
    <xsl:template match="lb[not(preceding-sibling::*[1][local-name()='pc'])][not(ancestor::note)][not(ancestor::add)]">
        <xsl:choose>
            <xsl:when test="$lb = 'yes'">
                <br />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="lb[preceding-sibling::*[1][local-name()='pc']]">
        <xsl:if test="$lb = 'yes'">
            <br />
        </xsl:if>
    </xsl:template>
        
    <xsl:template match="pc">
        <xsl:if test="$lb = 'yes'">
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>
    
    <!-- Trotz Aufhebung der lb's soll am Rand genug Platz für Notes bleiben --> 
    <xsl:template match="text">
        <div class="text">          
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:if> 
            <xsl:attribute name="style">
                <xsl:if test="//note[contains(@place,'left')]">
                    padding-left: 150px;  
                </xsl:if>
                <xsl:if test="//note[contains(@place,'right')]">
                    padding-right:150px;
                </xsl:if>
                <xsl:if test="@xml:id='bnp-e3-87-39r'">
                    padding-right: 60px;
                </xsl:if>
            </xsl:attribute>   
            <xsl:apply-templates/>         
        </div>
    </xsl:template>
    
    <!-- editorische Ergänzungen anzeigen -->
    <xsl:template match="supplied">
        <span class="supplied" title="lacuna no original">
            <xsl:choose>
                <xsl:when test="not(node()) or note">□</xsl:when>
                <xsl:otherwise>
                    &lt;<xsl:apply-templates />&gt;
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <!-- special case 180r -->
    <xsl:template match="text[@xml:id='bnp-e3-180r']//note[@place='margin top right']">
        <span class="note addition margin top right" style="right: 0px;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="text[@xml:id='bnp-e3-180r']//note[@place='margin left'][supplied]">
        <span class="note addition margin left" style="left: -135px;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>