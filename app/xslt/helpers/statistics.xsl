<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <html>
            <head>
                <!-- Plotly.js -->
                <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
            </head>
            <body>
                <!-- Plotly chart will be drawn inside this DIV -->
                <div id="myDiv" style="width: 1000px; height: 600px;"></div>
                <script>
        var trace1 = {
        
        x: [<xsl:for-each select="//result">
            '<xsl:value-of select="@date"/>'
            <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>],
        
        y: [<xsl:for-each select="//result">
            <xsl:choose>
                <xsl:when test=".=''">0</xsl:when>
                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>],
        
        mode: 'markers',
        
        type: 'scatter'
        
        };
        
        
        var data = [trace1];
        
        
        Plotly.newPlot('myDiv', data);
                </script>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>