xquery version "3.1";

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
declare variable $helpers:web-language := if(contains($config:request-path,"/pt/")) then "pt"
                                            else if(contains($config:request-path,"/de/")) then "de"
                                            else "en";
declare variable $helpers:lists := doc('/db/apps/pessoa/resources/lists.xml');
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
declare function helpers:getValueMap($node as node(), $model as map(*),$container as xs:string,$key as xs:string) {

    $model($container)($key)
};

declare function helpers:createValueMap($node as node(), $model as map(*), $container as xs:string, $key as xs:string,$name as xs:string) {
    if(exists($model($container)) and exists($model($container)($key))) then
    map:merge(($model, map:entry($name, $model($container)($key))))
    else()
};

declare function helpers:createValueMapEach($node as node(), $model as map(*), $container as xs:string, $key as xs:string,$name as xs:string) {
    for $item in $model($container)($key)
    return
        templates:process($node/node(),map:merge(($model, map:entry($name, $item))))
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
            $node/@*, templates:process($node/node(), map:merge(($model, map:entry($to, $item))))
        }
};

(:~
 : Identisch zu helpers:each aber ganz ohne irgendein umschließendes Element
 :)
declare function helpers:invisibleEach($node as node(), $model as map(*), $from as xs:string, $to as xs:string) {
    for $item in $model($from)
    return
        templates:process($node/node(), map:merge(($model, map:entry($to, $item))))
};
(:)
declare function helpers:lettersOfTheAlphabet() {
    ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
};

declare function helpers:lettersOfTheAlphabeHight() {
('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
};
:)
(:)
declare %templates:wrap function helpers:singleElement($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/resources/lists.xml')
    return helpers:singleAttribute($doc,$xmltype,$xmlid)
};

declare function helpers:singleElementHidden($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/resources/lists.xml')
    return helpers:singleAttribute($doc,$xmltype,$xmlid)
};



declare function helpers:singleAttribute($doc as node(),$type as xs:string,$id as xs:string) as xs:string? {
    let $entry := if($helpers:web-language = "pt")
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry/data(.)
};
:)

(:)
declare function helpers:singleElement_xquery($type as xs:string,$id as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/resources/lists.xml')   
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry/data(.)
};
:)
declare function helpers:singleElementNode_xquery($ListType as xs:string, $ListId as xs:string)  {
    $helpers:lists//tei:list[@type=$ListType]/tei:item[@xml:id=$ListId]/tei:term[@xml:lang=$helpers:web-language]
};
(:)
declare function helpers:singleElementList_xquery($ListType as xs:string,$ListId as xs:string) as xs:string? {
    if($helpers:web-language = "pt")
                  then $helpers:lists//tei:list[@type=$ListType and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$ListId]
                  else $helpers:lists//tei:list[@type=$ListType and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$ListId)]
};
:)
declare function helpers:singleElementInList($node as node(), $model as map(*), $ListType as xs:string, $ListId as xs:string){
    helpers:singleElementInList_xQuery($ListType,$ListId)

};

declare function helpers:singleElementInList_xQuery($ListType as xs:string, $ListId as xs:string) as xs:string?{
    $helpers:lists//tei:list[@type = $ListType]/tei:item[@xml:id=$ListId]/tei:term[@xml:lang = $helpers:web-language]
};



declare function helpers:createInput_item($xmltype as xs:string,$btype as xs:string, $name as xs:string, $value as xs:string*) as node()* {
    for $id in $value
        let $entry := helpers:singleElementInList_xQuery($xmltype,$id)
        let $input := <input class="{concat($name,"_input-box")}" type="{$btype}" name="{$name}" value="{$id}" id="{$id}"/>
        let $label := <label class="{concat($name,"_input-label")}" for="{$id}">{$entry}</label>
        let $breaked := <br />
        return ($input,$label,$breaked)
};

declare function helpers:createInput_term($xmltype as xs:string, $btype as xs:string, $name as xs:string, $value as xs:string*, $checked as xs:string?) as node()* {
    for $id in $value
    let $entry := helpers:singleElementInList_xQuery($xmltype,$id)
    let $input := if($checked = "checked") then <input class="{concat($name,"_input-box")}" type="{$btype}" name="{$name}" value="{$id}" id="{$id}" checked="checked"/>
    else <input class="{concat($name,"_input-box")}" type="{$btype}" name="{$name}" value="{$id}" id="{$id}" />
    let $label := <label class="{concat($name,"_input-label")}" for="{$id}">{$entry}</label>
    let $breaked := <br />
    return ($input,$label,$breaked)
};

declare function helpers:createOption_new($xmltype as xs:string, $value as xs:string*) as node()* {
    for $id in $value
        let $entry:= helpers:singleElementInList_xQuery($xmltype,$id)
        let $val := if(exists($helpers:lists//tei:list[@type = $xmltype]/tei:item[@xml:id=$id]/tei:note[@type="range"])) then $helpers:lists//tei:list[@type = $xmltype]/tei:item[@xml:id=$id]/tei:note[@type="range"]/data(.) else $id
    return <option value="{$val}">{$entry}</option>
};


declare function helpers:index-of-node
( $nodes as node()* ,
        $nodeToFind as node() )  as xs:integer* {

    for $seq in (1 to count($nodes))
    return $seq[$nodes[$seq] is $nodeToFind]
} ;

declare function helpers:switchLang($node as node(), $model as map(*)) {
    let $request-path := if($config:request-path != "") then $config:request-path else "index.html"
    let $page :=     if(contains($config:request-path,concat("/",$helpers:web-language,"/"))) then substring-after($request-path,concat("/",$helpers:web-language,"/")) else substring-after($request-path,"pessoa//")

    return <script>
            function switchlang(value){{location.href="{$helpers:app-root}/"+value+"/{$page}";}}
        </script>
};

declare function helpers:switchLangNetwork($node as node(), $model as map(*)) {
    let $request-path := if($config:request-path != "") then $config:request-path else "index.html"
    let $page :=     if(contains($config:request-path,concat("/",$helpers:web-language,"/"))) then substring-after($request-path,concat("/",$helpers:web-language,"/")) else substring-after($request-path,"pessoa//")

    return <script>
        function switchlang(value){{location.href="{$helpers:app-root}/"+value+"/network/{$page}";}}
    </script>
};

declare function helpers:contains-any-of( $arg as xs:string?, $searchStrings as xs:string* )  as xs:boolean {

    some $searchString in $searchStrings
    satisfies contains($arg,$searchString)
} ;