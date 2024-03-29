xquery version "3.1";

module namespace doc="http://localhost:8080/exist/apps/pessoa/doc";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "author.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";
import module namespace app="http://localhost:8080/exist/apps/pessoa/templates" at "app.xql";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";


declare namespace tei="http://www.tei-c.org/ns/1.0";


(: declare variable $ms:id := request:get-parameter("id", ()); :)

declare function doc:get-title($node as node(), $model as map(*), $id as xs:string) as node()+{
    let $xml := doc:get-xml($id)//tei:fileDesc
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc.xsl")
    let $title :=  <h2>{for $elem in $xml//tei:title/node() return if(exists($elem/node())) then <span class="doc_superscript">{$elem/node()/data(.)}</span> else replace($elem,"/E3","")}</h2>
 (:   let $title := <h2>{substring-before($xml//tei:title/data(.),"/E3"),substring-after($xml//tei:title/data(.),"/E3")}</h2>:)
    let $date := <p id="titledate">{$xml//tei:origDate/data(.)}</p>
    return <div>{$title} {$date}</div>
};

declare function doc:get-indexes($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/lists.xsl")
    return transform:transform($xml, $stylesheet, (<parameters><param name="lang" value="{$helpers:web-language}" /><param name="host" value="{$helpers:app-root}"/></parameters>))
};

declare function doc:createLink($node as node(), $model as map(*),$id as xs:string, $type as xs:string) {
    let $types := ("diplomatic-transcription","first-version","last-version")
    let $links := for $typ in $types 
                            return 
                           if($typ eq $type) then <li class="selected tabs"><span>{helpers:singleElementInList_xQuery("tabs",$typ)}</span></li>
                           else <li class="tabs"><a href="{$helpers:app-root}/{$helpers:web-language}/doc/{$id}/{$typ}"><span>{helpers:singleElementInList_xQuery("tabs",$typ)}</span></a></li>
  return $links
                            
};

declare function doc:catch-text($node as node(), $model as map(*),$id as xs:string, $type as xs:string) as item()+ {
        let $xml := doc:get-xml($id)
        return switch($type) 
                case "diplomatic-transcription" return doc:get-text($xml)
                case "first-version" return doc:get-text-var1($xml)
                case "last-version" return doc:get-text-var2($xml)
                default return doc:get-text($xml)
};

declare function doc:get-text($xml) as item()+{
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function doc:get-text-edited($node as node(), $model as map(*),$id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc-edited.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function doc:get-text-var1($xml) as item()+{
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc-var1.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function doc:get-text-var2($xml) as item()+{
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc-var2.xsl")
    return transform:transform($xml, $stylesheet, ())
};




declare function doc:get-image($node as node(), $model as map(*), $id as xs:string) as item()+{
    (: Imageviewer :)
    let $file-names := doc:get-xml($id)//tei:graphic/@url/data(.)
    let $num-files := count($file-names)
    return
    (<div id="openseadragon1" ></div>,
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


declare %templates:wrap function doc:docControll($node as node(), $model as map(*), $id as xs:string) {
      let $libary :=      if(helpers:contains-any-of($id,('BNP','CP'))) then "doc"
                         else "pub"
    let $db := doc('/db/apps/pessoa/data/doclist.xml')
      let $loged := config:logged-in()
    let $list := if($loged) then $db//docs[@dir=$libary]/doc else  $db//docs[@dir=$libary]/doc[@availability eq "free"]
    let $doc := $list[@id = $id]
    let $sum := count($list)
    let $pos := if($loged) then xs:integer($doc/@pos/data(.))  else helpers:index-of-node($list,$doc)
    let $forward := if($pos != $sum) then $pos+1 else 1
    let $backward := if($pos != 1) then ($pos) -1 else $sum

    let $arrows := if($loged) then
        <div>
            <a href="{concat($helpers:app-root,'/',$helpers:web-language,'/',$libary,'/',$list[@pos = $backward]/@id/data(.))}">
                <span id="back">
                    {helpers:singleElementInList_xQuery('buttons',"previous")}
                </span>
            </a>
            <a href="{concat($helpers:app-root,'/',$helpers:web-language,'/',$libary,'/',$list[@pos = $forward]/@id/data(.))}">
                <span id="forward">
                    {helpers:singleElementInList_xQuery('buttons','next')}
                </span>
            </a>
            <div class="clear"></div>
        </div>
        else <div>
                            <a href="{concat($helpers:app-root,'/',$helpers:web-language,'/',$libary,'/',$list[$backward]/@id/data(.))}">
                                <span id="back">
                                    {helpers:singleElementInList_xQuery('buttons',"previous")}
                                </span>
                            </a>
                            <a href="{concat($helpers:app-root,'/',$helpers:web-language,'/',$libary,'/',$list[$forward]/@id/data(.))}">
                                <span id="forward">
                                    {helpers:singleElementInList_xQuery('buttons','next')}
                                </span>
                            </a>
                            <div class="clear"></div>
                    </div>
    return $arrows
};

declare function doc:footerfilter($node as node(), $model as map(*), $id as xs:string,$dir as xs:string) {
             map {
                "xmllink" : <a class="filter-a" href="{$helpers:app-root}/{$dir}/{$id}/xml" target="_blank">XML</a>,
                "footercitar" : "test"
                                            
                
            }
};

declare function doc:cite($node as node(), $model as map(*),$id as xs:string, $dir as xs:string, $type) {
<span>{
                for $elem in helpers:singleElementNode_xquery("cite","cite-tx")/tei:span
                                            return 
                                            switch($elem/@type)
                                                case "web" return <i>{helpers:singleElementInList_xQuery("cite","cite-web")}</i>
                                                case "link" return concat(' "',doc(concat("/db/apps/pessoa/data/",$dir,"/",$id,".xml"))//tei:titleStmt/tei:title[1],'." ')
                                                case "url" return
                                                    <a class="olink" href="{concat($helpers:app-root,'/',$id,'/',$type)}">
                                                        {if($dir eq 'doc') then
                                                            concat(' <',$helpers:app-root,'/doc/',$id,'/',replace($type," ",""),'>')
                                                        else
                                                            concat(' <',$helpers:app-root,'/pub/',$id,'/diplomatic-transcription>')
                                                        }
                                                    </a>
                                                case "doi" return (" DOI: ",<a id="tx-doi" class="doilink" href="https://dx.doi.org/{$elem/data(.)}">{$elem/data(.)}</a>)
                                                default return $elem
                                            }</span>};
(:
(
                                            :)

                (:
                replace(helpers:singleElement_xquery("cite","cite-tx"),"#LINK#",concat('"',doc(concat("/db/apps/pessoa/data/",$dir,"/",$id,".xml"))//tei:titleStmt/tei:title[1],'."')):)

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

declare function doc:get-genre_type($node as node(), $model as map(*),$type as xs:string) as node() {
    <h1>{ helpers:singleElementInList_xQuery("genres",$type)}</h1>
};


declare function doc:notaButton($node as node(), $model as map(*)) {
    <script>
        DocHide("{helpers:singleElementInList_xQuery("buttons","note")}")
    </script>

};