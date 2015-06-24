xquery version "3.0";

module namespace doc="http://localhost:8080/exist/apps/pessoa/doc";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "author.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";
import module namespace app="http://localhost:8080/exist/apps/pessoa/templates" at "app.xql";


declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";


(: declare variable $ms:id := request:get-parameter("id", ()); :)

declare function doc:get-title($node as node(), $model as map(*), $id as xs:string) as node()+{
    let $xml := doc:get-xml($id)
    let $title := <h2>{$xml//tei:title/data(.)}</h2>
    let $date := <p id="titledate">{$xml//tei:origDate/data(.)}</p>
    return <div>{$title} {$date}</div>
};

declare function doc:get-indexes($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/lists.xsl")
    return transform:transform($xml, $stylesheet, (<parameters><param name="lang" value="{$helpers:web-language}" /></parameters>))
};

declare function doc:get-text($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function doc:get-text-edited($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc-edited.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function doc:get-text-var1($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc-var1.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function doc:get-text-var2($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc-var2.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function doc:get-text-pessoal($node as node(), $model as map(*), $id as xs:string, $lb as xs:string, $abbr as xs:string, $version as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := 
    if($version ="first") then doc("/db/apps/pessoa/xslt/doc-var1.xsl")
    else if($version ="last") then
       doc("/db/apps/pessoa/xslt/doc-var2.xsl")
    else doc("/db/apps/pessoa/xslt/doc-pessoal.xsl")
    return
    if($lb="yes") then
        if($abbr ="yes") then
             transform:transform($xml, $stylesheet, (<parameters><param name="lb" value="yes"/><param name="abbr" value="no"/></parameters>))
        else
            transform:transform($xml, $stylesheet, (<parameters><param name="lb" value="yes"/><param name="abbr" value="yes"/></parameters>))
           
    else
        if($abbr="yes") then
            transform:transform($xml, $stylesheet, (<parameters><param name="lb" value="no"/><param name="abbr" value="yes"/></parameters>))
        else
            transform:transform($xml, $stylesheet, (<parameters><param name="lb" value="no"/><param name="abbr" value="no"/></parameters>))
};

declare function doc:get-genre($node as node(), $model as map(*), $type as xs:string, $orderBy as xs:string) as item()*{  
    let $i := if($orderBy = "alphab") then 2 else 5
    let $docs := 
        for $doc in collection("/db/apps/pessoa/data") where ($doc//tei:rs[@type ="genre" and @key =$type])
        return $doc
    let $years :=
        for $doc in $docs 
        return fn:substring(author:getYearOrTitle($doc,$orderBy),0,$i) 
    let $years := fn:distinct-values($years)
    return (doc:getNavigation($years, $type),
    for $year in $years 
        let $docsInYear :=  
            for $doc in $docs where(fn:substring(author:getYearOrTitle($doc,$orderBy),0,$i) = $year) return $doc
    order by $year       
    return (<div class="sub_Nav"><h2 id="{$year}">{if ($year = "B") then "BNP" else if ($year = "M") then "MN" else $year}</h2></div>,
     for $doc in $docsInYear 
     order by (author:getYearOrTitle($doc,$orderBy))
     return
        if ($doc//tei:sourceDesc/tei:msDesc)
                    then  ( <div class="doctabelcontent"><a href="{$helpers:app-root}/doc/{substring-before(replace(replace(($doc//tei:idno)[1]/data(.), "/","_")," ", "_"),".xml")}">{($doc//tei:title)[1]/data(.)}</a></div>)                              
                    else (<div class="doctabelcontent"><a href="{$helpers:app-root}/{substring-before(substring-after(document-uri($doc),"/db/apps/pessoa/data"),".xml")}">{($doc//tei:sourceDesc[1]/tei:biblStruct[1]/tei:analytic/tei:title)[1]/data(.)}</a></div>)           
    ) )     
};

declare function doc:getNavigation($years, $type){
    let $years := for $year in $years order by $year 
    return 
    if ($year = 'B') then "BNP"
    else
    if($year = 'M') then "MN"
    else
    $year
    return
    <div class="navigation"> 
        {for $year at $i in $years
        order by $year
            return if ($i = count($years)) then
                <a href="#{$year}">{$year}</a>
                else
                (<a href="#{$year}">{$year}</a>,<span>|</span>)
        }  
        <br/>
        <br/>
    </div>
};


declare function doc:get-image($node as node(), $model as map(*), $id as xs:string) as item()+{
    (: Imageviewer :)
    let $file-names := doc:get-xml($id)//tei:graphic/@url/data(.)
    let $num-files := count($file-names)
    return
    (<div id="openseadragon1" style="width: 400px; height: 380px;"></div>,
    <script src="{$helpers:app-root}/resources/js/openseadragon.js"></script>,
    <script type="text/javascript">
        var viewer = OpenSeadragon({{
            id: "openseadragon1",
            prefixUrl: "{$helpers:app-root}/resources/images/",
    	    showNavigator:  true,
            tileSources: {if ($num-files gt 1)
                         then ("[",
                                for $file-name at $pos in $file-names
                                let $file-name := doc:get-image-xml-file($file-name)
                                return (concat('"',$helpers:webfile-path,"/","imageinzoom","/",$file-name,'"'), if ($pos lt $num-files) then "," else ())
                           ,"]")
                         else let $file-name := doc:get-image-xml-file($file-names)
                              return concat('"',$helpers:webfile-path,"/","imageinzoom","/",$file-name, '",')
                         }
    		
        }});
    </script>)
    (: Imageviewer :)
};

declare function doc:get-image-xml-file($file-name){
    lower-case(substring-after(concat(substring-before($file-name, ".jpg"), ".xml"), "/"))
};


declare function doc:get-year($node as node(), $model as map(*), $year as xs:string)as item()*{
    let $docs := collection("/db/apps/pessoa/data")    
    return for $doc in $docs
        return if($doc//tei:origDate[@when])
            then 
                if($doc//tei:origDate[@when=$year])
                then (<a href="{$helpers:app-root}/doc/{replace(replace($doc//tei:idno/data(.), "/","_")," ", "_")}">{ $doc//tei:idno/data(.)}</a>,<br />)
                else ()
          
   
           else ()
                
};

declare function doc:get-xml($id){
    let $file-name := concat($id, ".xml")
    return doc(concat("/db/apps/pessoa/data/doc/", $file-name)) 
};


declare %templates:wrap function doc:docControll($node as node(), $model as map(*)) {
    let $db := collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
    let $doc := if(substring-after($helpers:request-path,"doc/")) 
                    then substring-after($helpers:request-path,"doc/")
                else substring-after($helpers:request-path,"pub")
    let $index := index-of($db,doc(concat("/db/apps/pessoa/data/doc/",$doc,".xml")))    
    let $libary :=  if(substring-after($helpers:request-path,"doc/")) 
                    then "doc"
                else "pub"

    let $arrows := <div>
                            <a href="{concat($helpers:app-root,'/',$helpers:web-language,'/',$libary,'/',substring-before(root($db[position() = (($index) -1)])/util:document-name(.),".xml"))}">
                                <span id="back"> 
                                    {page:singleAttribute(doc('/db/apps/pessoa/data/lists.xml'),"buttons","previous")}
                                </span>
                            </a>
                            <a href="{concat($helpers:app-root,'/',$helpers:web-language,'/',$libary,'/',substring-before(root($db[position() = (($index) +1)])/util:document-name(.),".xml"))}">
                                <span id="forward">
                                    {page:singleAttribute(doc('/db/apps/pessoa/data/lists.xml'),"buttons","next")}
                                </span>
                            </a>
                            <div class="clear"></div>
                    </div>
    return $arrows
};

declare function doc:footerfilter($node as node(), $model as map(*)) {
let $doc := doc("/db/apps/pessoa/data/lists.xml")
let $script :=     <script>
  $("#zitat").click(function() {{
    $( "#dialog" ).dialog();
  }});
  </script>
  let $popup:= 
  <div id="dialog" title="Basic dialog" style="display:none;border:solid">
  <p>This is the default dialog which is useful for displaying information. The dialog window can be moved, resized and closed with the 'x' icon.</p>
</div>
let $filter := <div id="filter">
                <a class="filter-a" href="">{page:singleAttribute($doc, "footer","print")}</a>
                <a class="filter-a" href="{$helpers:request-path}/xml" target="_blank">XML</a>
                <a class="filter-a" id="zitat" >{page:singleAttribute($doc, "footer","cite")}</a>
            </div>
            return ($filter,$script,$popup)
};

declare  function doc:get-recorder($node as node(), $model as map(*)) as node() {
    let $script := <script type="text/javascript">
        
        function reorder(){{
        if ($("#date").is(":checked"))
        {{
        $("#genreList").load("{$helpers:request-path}?orderBy=date");
        
        }}
        else{{
        $("#genreList").load("{$helpers:request-path}?orderBy=alphab"); 
        }}
        }}
    </script> 
    return $script
};

declare function doc:get-genre_type($node as node(), $model as map(*)) as node() {
    let $type := substring-after($helpers:request-path,"genre/")
   
    let $title := if($helpers:web-language = "pt") 
        then data(doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="genres"][@xml:lang=$helpers:web-language]/tei:item[@xml:id=$type])
        else data(doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="genres"][@xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$type)])
    return <h2>{ $title}</h2>
};

declare function doc:get-versaoPessoal($node as node(), $model as map(*)) as node() {
let $script := <script type="text/javascript">

        function versaoPessoal(){{
            var url = window.location.href;
            var i = url.lastIndexOf("/");
            var j = url.lastIndexOf("#");
            var id = url.substring(i+1,j);
           
            var toLoad = "http://localhost:8080/exist/apps/pessoa/{$helpers:web-language}/page/doc/versao-pessoal?id=" + id;
            if ($("#lb").is(":checked"))
            {{
               toLoad = toLoad.concat("&amp;lb=yes");
            }}
            else
            {{
            toLoad = toLoad.concat("&amp;lb=no");
            }}
            if ($("#abbr").is(":checked"))
            {{
               toLoad = toLoad.concat("&amp;abbr=yes");
            }}
            else
            {{
                toLoad = toLoad.concat("&amp;abbr=no");
            }}
            
            if ($("#diplomatic").is(":checked"))
            {{
               toLoad = toLoad.concat("&amp;version=diplomatic");
            }}
            if ($("#first").is(":checked"))
            {{
               toLoad = toLoad.concat("&amp;version=first");
            }}
          
            if ($("#last").is(":checked"))
            {{
               toLoad = toLoad.concat("&amp;version=last");
            }}
             $("#tabs-4-text").load(toLoad);
             
             
             
           
        }}
        
        
        if ( window.addEventListener ) {{
        addEventListener( "load", draw(100,100), false );
        }} else {{
        attachEvent( "onload", draw(100,100) );
        }}
        
function draw(w, h) {{
var canvas = document.getCSSCanvasContext("2d", "lines", w, h); 
canvas.strokeStyle = "rgb(0,0,0)";
canvas.beginPath();
canvas.moveTo( 0,0);
canvas.lineTo( w, h );
canvas.stroke();

var canvas2 = document.getCSSCanvasContext("2d", "verticalLine", w, h);
canvas2.strokeStyle = "rgb(0,0,0)";
canvas2.beginPath();
canvas2.moveTo( 0,0);
canvas2.lineTo( 10,60 );
canvas2.stroke();

var canvas3 = document.getCSSCanvasContext("2d", "circle", w, h);
canvas3.strokeStyle = "rgb(0,0,0)";
canvas3.beginPath();
canvas3.arc(12,12,12,0,2*Math.PI);
canvas3.stroke();
}}


    </script>
    return $script
};

(:declare function doc:getIndex($node as node(), $model as map(*), $type){
     let $lists := doc('/db/apps/pessoa/data/lists.xml')
     let $docs := collection("/db/apps/pessoa/data/doc/") 
     let $journals := 
        for $doc in $docs return
        $doc//tei:text//tei:rs[@type='journal']
     let $journalKeys := $lists//tei:list[@type='journal']/@xml:id
     let $journalNames := $lists//tei:list[@type='journal']/item
     let $letters :=
        for $name in $journalNames return substring($name,0,2)
     let $letters := distinct-values($letters)
     return 
        (doc:getNavigation($letters),
        for $letter in $letters 
            let $journalsWithLetter := 
                for $name in $journalNames where (substring($name,0,2) = $letter) return $name
            order by upper-case($name)
            return 
             (<div class="sub_Nav"><h2 id="{$letter}">{$letter}</h2></div>,
            for $journal in $journalsWithLetter order by $journal return
            (<div class="indexItem">{$journal}</div>,<ul class="indexDocs">{
            doc:getDocsForItem($item, $type)}</ul>)))
            
};:)

declare function doc:getIndex($node as node(), $model as map(*), $type){
    let $lists := doc('/db/apps/pessoa/data/lists.xml')
    let $docs := collection("/db/apps/pessoa/data/doc/")   
    let $items := 
        for $doc in $docs return
        if($type='journal') then 
        $doc//tei:text//tei:rs[@type=$type]/@key
        else
            $doc//tei:text//tei:rs[@type=$type][not(child::tei:choice/tei:abbr)][not(child::tei:pc)]
    let $items := distinct-values($items) 
    let $items := 
        for $item in $items return $item(:replace(replace(replace($item,'"',''),'“',''),'”',''):)
    let $letters := 
        for $item in $items order by $item return
            fn:substring($item,0,2)
    let $letters := distinct-values($letters)
    return (doc:getNavigation($letters),
        for $letter in $letters 
            let $itemsWithLetter := 
                for $item in $items where (substring($item,0,2) = $letter) return  $item
        order by upper-case($item)
        return 
            (<div class="sub_Nav"><h2 id="{$letter}">{$letter}</h2></div>,
            for $item in $itemsWithLetter order by $item return
            (<div class="indexItem">{if($type='journal') then ($lists//tei:list[@type='journal']/tei:item[@xml:id=$item]) else $item}</div>,<ul class="indexDocs">{
            doc:getDocsForItem($item, $type)}</ul>)))
};

declare function doc:getDocsForItem($item, $type){
    let $docs := collection("/db/apps/pessoa/data/doc/")
    let $docsForItem := 
    if($type='journal') then
        for $doc in $docs return
        if($doc//tei:text//tei:rs[@type=$type]/@key = $item) then $doc else ()
    else
        for $doc in $docs return
            if($doc//tei:text//tei:rs[@type=$type][not(child::tei:choice/tei:abbr)][not(child::tei:pc)]= $item) then $doc else ()
            
    for $doc in $docsForItem return
    <li class="indexDoc">
    <a style="color: #08298A;" href="{$helpers:app-root}/doc/{substring-before(replace(replace(($doc//tei:idno)[1]/data(.), "/","_")," ", "_"),".xml")}">{($doc//tei:title)[1]/data(.)} </a>
    </li>
};

declare function doc:getNavigation($letters){
    <div class="navigation">
        {for $letter at $i in $letters order by $letter return
        if($i = count($letters)) then <a style="color: #08298A;" href="#{$letter}">{$letter}</a> else
        (<a style="color: #08298A;" href="#{$letter}">{$letter}</a>,<span>|</span>)}
    </div>
};




