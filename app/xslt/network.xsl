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
"links": [
  <xsl:for-each select="doc('network-basis.xml')/persons/person">
      <xsl:if test="documents/document/person">
          <xsl:variable name="position-person" select="position()"/>
          <xsl:variable name="curr" select="current()"/>
          <xsl:for-each-group select=".//person[empty(index-of($curr/preceding-sibling::person/id, id))]" group-by="id">
              {
              "source": <xsl:value-of select="$position-person - 1"/>,
              "target": <xsl:value-of select="count(//persons/person[id = current-grouping-key()]/preceding-sibling::person)"/>,
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
</xsl:template>
        
</xsl:stylesheet>
