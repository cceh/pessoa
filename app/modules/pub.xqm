xquery version "3.0";

module namespace pub="http://localhost:8080/exist/apps/pessoa/pub";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";

declare function pub:get-title($node as node(), $model as map(*), $id as xs:string) as node()* {
    let $xml := pub:get-xml($id)
    (: get the xml, title and author of the publication :)
    let $title := <h2>{$xml//tei:titleStmt/tei:title/data(.)}</h2>
    let $author := <p class="titleline_additional" id="t_add_3"> {$xml//tei:titleStmt/tei:author/tei:rs/data(.)}</p>
    return ($title, $author,
    
        (: get the details for each journal publication :)
        let $monogr := $xml//tei:sourceDesc/tei:biblStruct/tei:monogr
        return
            for $journal_pub in $monogr
                let $journal_title := $journal_pub/tei:title/data(.)
                let $journal_issue := $journal_pub/tei:biblScope[@unit="issue"]/data(.)
                let $date := $journal_pub/tei:imprint/tei:date/data(.)
                let $pages := if(exists($journal_pub/tei:biblScope[@unit="page"])) 
                             then let $pa := $journal_pub/tei:biblScope[@unit="page"]/data(.)
                                  let $pa_label := if(contains($pa,"-")) then "pp. " else "p. "
                                  return concat($pa_label,$pa)
                             else ()
                let $titleline := <p class="titleline_additional" id="t_add_1">{concat(string-join(($journal_title, $journal_issue)," "), ", ", string-join(($date, $pages), ", "), ".")}</p>
                return $titleline
    )
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