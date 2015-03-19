<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

	<xsl:output method="html"/>

	<xsl:param name="listNo_string"/>
	<xsl:variable name="listNo" select="number($listNo_string)"></xsl:variable>
	<xsl:variable name="title">
		<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]/text()"/>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<style type="text/css">
				h1{
				    text-align:center;
				    font-size:larger;
				    padding-top:1em;
				    padding-bottom:2em;
				}
				
				h2{
				    font-size:medium;
				    margin-bottom:10px;
				}
				
				p + h2{
				    padding-top:1em;
				}
				
				p.bibl{
				    padding-left:20px;
				    text-indent:-20px;
				}</style>

			<head>
				<title>
					<xsl:value-of select="$title"/>
				</title>
			</head>

			<body>
				<!--<h1>
					<xsl:value-of select="$title"/>
				</h1>-->
				<xsl:apply-templates/>
			</body>
		</html>

	</xsl:template>

	<!-- surpress standard template for unmatched text tags -->
	<xsl:template match="text()"/>

	<!-- copy all text nodes in bibl tags -->
	<xsl:template match="//listBibl[$listNo]/bibl/text()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- the bibliography list -->
	<xsl:template match="/TEI/text/body/listBibl[$listNo]">
		<h2>
			<xsl:value-of select="head"/>
		</h2>
		<xsl:for-each select="bibl">
			<p class="bibl">
				<xsl:apply-templates/>
			</p>
		</xsl:for-each>
	</xsl:template>

	<!-- emphasis in reference text -->
	<xsl:template match="//listBibl[$listNo]//hi[@rend='#italic']">
		<em>
			<xsl:value-of select="."/>
		</em>
	</xsl:template>
	
	<!-- superscript -->
	<xsl:template match="//listBibl[$listNo]//hi[@rend='#superscript']">
		<sup><xsl:value-of select="." /></sup>
	</xsl:template>

	<!-- links in reference text -->
	<xsl:template match="//listBibl[$listNo]//ref[@target]">
		<a href="{@target}">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>

	<!-- line breaks -->
	<xsl:template match="//listBibl[$listNo]//lb">
		<br/>
	</xsl:template>
		
</xsl:stylesheet>
