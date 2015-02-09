<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
    
    version="2.0">
   

    
    <xsl:template match="/">


        <xsl:for-each select="//TEI">
            <!--<xsl:result-document href="events.xml">-->
           
                <events>
                    <xsl:attribute name="title">
                        <xsl:value-of select="//title/normalize-space(.)"/>
                    </xsl:attribute>

                    

                    <!--<note type="genre">
                        <rs type="genre" key="lista_editorial">Lista editorial</rs>-->
                        <!--<rs type="genre" key="nota_editorial">Nota
                                                    editorial</rs>-->
                   <!-- </note>-->
                    
                    <xsl:for-each select=".//origDate">
                     <xsl:attribute name="start">
                        <xsl:value-of select=".//@from|@when|@notAfter|@notBefore"/>
                    </xsl:attribute>
                    </xsl:for-each>
                   
                   
                    <xsl:if test=".//@to">
                        <xsl:attribute name="end">
                            <xsl:value-of select=".//@to"/>
                        </xsl:attribute>
                    </xsl:if>
                   
                   
                    <xsl:if test=".//@from and .//@to">
                        <xsl:attribute name="durationEvent">
                            <xsl:text>true</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    
                    <xsl:if test=".//@from and .//@to">
                        <xsl:attribute name="classname">
                            <xsl:text>special_event</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    
                    
                   <!--1. durationEvent="true" classname="special_event" bei strat-und end-attributes müssen rein-->
                    <!--2. link muss angepasst werden-->
                    
                    <!--<xsl:choose>
                        <xsl:when test=".//@from|@when|@notAfter|@notBefore">
                            <xsl:attribute name="start">
                                <xsl:value-of select=".//origDate/@from|@when|@notAfter|@notBefore"/>
                            </xsl:attribute>
                        </xsl:when>    
                    </xsl:choose>  -->   
                    <!--<xsl:if test=".//@to">
                        <xsl:attribute name="end">
                            <xsl:value-of select=".//@to"/>
                        </xsl:attribute>    
                    </xsl:if>
                    -->
                 <!--   
                    <xsl:if test=".//@from|@when|@notAfter|@notBefore">
                    <xsl:attribute name="start">
                        <xsl:value-of select=".//origDate/@from|@when|@notAfter|@notBefore"/>
                    </xsl:attribute>
                    </xsl:if>
                    
                    
                    <xsl:if test=".//@to">
                        <xsl:attribute name="end">
                            <xsl:value-of select=".//@to"/>
                        </xsl:attribute>    
                    </xsl:if>-->
                    
                    <xsl:attribute name="caption">
                        <xsl:value-of select=".//origDate"/>
                    </xsl:attribute>
             
             
                        <xsl:attribute name="link">
                            <xsl:value-of select=".//idno"/>
                        </xsl:attribute>
                    
                    Fernando Pessoa,<xsl:value-of select=".//origDate"/>,<xsl:value-of select=".//rs"/>
                </events>

            <!--</xsl:result-document>-->
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

<!--<event start="1683-03-20" title="Stockholm" color="#CC0000" textColor="#000000">
    Aufbruch der Gesandtschaft aus Stockholm zum russischen und persischen Hof
    (unter der Leitung des Holländers Ludwig Fabritius)
</event>-->


<!--<xsl:for-each select="collection('file:///c:/someDir/?select=*.*')">
    <!-\- et cetera -\->
</xsl:for-each>-->