<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

<xsl:output method="text" encoding="UTF-8"/>

<xsl:template match="/">
{
"nodes": [
  <xsl:for-each select="doc('network-basis.xml')/persons/person">
    {
    "name": "<xsl:value-of select="name"/>",
    "group": 1
    }<xsl:if test="position() != last()">,</xsl:if>
  </xsl:for-each>
],
,
"links": [
  <xsl:for-each select="doc('network-basis.xml')/persons/person">
      <xsl:if test="documents/document/person">
          <xsl:variable name="position-person" select="position()"/>
          <xsl:for-each-group select=".//person" group-by="id">
              {
              "source": <xsl:value-of select="$position-person"/>,
              "target": <xsl:value-of select="count(//persons/person[id = current-grouping-key()]/preceding-sibling::person) + 1"/>,
              "value": <xsl:value-of select="count(current-group())"/>
              }
              <xsl:if test="position() != last()">,</xsl:if>
          </xsl:for-each-group>
          
      </xsl:if>
  </xsl:for-each>
]}
</xsl:template>
        
</xsl:stylesheet>
