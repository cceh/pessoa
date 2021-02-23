<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- @author: Ulrike Henny-Krahmer
    Created on 12 December 2020. 
    Last updated 18 February 2021. -->
    
    <xsl:variable name="docs" select="collection('../../data/doc')//TEI"/>
    <xsl:variable name="pubs" select="collection('../../data/pub')//TEI//imprint"/>
    
    <xsl:template match="/">
        
        <!--<xsl:call-template name="variances-1"/>-->
        <!--<xsl:call-template name="variances-2"/>-->
        <!--<xsl:call-template name="variances-3"/>-->
        <!--<xsl:call-template name="variances-4"/>-->
        <xsl:call-template name="variances-5"/>
    </xsl:template>
    
    <xsl:template name="variances-5">
        <!-- how many changes are there per list? create a bar chart -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/variances_5.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 600px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="changes-in-docs">
                        <list xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:for-each select="$docs">
                                <xsl:variable name="count-additions" select="count(.//add[not(parent::subst)])"/>
                                <xsl:variable name="count-deletions" select="count(.//del[not(parent::subst)])"/>
                                <xsl:variable name="count-substitutions" select="count(.//subst)"/>
                                <xsl:variable name="count-addSpans" select="count(.//addSpan)"/>
                                <xsl:variable name="count-delSpans" select="count(.//delSpan)"/>
                                <xsl:variable name="count-notes" select="count(.//note[@n='2'])"/>
                                <item>
                                    <xsl:value-of select="sum(($count-additions,$count-deletions,$count-substitutions,$count-addSpans,$count-delSpans,$count-notes))"/>
                                </item>
                            </xsl:for-each>    
                        </list>
                    </xsl:variable>
                    var data = [{
                    x: ["nenhuma intervenção", "1", "2", "3", "4", "5-10", "mais de 10 intervenções"],
                        y: [<xsl:value-of select="count($changes-in-docs//item[xs:integer(.)=0])"/>,
                    <xsl:value-of select="count($changes-in-docs//item[xs:integer(.)=1])"/>,
                    <xsl:value-of select="count($changes-in-docs//item[xs:integer(.)=2])"/>,
                    <xsl:value-of select="count($changes-in-docs//item[xs:integer(.)=3])"/>,
                    <xsl:value-of select="count($changes-in-docs//item[xs:integer(.)=4])"/>,
                    <xsl:value-of select="count($changes-in-docs//item[xs:integer(.)=(5,6,7,8,9,10)])"/>,
                    <xsl:value-of select="count($changes-in-docs//item[xs:integer(.)>10])"/>],
                        type: "bar",
                        marker: {color: "grey"}
                    }];
                    var layout = {
                    xaxis: {title: "número de intervenções", type: "category", automargin: true},
                    yaxis: {title: "número de listas editoriais"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="variances-4">
        <!-- what kind of changes did Pessoa make? -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/variances_4.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 600px; height: 400px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="count-additions" select="count($docs//add[not(parent::subst)])"/>
                    <xsl:variable name="count-deletions" select="count($docs//del[not(parent::subst)])"/>
                    <xsl:variable name="count-substitutions" select="count($docs//subst)"/>
                    <xsl:variable name="count-addSpans" select="count($docs//addSpan)"/>
                    <xsl:variable name="count-delSpans" select="count($docs//delSpan)"/>
                    <xsl:variable name="count-notes" select="count($docs//note[@n='2'])"/>
                    var data = [{
                    values: [<xsl:value-of select="$count-additions + $count-addSpans + $count-notes"/>, <xsl:value-of select="$count-substitutions"/>, <xsl:value-of select="$count-deletions + $count-delSpans"/>],
                    labels: ['acrescentos', 'substituições', 'eliminações'],
                    type: 'pie',
                    hole: 0.4
                    }];
                    
                    
                    Plotly.newPlot('myDiv', data);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="variances-3">
        <!-- how many changes are there per list? create a histogram -->
        <xsl:result-document href="/home/ulrike/Schreibtisch/archives/variances_3.html" method="html" encoding="UTF-8">
            <head>
                <!-- Load plotly.js into the DOM -->
                <script src='https://cdn.plot.ly/plotly-latest.min.js'></script>
            </head>
            <body>
                <div id='myDiv' style="width: 1000px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>
                <script>
                    <xsl:variable name="changes-in-docs" as="xs:integer*">
                        <xsl:for-each select="$docs">
                            <xsl:variable name="count-additions" select="count(.//add[not(parent::subst)])"/>
                            <xsl:variable name="count-deletions" select="count(.//del[not(parent::subst)])"/>
                            <xsl:variable name="count-substitutions" select="count(.//subst)"/>
                            <xsl:variable name="count-addSpans" select="count(.//addSpan)"/>
                            <xsl:variable name="count-delSpans" select="count(.//delSpan)"/>
                            <xsl:variable name="count-notes" select="count(.//note[@n='2'])"/>
                            <xsl:value-of select="sum(($count-additions,$count-deletions,$count-substitutions,$count-addSpans,$count-delSpans,$count-notes))"/>
                        </xsl:for-each>
                    </xsl:variable>
                    var trace = {
                    x: [<xsl:value-of select="string-join($changes-in-docs,',')"/>],
                    type: 'histogram',
                    };
                    var data = [trace];
                    var layout = {
                        xaxis: {title: "número de intervenções"},
                        yaxis: {title: "número de listas editoriais"}
                    };
                    Plotly.newPlot('myDiv', data, layout);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="variances-2">
        <!-- how many percent of the editorial lists have changes? -->
        <xsl:variable name="num-docs" select="count($docs)"/>
        <xsl:variable name="docs-with-changes" select="$docs[.//add or .//del or .//subst or .//addSpan or .//delSpan or .//note[@n='2']]"/>
        <xsl:variable name="num-docs-with-changes" select="count($docs-with-changes)"/>
        <xsl:value-of select="$num-docs-with-changes div $num-docs"/>
    </xsl:template>
    
    <xsl:template name="variances-1">
        <!-- Number of changes in documents and publications,
        divided by the number of documents/publications in the same year -->
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
                    name: 'listas editoriais'
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
                    name: 'publiçaões'
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
                    name: 'listas editoriais'
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
                    name: 'publiçaões'
                    };
                    
                    var data = [trace1, trace2, trace3, trace4];
                    
                    Plotly.newPlot('myDiv', data);
                </script>
            </body>
        </xsl:result-document>
    </xsl:template>
    
    
    
</xsl:stylesheet>