xquery version "3.0";

(:~
 : Modul, das verschiedene einfache Hilfsfunktionen enthält,
 : speziell zur Erzeugung komplexerer und oft verwendeter HTML-Elemente
 :)

module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";



(: web-root of the app :)
declare variable $helpers:app-root := $config:webapp-root;
(: declare variable $helpers:file-path := $config:file-path; :)
declare variable $helpers:request-path := $config:request-path;
declare variable $helpers:webfile-path := $config:webfile-path;
declare variable $helpers:web-language := if(contains($config:request-path,"/en/")) then "en"
                                            else if(contains($config:request-path,"/de/")) then "de"
                                            else "pt";
(:
declare variable $helpers:web-language := ();

    let $lang :=  if(request:get-parameter("plang",'')!="") then request:get-parameter("plang",'') else "pt"
    return $lang
    ; :)
    
declare function helpers:app-root($node as node(), $model as map(*)){
 let $elname := $node/node-name(.)
 
 return if (xs:string($elname) = "link")
        then <link href="{$helpers:app-root}/{$node/@href}">
                {$node/@*[not(xs:string(node-name(.)) = "href") and not(xs:string(node-name(.)) = "class")]}
                {helpers:copy-class-attr($node)}
             </link>
        else if (xs:string($elname) = "script" and $node/@type = "text/javascript")
        then <script type="{$node/@type}" src="{$helpers:app-root}/{$node/@src}" />
        else if (xs:string($elname) = "img")
        then <img src="{$helpers:app-root}/{$node/@src}">
                {$node/@*[not(xs:string(node-name(.)) = "src") and not(xs:string(node-name(.)) = "class")]}
                {helpers:copy-class-attr($node)}
             </img>
        else if (xs:string($elname) = "a")
             then <a href="{$helpers:app-root}/{$helpers:web-language}/{$node/@href}">
                    {$node/@*[not(xs:string(node-name(.)) = "href") and not(xs:string(node-name(.)) = "class")]}
                    {helpers:copy-class-attr($node)}
                    {templates:process($node/node(), $model)}
                  </a>
        else if (xs:string($elname) = "form")
             then <form action="{$helpers:app-root}/{$node/@action}">
                    {$node/@*[not(xs:string(node-name(.)) = "action") and not(xs:string(node-name(.)) = "class")]}
                    {helpers:copy-class-attr($node)}
                    {templates:process($node/node(), $model)}
                  </form>
        else $node
};

declare function helpers:copy-class-attr($node as node()){
    attribute class {$node/@class/concat(substring-before(., "helpers:app-root"), substring-after(., "helpers:app-root"))}
};

declare function helpers:copy-all-class($node as node()) {
        attribute class {$node/@class}
 };

declare function helpers:getValue($node as node(), $model as map(*), $get as xs:string) {
        $model($get)
};

(:~
 : Eine each Funktion zur Verwendung in views, identisch mit templates:each, 
 : aber ohne %templates:wrap Annotation, also ohne zusätzliches umschließendes
 : $node - Element
 :)
declare function helpers:each($node as node(), $model as map(*), $from as xs:string, $to as xs:string) {
    for $item in $model($from)
    return
        element { node-name($node) } {
            $node/@*, templates:process($node/node(), map:new(($model, map:entry($to, $item))))
        }
};

(:~
 : Identisch zu helpers:each aber ganz ohne irgendein umschließendes Element
 :)
declare function helpers:invisibleEach($node as node(), $model as map(*), $from as xs:string, $to as xs:string) {
    for $item in $model($from)
    return
        templates:process($node/node(), map:new(($model, map:entry($to, $item))))
};

declare function helpers:lettersOfTheAlphabet() {
    ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
};

declare function helpers:lettersOfTheAlphabeHight() {
('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
};

declare %templates:wrap function helpers:singleElement($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')    
    return helpers:singleAttribute($doc,$xmltype,$xmlid)     
};

declare function helpers:singleElementHidden($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')    
    return helpers:singleAttribute($doc,$xmltype,$xmlid)     
};



declare function helpers:singleAttribute($doc as node(),$type as xs:string,$id as xs:string) as xs:string? {
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry/data(.)
};


declare function helpers:singleElement_xquery($type as xs:string,$id as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')   
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry/data(.)
};

declare function helpers:singleElementNode_xquery($type as xs:string,$id as xs:string)  {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')   
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry
};
declare function helpers:singleElementList_xquery($type as xs:string,$id as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')   
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]
                  else $doc//tei:list[@type=$type and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]
     return $entry/data(.)
};