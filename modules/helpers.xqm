xquery version "3.0";

(:~
 : Modul, das verschiedene einfache Hilfsfunktionen enthält,
 : speziell zur Erzeugung komplexerer und oft verwendeter HTML-Elemente
 :)

module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";


(: web-root of the app :)
declare variable $helpers:app-root := $config:webapp-root;
(: declare variable $helpers:file-path := $config:file-path; :)
declare variable $helpers:request-path := $config:request-path;
declare variable $helpers:webfile-path := $config:webfile-path;
declare variable $helpers:web-language := if(contains($helpers:request-path,"en")) then "en" else "pt";
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
             then <a href="{$helpers:app-root}/{$node/@href}">
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