<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
       <persons>
           <!-- Alle Personen/Namen durchgehen -->
           <xsl:for-each select="doc('../data/lists.xml')//listPerson/person">
               <xsl:variable name="person-id" select="@corresp | @xml:id"/>
               <person>
                   <id><xsl:value-of select="$person-id"/></id>
                   <name><xsl:value-of select="persName[1]"/></name>
                   <documents>
                       <!-- Alle Dokumente durchgehen; kommt die aktuelle Person in dem Dokument überhaupt vor? -->
                       <xsl:for-each select="collection('../data/doc')//TEI[exists(.//rs[@type='name'][@key=$person-id])]">
                           <document>
                               <filename><xsl:value-of select=".//idno[@type='filename']"/></filename>
                               <!-- Welche anderen Personen kommen vor? Jede davon nur einmal berücksichtigen
                                   (deshalb for-each-group). -->
                               <xsl:for-each-group select=".//rs[@type='name'][not(@key=$person-id)]" group-by="@key">
                                   <person>
                                       <id><xsl:value-of select="@key"/></id>
                                   </person>
                               </xsl:for-each-group>
                           </document>
                       </xsl:for-each>
                   </documents>
               </person>
           </xsl:for-each>
       </persons>
    </xsl:template>
    
</xsl:stylesheet>