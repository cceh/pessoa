<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    
    <xsl:template match="/">
        
        <xsl:variable name="period-names" select="('1913-1918', '1919-1927', '1928-1935', '1913-1915', '1916-1919', '1920-1927')"/>
        <xsl:variable name="periods">
            <periods>
                <xsl:for-each select="$period-names">
                    <period>
                        <name><xsl:value-of select="."/></name>
                        <years>
                            <xsl:for-each select="xs:integer(substring-before(., '-')) to xs:integer(substring-after(.,'-'))">
                                <year><xsl:value-of select="."/></year>
                            </xsl:for-each>
                        </years>
                    </period>
                </xsl:for-each>
            </periods>
        </xsl:variable>
        
        
        
        
        <xsl:for-each select="$periods//period">
            
            <xsl:variable name="curr-period" select="."/>
            
            <xsl:variable name="persons">
                <persons>
                    <xsl:for-each-group select="collection('networks?select=*.xml')//persons[substring-after(substring-before(tokenize(base-uri(.),'/')[last()],'.xml'),'network-basis-') = $curr-period//year]/person" group-by="id">
                        <person>
                            <id><xsl:value-of select="current-grouping-key()"/></id>
                            <name><xsl:value-of select="name"/></name>
                            <group><xsl:choose>
                                <xsl:when test="status = 'ficticious'">0</xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose></group>
                            <size><xsl:value-of select="sum(current-group()/count)"/></size>
                            <main><xsl:choose>
                                <xsl:when test="name = ('Fernando Pessoa', 'Ricardo Reis', 'Álvaro de Campos', 'Alberto Caeiro')">1</xsl:when>
                                <xsl:otherwise>0</xsl:otherwise>
                            </xsl:choose></main>
                            <xsl:if test="current-group()/documents/document">
                                <documents>
                                    <xsl:for-each select="current-group()/documents/document">
                                        <xsl:copy-of select="."/>
                                    </xsl:for-each>
                                </documents>
                            </xsl:if>
                        </person>
                    </xsl:for-each-group>
                </persons>
            </xsl:variable>
            
            
            <xsl:result-document href="networks/{name}.json">
                {
                "nodes": [
                <xsl:for-each select="$persons//persons/person">
                    {
                    "name": "<xsl:value-of select="name"/>",
                    "group": <xsl:value-of select="group"/>,
                    "size": <xsl:value-of select="size"/>,
                    "main": <xsl:value-of select="main"/>
                    }<xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                ],
                "links": [
                <xsl:for-each select="$persons//persons/person">
                    <xsl:if test="documents/document/person">
                        
                        <xsl:variable name="position-person" select="position()"/>
                        <xsl:variable name="curr" select="current()"/>
                        <xsl:for-each-group select=".//person[empty(index-of($curr/preceding-sibling::person/id, id))]" group-by="id">
                            {
                            "source": <xsl:value-of select="$position-person - 1"/>,
                            "target": <xsl:value-of select="count($persons//person[id = current-grouping-key()]/preceding-sibling::person)"/>,
                            "value": <xsl:value-of select="count(current-group())"/>
                            }
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each-group>
                        <!-- das allerletzte Komma muss im Moment ggf. noch händisch gelöscht werden, falls es für die Person an der letzten 
          Position keine neuen Relationen mehr gibt (dann ist nämlich die letzte Person mit neuen Relationen nicht die letzte
          in der Liste) -->
                        <xsl:if test=".//person[empty(index-of($curr/preceding-sibling::person/id, id))] and position() != last()">,</xsl:if>
                    </xsl:if>
                </xsl:for-each>
                ]}
            </xsl:result-document>
            
            
        </xsl:for-each>
        
        
        
        
        
    </xsl:template>
    
    
</xsl:stylesheet>