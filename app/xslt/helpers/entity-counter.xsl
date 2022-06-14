<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:variable name="data" select="collection('../../data/doc')|collection('../../data/pub')"/>
    
    <!-- count mentioned entities -->
    <xsl:template match="/">
        <xsl:variable name="personen" select="count($data//rs[@type='name'])"/>
        <xsl:variable name="periodicals" select="count($data//rs[@type='periodical'])"/>
        <xsl:variable name="titles" select="count($data//rs[@type='title'])"/>
            Personen: <xsl:value-of select="$personen"/>;
            Zeitschriften: <xsl:value-of select="$periodicals"/>;
            Titel: <xsl:value-of select="$titles"/>;
            alle: <xsl:value-of select="sum(($personen,$periodicals,$titles))"/>
    </xsl:template>
    
    
</xsl:stylesheet>