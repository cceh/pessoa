<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:variable name="docs" select="collection('../../data/doc')//TEI"/>
    <xsl:variable name="pubs" select="collection('../../data/pub')//TEI//imprint"/>
    
    <xsl:template match="/">
        <!--<xsl:call-template name="variances-1"/>-->
        <xsl:call-template name="variances-2"/>
    </xsl:template>
    
    <xsl:template name="variances-2">
        <!-- Number of changes in documents and publications,
        divided by the number of documents/publications in the same year -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/variances_2.html" method="html" encoding="UTF-8">
            <!-- 1913 - 1935 -->
            <xsl:variable name="years" select="1912 to 1935"/>
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    var trace1 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="docs_year" select="$docs[.//origDate/(@when|@notBefore|@notAfter|@from)/starts-with(.,xs:string(current()))]"/>
                        <xsl:variable name="num_docs_year" select="count($docs_year)"/>
                        <xsl:variable name="count-additions" select="count($docs_year//add[not(parent::subst)])"/>
                        <xsl:variable name="count-deletions" select="count($docs_year//del[not(parent::subst)])"/>
                        <xsl:variable name="count-substitutions" select="count($docs_year//subst)"/>
                        <xsl:variable name="count-addSpans" select="count($docs_year//addSpan)"/>
                        <xsl:variable name="count-delSpans" select="count($docs_year//delSpan)"/>
                        <xsl:variable name="count-notes" select="count($docs_year//note[@n='2'])"/>
                        <xsl:choose>
                            <xsl:when test="$num_docs_year = 0">0</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="sum(($count-additions,$count-deletions,$count-substitutions,$count-addSpans,$count-delSpans,$count-notes)) div $num_docs_year"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'bar',
                    name: 'documents'
                    };
                    var trace2 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="curr-year" select="."/>
                        <xsl:variable name="pubs_year" select="$pubs[date/(@when|@notBefore|@notAfter|@from)/starts-with(.,xs:string(current()))]"/>
                        <xsl:variable name="num_pubs_year" select="count($pubs_year)"/>
                        <xsl:variable name="changes" as="node()*">
                            <xsl:for-each select="$pubs_year/ancestor::TEI//app">
                                <xsl:variable name="app_dates" select="(lem|rdg)/@wit/xs:integer(replace(tokenize(.,'_')[last()],'-\d+',''))"/>
                                <xsl:variable name="earliest" select="min($app_dates)"/>
                                <xsl:for-each select="$app_dates">
                                    <xsl:if test=". = $curr-year and . != $earliest">
                                        <xsl:value-of select="."/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$num_pubs_year = 0">0</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="count($changes) div $num_pubs_year"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'bar',
                    name: 'publications'
                    };
                    
                    var trace3 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="docs_year" select="$docs[.//origDate/(@when|@notBefore|@notAfter|@from)/starts-with(.,xs:string(current()))]"/>
                        <xsl:variable name="num_docs_year" select="count($docs_year)"/>
                        <xsl:variable name="count-additions" select="count($docs_year//add[not(parent::subst)])"/>
                        <xsl:variable name="count-deletions" select="count($docs_year//del[not(parent::subst)])"/>
                        <xsl:variable name="count-substitutions" select="count($docs_year//subst)"/>
                        <xsl:variable name="count-addSpans" select="count($docs_year//addSpan)"/>
                        <xsl:variable name="count-delSpans" select="count($docs_year//delSpan)"/>
                        <xsl:variable name="count-notes" select="count($docs_year//note[@n='2'])"/>
                        <xsl:choose>
                            <xsl:when test="$num_docs_year = 0">0</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="sum(($count-additions,$count-deletions,$count-substitutions,$count-addSpans,$count-delSpans,$count-notes)) div $num_docs_year"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'line',
                    line: {shape: 'spline'},
                    name: 'documents'
                    };
                    var trace4 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="curr-year" select="."/>
                        <xsl:variable name="pubs_year" select="$pubs[date/(@when|@notBefore|@notAfter|@from)/starts-with(.,xs:string(current()))]"/>
                        <xsl:variable name="num_pubs_year" select="count($pubs_year)"/>
                        <xsl:variable name="changes" as="node()*">
                            <xsl:for-each select="$pubs_year/ancestor::TEI//app">
                                <xsl:variable name="app_dates" select="(lem|rdg)/@wit/xs:integer(replace(tokenize(.,'_')[last()],'-\d+',''))"/>
                                <xsl:variable name="earliest" select="min($app_dates)"/>
                                <xsl:for-each select="$app_dates">
                                    <xsl:if test=". = $curr-year and . != $earliest">
                                        <xsl:value-of select="."/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$num_pubs_year = 0">0</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="count($changes) div $num_pubs_year"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'line',
                    line: {shape: 'spline'},
                    name: 'publications'
                    };
                    
                    var data = [trace1, trace2, trace3, trace4];
                    
                    Plotly.newPlot('myDiv', data);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="variances-1">
        <!-- Number of documents and publications -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/variances_1.html" method="html" encoding="UTF-8">
            <!-- 1913 - 1935 -->
            <xsl:variable name="years" select="1912 to 1935"/>
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    var trace1 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="docs-when" select="count($docs[.//origDate/@when/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notBefore" select="count($docs[.//origDate/@notBefore/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notAfter" select="count($docs[.//origDate/@notAfter/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-from" select="count($docs[.//origDate/@from/starts-with(.,xs:string(current()))])"/>
                        <xsl:value-of select="sum(($docs-when, $docs-notBefore, $docs-notAfter, $docs-from))"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'bar',
                    name: 'documents'
                    };
                    
                    var trace2 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="pubs-when" select="count($pubs[date/@when/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="pubs-notBefore" select="count($pubs[date/@notBefore/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="pubs-notAfter" select="count($pubs[date/@notAfter/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="pubs-from" select="count($pubs[date/@from/starts-with(.,xs:string(current()))])"/>
                        <xsl:value-of select="sum(($pubs-when, $pubs-notBefore, $pubs-notAfter, $pubs-from))"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'bar',
                    name: 'publications'
                    };
                    
                    var trace3 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="docs-when" select="count($docs[.//origDate/@when/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notBefore" select="count($docs[.//origDate/@notBefore/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notAfter" select="count($docs[.//origDate/@notAfter/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-from" select="count($docs[.//origDate/@from/starts-with(.,xs:string(current()))])"/>
                        <xsl:value-of select="sum(($docs-when, $docs-notBefore, $docs-notAfter, $docs-from))"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'line',
                    line: {shape: 'spline'},
                    name: 'documents'
                    };
                    
                    var trace4 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="pubs-when" select="count($pubs[date/@when/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="pubs-notBefore" select="count($pubs[date/@notBefore/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="pubs-notAfter" select="count($pubs[date/@notAfter/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="pubs-from" select="count($pubs[date/@from/starts-with(.,xs:string(current()))])"/>
                        <xsl:value-of select="sum(($pubs-when, $pubs-notBefore, $pubs-notAfter, $pubs-from))"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'line',
                    line: {shape: 'spline'},
                    name: 'publications'
                    };
                    
                    var data = [trace1, trace2, trace3, trace4];
                    
                    Plotly.newPlot('myDiv', data);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>