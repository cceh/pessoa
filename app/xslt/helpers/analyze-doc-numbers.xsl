<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">

    <!-- @author: Ulrike Henny-Krahmer
    Created on 12 December 2020. 
    Last updated 13 December 2020. -->


    <xsl:variable name="docs" select="collection('../../data/doc')//TEI"/>
    <xsl:variable name="pubs" select="collection('../../data/pub')//TEI//imprint"/>
    
    <xsl:template match="/">
        
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
                        <xsl:variable name="curr-year" select="."/>
                        <xsl:variable name="docs-from" as="xs:float*">
                            <xsl:for-each select="$docs[.//origDate/@from]">
                                <xsl:variable name="date" select=".//origDate"/>
                                <xsl:variable name="from-year" select="xs:integer(substring($date/@from,1,4))"/>
                                <xsl:variable name="to-year" select="xs:integer(substring($date/@to,1,4))"/>
                                <xsl:variable name="num-years" select="$to-year - $from-year"/>
                                <xsl:if test="$from-year &lt;= $curr-year and $curr-year &lt;= $to-year">
                                    <xsl:value-of select="1 div $num-years"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="docs-when" select="count($docs[.//origDate/@when/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notBefore" select="count($docs[.//origDate/@notBefore/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notAfter" select="count($docs[.//origDate/@notAfter/starts-with(.,xs:string(current()))])"/>
                        <xsl:value-of select="sum(($docs-when, $docs-notBefore, $docs-notAfter, $docs-from))"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'bar',
                    name: 'listas editoriais (desde - até)',
                    width: 0.4,
                    offset: -0.4
                    };
                    
                    var trace2 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="docs-when" select="count($docs[.//origDate/@when/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notBefore" select="count($docs[.//origDate/@notBefore/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notAfter" select="count($docs[.//origDate/@notAfter/starts-with(.,xs:string(current()))])"/>
                        <xsl:value-of select="sum(($docs-when, $docs-notBefore, $docs-notAfter))"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'bar',
                    name: 'listas editoriais',
                    width: 0.4,
                    offset: -0.4
                    };
                    
                    var trace3 = {
                    x: [<xsl:value-of select="string-join($years,',')"/>],
                    y: [<xsl:for-each select="$years">
                        <xsl:variable name="curr-year" select="."/>
                        <xsl:variable name="docs-from" as="xs:float*">
                            <xsl:for-each select="$docs[.//origDate/@from]">
                                <xsl:variable name="date" select=".//origDate"/>
                                <xsl:variable name="from-year" select="xs:integer(substring($date/@from,1,4))"/>
                                <xsl:variable name="to-year" select="xs:integer(substring($date/@to,1,4))"/>
                                <xsl:variable name="num-years" select="$to-year - $from-year"/>
                                <xsl:if test="$from-year &lt;= $curr-year and $curr-year &lt;= $to-year">
                                    <xsl:value-of select="1 div $num-years"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="docs-when" select="count($docs[.//origDate/@when/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notBefore" select="count($docs[.//origDate/@notBefore/starts-with(.,xs:string(current()))])"/>
                        <xsl:variable name="docs-notAfter" select="count($docs[.//origDate/@notAfter/starts-with(.,xs:string(current()))])"/>
                        <xsl:value-of select="sum(($docs-when, $docs-notBefore, $docs-notAfter, $docs-from))"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: 'line',
                    line: {shape: 'spline'},
                    name: 'listas editoriais (tendência)'
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
                    type: 'bar',
                    name: 'publiçaões',
                    width: 0.4,
                    offset: 0
                    };
                    
                    var trace5 = {
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
                    name: 'publiçaões (tendência)'
                    };
                    
                    var data = [trace1, trace2, trace3, trace4, trace5];
                    var layout = {
                    colorway: ['rgb(153, 204, 255)','rgb(31, 119, 180)','rgb(44, 160, 44)','rgb(255, 127, 14)','rgb(214, 39, 40)']
                    }
                    
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
        
    </xsl:template>
    
    
    
</xsl:stylesheet>