<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:import href="doc-edited.xsl"/>
    <xsl:output method="xhtml" encoding="UTF-8" indent="no"/>
    
    
    <!-- choices -->
    <!-- Alternativen von Pessoa selbst 
        (etwas ist hinzugefügt, aber nichts gestrichen, die beiden Varianten schließen sich aber aus)
    hier: 2. Alternative anzeigen -->
    <xsl:template match="choice[seg and seg[2]/add/@place='below']" mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant">
                <xsl:apply-templates select="seg[2]/add"/><!-- war: text() -->
            </span>
        </span>
    </xsl:template>
    <xsl:template match="choice[seg and seg[2]/add/@place='above']" mode="#default deletion addition">
        <span class="choice">
            <span class="seg variant" title="variant">
                <xsl:apply-templates select="seg[2]/add"/><!-- war: text() -->
            </span>
        </span>
    </xsl:template>
    
    <!-- Ergänzung von Pessoa selbst
    (alternativ: nichts  - das Hinzugefügte)
    hier: das Hinzugefügte anzeigen -->
    <xsl:template match="seg/add[@n='2']" mode="#default deletion addition">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="add[@place='above'][@n='2'][not(parent::seg)]|add[@place='above'][parent::seg[@n='2']]" mode="#default deletion addition">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
    <xsl:template match="add[@place='below'][parent::seg[@n='2']]" mode="#default deletion addition">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
    <!-- Ersetzung von Pessoa selbst: etwas wird gelöscht, etwas anderes hinzugefügt
    hier: Anzeigen des Hinzugefügten -->
    <xsl:template match="subst[del and add/@n]" mode="#default deletion addition">
        <xsl:apply-templates select="add/text()"/>
    </xsl:template>
    
    
    <!-- einzublendende Spans -->
    <xsl:template match="addSpan[@n='2']">
        <xsl:variable name="anchorID" select="@spanTo/substring-after(.,'#')" />
        <xsl:apply-templates select="following-sibling::*[following::anchor[@xml:id=$anchorID]]" mode="addition" />
    </xsl:template>
    
    <!-- einzublendende Notes -->
    <!-- Notes -->
    <xsl:template match="note[@place = 'margin-right'][@n='2']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-right"/>
    </xsl:template>
    
    <xsl:template match="note[@place = 'margin-left'][@n='2']" mode="#default deletion addition">
        <xsl:call-template name="note-margin-left"/>
    </xsl:template>
    
    
    <!-- einzublendende Pfeile -->
    <xsl:template match="metamark[@rend='arrow-right-curved-up'][@n='2']" mode="#default deletion addition">
        <span id="{@xml:id}" class="anchor invisible">x</span>
    </xsl:template>
    
    <xsl:template match="metamark[@rend='arrow-right-curved-down'][@n='2']" mode="#default deletion addition">
        <span id="{@xml:id}" class="anchor invisible">x</span>
        <!--<script type="text/javascript">
            window.onload = function(){
                var el1 = document.getElementById('<xsl:value-of select="@xml:id"/>');
                var el2 = document.getElementById('<xsl:value-of select="@target"/>');
                
                var scrollX = window.pageXOffset;
                var scrollY = window.pageYOffset;
                
                var rect1 = el1.getBoundingClientRect();
                var rect2 = el2.getBoundingClientRect();
                
                var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
                var svgNS = svg.namespaceURI;
                
                var defs = document.createElementNS(svgNS, 'defs');
                var marker = document.createElementNS(svgNS, 'marker');
                marker.setAttribute('id', 'arr1');
                marker.setAttribute('viewBox', '0 0 10 10');
                marker.setAttribute('refX', '0');
                marker.setAttribute('refY', '5');
                marker.setAttribute('markerUnits', 'strokeWidth');
                marker.setAttribute('markerWidth', '10');
                marker.setAttribute('markerHeight', '10');
                marker.setAttribute('orient', 'auto');
                
                var markerpath = document.createElementNS(svgNS, 'path');
                markerpath.setAttribute('d', 'M 0,0 l 10,5 l -10,5 z');
                
                marker.appendChild(markerpath);
                defs.appendChild(marker);
                
                var path = document.createElementNS(svgNS,'path');
                path.setAttribute('d', 'M ' + (rect1.right + 5 + scrollX) + ' ' + (rect1.bottom + scrollY) + ' A 10 55 0 1 1 ' + (rect2.right + 10 + scrollX) + ' ' + (rect2.top + scrollY));
                path.setAttribute('stroke', '#000000');
                path.setAttribute('fill', 'transparent');
                path.setAttribute('marker-end', 'url(#arr1)');
                
                svg.appendChild(defs);
                svg.appendChild(path);
                
                svg.setAttribute('style', 'position:absolute; top:0; left:0; width:100%; height:100%;')
                document.body.appendChild(svg);
            }
        </script>-->
    </xsl:template>
    
    <xsl:template match="anchor[.=''][@xml:id]" mode="#default deletion addition">
        <span id="{@xml:id}" class="anchor invisible">x</span>
    </xsl:template>
    
    
    
    
    <!-- special case MN246 -->
    <xsl:template match="text[@xml:id='mn246']//choice[seg[@n]]" mode="#default deletion addition">
                <xsl:value-of select="substring-after(seg[2],'ou')"/>  
    </xsl:template>
    
    
    
</xsl:stylesheet>