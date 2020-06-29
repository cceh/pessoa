xquery version "3.0";

module namespace pub="http://localhost:8080/exist/apps/pessoa/pub";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";

declare function pub:get-title($node as node(), $model as map(*), $id as xs:string) as node()* {
   
   let $xml := (pub:get-xml($id))//tei:sourceDesc/tei:biblStruct/tei:monogr
    let $title := <h2>{(pub:get-xml($id))/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/data(.)}</h2>
    let $page := if( exists($xml/tei:biblScope[@unit="page"])) then (
        let $pa := $xml/tei:biblScope[@unit="page"]/data(.)
        let $se := if(contains($pa,"-")) then "pp." else "p."
        return concat( ", ", $se,$pa)
            )
    else ()
    let $author := <p class="titleline_additional" id="t_add_3"> {(pub:get-xml($id))//tei:sourceDesc/tei:biblStruct//tei:author/tei:rs/data(.)}</p>
    let $titlemaText := ($xml/tei:title/data(.),$xml/tei:biblScope[@unit="issue"]/data(.))  
    let $titlema := <p  class="titleline_additional" id="t_add_1"> {string-join($titlemaText," ")},</p>
    (:    let $titlema := <p  class="titleline_additional" id="t_add_1"> {$xml/tei:title/data(.)}{concat(" "," ")}{$xml/tei:biblScope[@unit="issue"]/data(.)},</p>:)
    let $datpa := <p class="titleline_additional" id="t_add_2"> {$xml/tei:imprint/tei:date/data(.)}{$page}.</p>
    return ($title,$author,$titlema,$datpa)

};


declare function pub:get-text($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := pub:get-xml($id)
    let $genre := $xml//tei:note[@type='genre']/tei:rs[@type="genre"]/@key
    let $stylesheet := if ($genre = "prosa") then doc("/db/apps/pessoa/xslt/pub-prose.xsl") else doc("/db/apps/pessoa/xslt/pub.xsl")
    return transform:transform($xml, $stylesheet, ())
};

declare function pub:get-xml($id){
    let $file-name := concat($id, ".xml")
    return doc(concat("/db/apps/pessoa/data/pub/", $file-name)) 
};

declare function pub:get-image($node as node(), $model as map(*), $id as xs:string) as item()+{
    (: Imageviewer :)
    let $file-names := pub:get-xml($id)//tei:graphic/@url/data(.)
    let $num-files := count($file-names)
    return
    (<div id="openseadragon1"></div>,
    <script src="{$helpers:app-root}/resources/js/openseadragon.js"></script>,
    <script type="text/javascript">
        var viewer = OpenSeadragon({{
            id: "openseadragon1",
            prefixUrl: "{$helpers:app-root}/resources/images/",
    	    showNavigator:  true,
            tileSources: {if ($num-files gt 1)
                         then ("[",
                                for $file-name at $pos in $file-names
                                let $file-name := pub:get-image-xml-file($file-name)
                                return (concat('"',$helpers:webfile-path,"/","imageinzoom","/",$file-name,'"'), if ($pos lt $num-files) then "," else ())
                           ,"]")
                         else let $file-name := pub:get-image-xml-file($file-names)
                              return concat('"',$helpers:webfile-path,"/","imageinzoom","/",$file-name, '",')
                         }
    		
        }});
    </script>)
    (: Imageviewer :)
};

declare function pub:get-image-xml-file($file-name){
    lower-case(substring-after(concat(substring-before($file-name, ".jpg"), ".xml"), "/"))
};

declare function pub:get-indexes($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := pub:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/lists.xsl")
    return transform:transform($xml, $stylesheet, (<parameters><param name="lang" value="{$helpers:web-language}" /><param name="host" value="{$helpers:app-root}"/></parameters>))
};