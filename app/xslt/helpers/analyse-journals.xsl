<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- @author: Ulrike Henny-Krahmer
    Created on 6 December 2022. -->
    
    <!-- The purpose of this stylesheet is to generate charts about the publications.
        It was used in the context of an academic publication.
        Usage note: adjust the path for the output documents in lines 38, 104, 150, 196, 243,
        319, 395, 471, 548, 621, 694, 767, 840, 914, 988, 1059. -->
    
    <xsl:variable name="docs" select="collection('../../data/doc')//TEI"/>
    <xsl:variable name="pubs" select="collection('../../data/pub')//TEI"/>
    <xsl:variable name="lists" select="document('../../data/indices.xml')//TEI//list[@type='periodical']"/>
    <xsl:variable name="colors">
        <list xmlns="http://www.tei-c.org/ns/1.0">
            <item>#9BD770</item>
            <item>#66B032</item>
            <item>#375F1B</item>
            <item>#79BEA8</item>
            <item>#448D76</item>
            <item>#23483C</item>
            <item>#609CE1</item>
            <item>#236AB9</item>
        </list>
    </xsl:variable>

    <xsl:template match="/">
        
        <xsl:call-template name="journals-6"/>
        
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
                    name: "poetry"
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
                    name: "prose"
                    //marker: {color: "grey"}
                    };
                    var data = [trace1,trace2];
                    var layout = {
                    barmode: "stack",
                    xaxis: {title: "", type: "category", automargin: true},
                    yaxis: {title: "number of publications"}
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
                    name: "poetry"
                    //marker: {color: "grey"}
                    };
                    
                    
                    var data = [trace1];
                    var layout = {
                    //barmode: "stack",
                    xaxis: {title: "", type: "category", automargin: true},
                    yaxis: {title: "number of publications (poetry)"}
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
                    name: "prose"
                    //marker: {color: "grey"}
                    };
                    
                    
                    var data = [trace1];
                    var layout = {
                    //barmode: "stack",
                    xaxis: {title: "", type: "category", automargin: true},
                    yaxis: {title: "number of publications (prose)"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-2">
        <!-- Create a bar chart: how many journals are mentioned in the documents/lists? -->
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
                    name: "lists"
                    //marker: {color: "grey"}
                    };
                    
                    
                    var data = [trace1];
                    var layout = {
                    //barmode: "stack",
                    xaxis: {title: "", type: "category", automargin: true},
                    yaxis: {title: "number of mentions in lists"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-3">
        <!-- Create a bar chart: how many texts are published in which journals
            over the years? (1912-1935) -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_3.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1300px; height: 1100px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="journals-in-pubs">
                        <list xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:for-each-group select="$pubs//sourceDesc//rs[@type='periodical']" group-by="@key">
                                <xsl:sort select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                                <!--<xsl:sort select="count(current-group)" order="descending" data-type="number"/>-->
                                <item xml:id="{current-grouping-key()}"><xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/></item>
                            </xsl:for-each-group>
                        </list>
                    </xsl:variable>
                    
                    <xsl:for-each select="$journals-in-pubs//item">
                        <xsl:variable name="current-key" select="@xml:id"/>
                        <xsl:variable name="position" select="position()"/>
                        var trace<xsl:value-of select="position()"/> = {
                        x: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        y: [<xsl:for-each select="1912 to 1935">
                                <xsl:value-of select="count($pubs[.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$current-key])"/>
                                <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        text: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="$position"/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        textposition: "inside",
                        name: "<xsl:value-of select="current()"/> (<xsl:value-of select="$position"/>)",
                        marker: {color: "<xsl:choose>
                            <xsl:when test=".='Presença'">#4CAF50</xsl:when>
                            <xsl:when test=".='Contemporânea'">#ff9800</xsl:when>
                            <xsl:when test=".='Orpheu'">#2196F3</xsl:when>
                            <xsl:when test=".='Athena'">#9c27b0</xsl:when>
                            <xsl:when test=".='Revista de Comércio e Contabilidade'">#f44336</xsl:when>
                            <xsl:when test=".='O Jornal'">#ffeb3b</xsl:when>
                            <xsl:when test=".='O Notícias Ilustrado'">#87CEEB</xsl:when>
                            <xsl:otherwise>white</xsl:otherwise>
                        </xsl:choose>", line: {color: "black", width: 1.5}}
                        };    
                    </xsl:for-each>
                    
                    
                    var data = [<xsl:for-each select="$journals-in-pubs//item">
                        trace<xsl:value-of select="position()"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications"},
                    xaxis: {type: "category"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-3a">
        <!-- Create a bar chart: how many prose texts are published in which journals
            over the years? (1912-1935) -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_3a.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1300px; height: 900px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="journals-in-pubs">
                        <list xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:for-each-group select="$pubs[.//rs[@type='genre'][@key='prosa']]//sourceDesc//rs[@type='periodical']" group-by="@key">
                                <xsl:sort select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                                <!--<xsl:sort select="count(current-group)" order="descending" data-type="number"/>-->
                                <item xml:id="{current-grouping-key()}"><xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/></item>
                            </xsl:for-each-group>
                        </list>
                    </xsl:variable>
                    
                    <xsl:for-each select="$journals-in-pubs//item">
                        <xsl:variable name="current-key" select="@xml:id"/>
                        <xsl:variable name="position" select="position()"/>
                        var trace<xsl:value-of select="position()"/> = {
                        x: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        y: [<xsl:for-each select="1912 to 1935">
                            <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$current-key])"/>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        text: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="$position"/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        textposition: "inside",
                        name: "<xsl:value-of select="current()"/> (<xsl:value-of select="$position"/>)",
                        marker: {color: "<xsl:choose>
                            <xsl:when test=".='Presença'">#4CAF50</xsl:when>
                            <xsl:when test=".='Contemporânea'">#ff9800</xsl:when>
                            <xsl:when test=".='Orpheu'">#2196F3</xsl:when>
                            <xsl:when test=".='Athena'">#9c27b0</xsl:when>
                            <xsl:when test=".='Revista de Comércio e Contabilidade'">#f44336</xsl:when>
                            <xsl:when test=".='O Jornal'">#ffeb3b</xsl:when>
                            <xsl:when test=".='O Notícias Ilustrado'">#87CEEB</xsl:when>
                            <xsl:otherwise>white</xsl:otherwise>
                        </xsl:choose>", line: {color: "black", width: 1.5}}
                        };    
                    </xsl:for-each>
                    
                    
                    var data = [<xsl:for-each select="$journals-in-pubs//item">
                        trace<xsl:value-of select="position()"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications (prose)"},
                    xaxis: {type: "category"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-3b">
        <!-- Create a bar chart: how many poems are published in which journals
            over the years? (1912-1935) -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_3b.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1300px; height: 600px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="journals-in-pubs">
                        <list xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:for-each-group select="$pubs[.//rs[@type='genre'][@key='poesia']]//sourceDesc//rs[@type='periodical']" group-by="@key">
                                <xsl:sort select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                                <!--<xsl:sort select="count(current-group)" order="descending" data-type="number"/>-->
                                <item xml:id="{current-grouping-key()}"><xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/></item>
                            </xsl:for-each-group>
                        </list>
                    </xsl:variable>
                    
                    <xsl:for-each select="$journals-in-pubs//item">
                        <xsl:variable name="current-key" select="@xml:id"/>
                        <xsl:variable name="position" select="position()"/>
                        var trace<xsl:value-of select="position()"/> = {
                        x: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        y: [<xsl:for-each select="1912 to 1935">
                            <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$current-key])"/>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        text: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="$position"/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        textposition: "inside",
                        name: "<xsl:value-of select="current()"/> (<xsl:value-of select="$position"/>)",
                        marker: {color: "<xsl:choose>
                            <xsl:when test=".='Presença'">#4CAF50</xsl:when>
                            <xsl:when test=".='Contemporânea'">#ff9800</xsl:when>
                            <xsl:when test=".='Orpheu'">#2196F3</xsl:when>
                            <xsl:when test=".='Athena'">#9c27b0</xsl:when>
                            <xsl:when test=".='Revista de Comércio e Contabilidade'">#f44336</xsl:when>
                            <xsl:when test=".='O Jornal'">#ffeb3b</xsl:when>
                            <xsl:when test=".='O Notícias Ilustrado'">#87CEEB</xsl:when>
                            <xsl:otherwise>white</xsl:otherwise>
                        </xsl:choose>", line: {color: "black", width: 1.5}}
                        };    
                    </xsl:for-each>
                    
                    
                    var data = [<xsl:for-each select="$journals-in-pubs//item">
                        trace<xsl:value-of select="position()"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications (poetry)"},
                    xaxis: {type: "category"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-4">
        <!-- Create a bar chart: how many journals are mentioned in the documents/lists
            over the years? (1912-1935) -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_4.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1300px; height: 800px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="journals-in-docs">
                        <list xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:for-each-group select="$docs//text//rs[@type='periodical']" group-by="@key">
                                <xsl:sort select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/>
                                <!--<xsl:sort select="count(current-group)" order="descending" data-type="number"/>-->
                                <item xml:id="{current-grouping-key()}"><xsl:value-of select="normalize-space(translate($lists//item[@xml:id=current-grouping-key()],'&quot;',''))"/></item>
                            </xsl:for-each-group>
                        </list>
                    </xsl:variable>
                    
                    <xsl:for-each select="$journals-in-docs//item">
                        <xsl:variable name="current-key" select="@xml:id"/>
                        <xsl:variable name="position" select="position()"/>
                        var trace<xsl:value-of select="position()"/> = {
                        x: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        y: [<xsl:for-each select="1912 to 1935">
                            <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$current-key])"/>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        text: [<xsl:for-each select="1912 to 1935">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="$position"/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        textposition: "inside",
                        name: "<xsl:value-of select="current()"/> (<xsl:value-of select="$position"/>)",
                        marker: {color: "<xsl:choose>
                            <xsl:when test=".='Presença'">#4CAF50</xsl:when>
                            <xsl:when test=".='Contemporânea'">#ff9800</xsl:when>
                            <xsl:when test=".='Orpheu'">#2196F3</xsl:when>
                            <xsl:when test=".='Athena'">#9c27b0</xsl:when>
                            <xsl:when test=".='Revista de Comércio e Contabilidade'">#f44336</xsl:when>
                            <xsl:when test=".='O Jornal'">#ffeb3b</xsl:when>
                            <xsl:when test=".='O Notícias Ilustrado'">#87CEEB</xsl:when>
                            <xsl:otherwise>white</xsl:otherwise>
                        </xsl:choose>", line: {color: "black", width: 1.5}}
                        };    
                    </xsl:for-each>
                    
                    
                    var data = [<xsl:for-each select="$journals-in-docs//item">
                        trace<xsl:value-of select="position()"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of mentions in lists"},
                    xaxis: {type: "category"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-5a">
        <!-- Create a bar chart: how many prose texts and poems
            are published in Orpheu over the years? (1912-1935)
        And how often is Orpheu mentioned in the lists? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_5a.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="key-Orpheu" select="$lists//item[.='Orpheu']/@xml:id"/>
                    var trace1 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Orpheu])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (prose)"
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Orpheu])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (poetry)"
                    };
                    
                    var trace3 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$key-Orpheu])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "mentions in lists"
                    };    
                    
                    
                    var data = [trace1, trace2, trace3];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications / mentions in lists"},
                    xaxis: {type: "category"},
                    title: "Orpheu"
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
  
    <xsl:template name="journals-5b">
        <!-- Create a bar chart: how many prose texts and poems
            are published in Presença over the years? (1912-1935)
        And how often is Presença mentioned in the lists? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_5b.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="key-Presenca" select="$lists//item[.='Presença']/@xml:id"/>
                    var trace1 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Presenca])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (prose)"
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Presenca])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (poetry)"
                    };
                    
                    var trace3 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$key-Presenca])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "mentions in lists"
                    };    
                    
                    
                    var data = [trace1, trace2, trace3];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications / mentions in lists"},
                    xaxis: {type: "category"},
                    title: "Presença"
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-5c">
        <!-- Create a bar chart: how many prose texts and poems
            are published in Athena over the years? (1912-1935)
        And how often is Athena mentioned in the lists? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_5c.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="key-Athena" select="$lists//item[.='Athena']/@xml:id"/>
                    var trace1 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Athena])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (prose)"
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Athena])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (poetry)"
                    };
                    
                    var trace3 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$key-Athena])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "mentions in lists"
                    };    
                    
                    
                    var data = [trace1, trace2, trace3];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications / mentions in lists"},
                    xaxis: {type: "category"},
                    title: "Athena"
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-5d">
        <!-- Create a bar chart: how many prose texts and poems
            are published in Contemporânea over the years? (1912-1935)
        And how often is Contemporânea mentioned in the lists? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_5d.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="key-Contemporanea" select="$lists//item[.='Contemporânea']/@xml:id"/>
                    var trace1 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Contemporanea])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (prose)"
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Contemporanea])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (poetry)"
                    };
                    
                    var trace3 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$key-Contemporanea])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "mentions in lists"
                    };    
                    
                    
                    var data = [trace1, trace2, trace3];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications / mentions in lists"},
                    xaxis: {type: "category"},
                    title: "Contemporânea"
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-5e">
        <!-- Create a bar chart: how many prose texts and poems
            are published in Contemporânea over the years? (1912-1935)
        And how often is Contemporânea mentioned in the lists? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_5e.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="key-OJornal" select="$lists//item[.='O Jornal']/@xml:id"/>
                    var trace1 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-OJornal])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (prose)"
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-OJornal])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (poetry)"
                    };
                    
                    var trace3 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$key-OJornal])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "mentions in lists"
                    };    
                    
                    
                    var data = [trace1, trace2, trace3];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications / mentions in lists"},
                    xaxis: {type: "category"},
                    title: "O Jornal"
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template name="journals-5f">
        <!-- Create a bar chart: how many prose texts and poems
            are published in Contemporânea over the years? (1912-1935)
        And how often is Contemporânea mentioned in the lists? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_5f.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="key-RevistaCC" select="$lists//item[.='Revista de Comércio e Contabilidade']/@xml:id"/>
                    var trace1 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-RevistaCC])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (prose)"
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-RevistaCC])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (poetry)"
                    };
                    
                    var trace3 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$key-RevistaCC])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "mentions in lists"
                    };    
                    
                    
                    var data = [trace1, trace2, trace3];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications / mentions in lists"},
                    xaxis: {type: "category"},
                    title: "Revista de Comércio e Contabilidade"
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template name="journals-5g">
        <!-- Create a bar chart: how many prose texts and poems
            are published in Contemporânea over the years? (1912-1935)
        And how often is Contemporânea mentioned in the lists? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_5g.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="key-Noticias" select="$lists//item[.='O &quot;Notícias&quot; Ilustrado']/@xml:id"/>
                    var trace1 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='prosa']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Noticias])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (prose)"
                    };
                    
                    var trace2 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($pubs[.//rs[@type='genre'][@key='poesia']][.//imprint//date[starts-with(@when, xs:string(current()))]]//sourceDesc//rs[@type='periodical'][@key=$key-Noticias])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "publications (poetry)"
                    };
                    
                    var trace3 = {
                    x: [<xsl:for-each select="1912 to 1935">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    y: [<xsl:for-each select="1912 to 1935">
                        <xsl:value-of select="count($docs[.//origDate[starts-with(@when, xs:string(current()))]]//text//rs[@type='periodical'][@key=$key-Noticias])"/>
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>],
                    type: "bar",
                    name: "mentions in lists"
                    };    
                    
                    
                    var data = [trace1, trace2, trace3];
                    var layout = {
                    barmode: "stack",
                    legend: {"orientation": "h", "traceorder": "normal"},
                    yaxis: {title: "number of publications / mentions in lists"},
                    xaxis: {type: "category"},
                    title: "O Notícias Ilustrado"
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="journals-6">
        <!-- Create a bar chart: how many texts by which authors are published in which journals? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/journals_6-20230927.html" method="html" encoding="UTF-8">
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
                        <xsl:value-of select="count(current-group()[ancestor::TEI//author/rs[@type='name'][@key='FP']])"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "Fernando Pessoa"
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
                        <xsl:value-of select="count(current-group()[ancestor::TEI//author/rs[@type='name'][@key='AC']])"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "Alberto Caeiro"
                    //marker: {color: "grey"}
                    };
                    
                    var trace3 = {
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
                        <xsl:value-of select="count(current-group()[ancestor::TEI//author/rs[@type='name'][@key='AdC']])"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "Álvaro de Campos"
                    //marker: {color: "grey"}
                    };
                    
                    var trace4 = {
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
                        <xsl:value-of select="count(current-group()[ancestor::TEI//author/rs[@type='name'][@key='RR']])"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "Ricardo Reis"
                    //marker: {color: "grey"}
                    };
                    
                    var trace5 = {
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
                        <xsl:value-of select="count(current-group()[ancestor::TEI//author/rs[@type='name'][@key='BS']])"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each-group>],
                    type: "bar",
                    name: "Bernardo Soares"
                    //marker: {color: "grey"}
                    };
                    
                    
                    var data = [trace1,trace2,trace3,trace4,trace5];
                    var layout = {
                    barmode: "stack",
                    xaxis: {title: "", type: "category", automargin: true},
                    yaxis: {title: "number of publications"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    
</xsl:stylesheet>