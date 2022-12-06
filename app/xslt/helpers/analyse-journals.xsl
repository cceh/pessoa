<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- @author: Ulrike Henny-Krahmer
    Created on 6 December 2022. -->
    
    <xsl:variable name="docs" select="collection('../../data/doc')//TEI"/>
    <xsl:variable name="pubs" select="collection('../../data/pub')//TEI"/>
    <xsl:variable name="lists" select="document('../../data/lists.xml')//TEI"/>
    
    
    <xsl:template match="/">
        <xsl:call-template name="journals-1"/>
        <xsl:call-template name="journals-1a"/>
        <xsl:call-template name="journals-1b"/>
    </xsl:template>
    
    <xsl:template name="journals-1">
        <!-- Create a bar chart: how many poems and prose texts are published in which journals? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_1.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1200px; height: 900px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    
                    var trace1 = {
                    x: [<xsl:for-each-group select="$pubs//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    y: [<xsl:for-each-group select="$pubs//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:value-of select="count(current-group()[ancestor::TEI//rs[@type='genre'][@key='poesia']])"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "poesia"
                    //marker: {color: "grey"}
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each-group select="$pubs//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    y: [<xsl:for-each-group select="$pubs//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:value-of select="count(current-group()[ancestor::TEI//rs[@type='genre'][@key='prosa']])"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "prosa"
                    //marker: {color: "grey"}
                    };
                    var data = [trace1,trace2];
                    var layout = {
                    barmode: "stack",
                    xaxis: {title: "revista", type: "category", automargin: true},
                    yaxis: {title: "número de publicações"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-1a">
        <!-- Create a bar chart: how many poems are published in which journals? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_1a.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 800px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    
                    var trace1 = {
                    x: [<xsl:for-each-group select="$pubs[.//rs[@type='genre'][@key='poesia']]//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    y: [<xsl:for-each-group select="$pubs[.//rs[@type='genre'][@key='poesia']]//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:value-of select="count(current-group())"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "poesia"
                    //marker: {color: "grey"}
                    };
                    
                    
                    var data = [trace1];
                    var layout = {
                    //barmode: "stack",
                    xaxis: {title: "revista", type: "category", automargin: true},
                    yaxis: {title: "número de publicações (poesia)"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-1b">
        <!-- Create a bar chart: how many prose texts are published in which journals? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_1b.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 1000px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    
                    var trace1 = {
                    x: [<xsl:for-each-group select="$pubs[.//rs[@type='genre'][@key='prosa']]//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    y: [<xsl:for-each-group select="$pubs[.//rs[@type='genre'][@key='prosa']]//sourceDesc//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:value-of select="count(current-group())"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "prosa"
                    //marker: {color: "grey"}
                    };
                    
                    
                    var data = [trace1];
                    var layout = {
                    //barmode: "stack",
                    xaxis: {title: "revista", type: "category", automargin: true},
                    yaxis: {title: "número de publicações (prosa)"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-2">
        <!-- Create a bar chart: how many prose texts are published in which journals? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_2.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 700px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    
                    var trace1 = {
                    x: [<xsl:for-each-group select="$docs//text//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    y: [<xsl:for-each-group select="$docs//text//rs[@type='periodical']" group-by="@key">
                        <xsl:sort select="count(current-group())" order="descending" data-type="number"/>
                        <xsl:value-of select="count(current-group())"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "listas"
                    //marker: {color: "grey"}
                    };
                    
                    
                    var data = [trace1];
                    var layout = {
                    //barmode: "stack",
                    xaxis: {title: "revista", type: "category", automargin: true},
                    yaxis: {title: "número de menções em listas"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    
</xsl:stylesheet>