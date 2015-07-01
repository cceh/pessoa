xquery version "3.0";

module namespace obras="http://localhost:8080/exist/apps/pessoa/obras";


import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";

declare function obras:test($node as node(), $model as map(*), $id as xs:string?) as node()* {
    let $test := "Hello"
    return <p>{$test, $id}</p>
};

declare function obras:getObras($node as node(),$model as map(*), $id as xs:string) as node()* {
    let $list := doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]
    let $stages := if(exists($list/tei:list/tei:item/tei:list)) then 2
                            else 1
    return for $stage in (0 to $stages) 
                    for $item in obras:getTitles($id, $stage)
                        return (<div>  { 
                             if ($item/@ref/data(.) != "") then<p> <a href="{$item/@ref/data(.)}" class="wlink">{$item/@key/data(.)},{$item/@title/data(.)}</a> </p>
                             else <p> {$item/@key/data(.)},{$item/@title/data(.)} </p>} { 
                        if(exists(obras:getLinks($item/@key/data(.)) )) then                      
                            <div> 
                                <ul>{ for $links in obras:getLinks($item/@key/data(.)) return <a class="olink" href="{$links/@ref/data(.)}"><li>{$links/@doc/data(.)}</li></a>}</ul>
                            </div> else () }
                        </div> )
};


declare function obras:getTitles ($id as xs:string, $stage as xs:integer) as item()* {
   if($stage = 0) then 
        for $item in  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]
            let $ref := if(exists(obras:buildSearch($item/attribute(),"pub")) ) then concat($helpers:app-root,"/",$helpers:web-language,"/pub/", substring-before(root(obras:buildSearch($item/attribute(),"pub"))/util:document-name(.),".xml")) else ""
             return <item title="{$item/tei:title/data(.)}" key="{$item/attribute()}" ref="{$ref}"/>
    else if ($stage = 1) then    for $item in  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id] /tei:list/tei:item 
            let $ref :=if(exists($item/attribute())) then
                                if(obras:buildSearch($item/attribute(),"pub") != "" ) then concat($helpers:app-root,"/",$helpers:web-language,"/pub/", substring-before(root(obras:buildSearch($item/attribute(),"pub"))/util:document-name(.),".xml")) else ""
                                else ""
            return (<item title="{$item/tei:title/data(.)}" key="{$item/attribute()}" ref="{$ref}"/>,
            if(exists($item/tei:list)) then 
                for $subitem in  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id] /tei:list/tei:item/tei:list/tei:item 
                let $ref := if(exists(obras:buildSearch($subitem/attribute(),"pub")) ) then concat($helpers:app-root,"/",$helpers:web-language,"/pub/",substring-before(root(obras:buildSearch($subitem/attribute(),"pub"))/util:document-name(.),".xml")) else ""
                     return <item title="{$subitem/tei:title/data(.)}" key="{$subitem/attribute()}" ref="{$ref}"/>
                    else () )
   else ()

};

declare function obras:getLinks($id as xs:string) as item()* {
        for $item in obras:buildSearch($id,"doc") 
        let $doc := substring-before(root($item)/util:document-name(.),".xml")
        let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/doc/",$doc)
        return <item doc="{$doc}"  ref="{$ref}"/>
};

declare function obras:buildSearch($id as xs:string, $type as xs:string) as node()* {
        let $db := if($type = "doc") then collection( "/db/apps/pessoa/data/doc")
                           else collection( "/db/apps/pessoa/data/pub")
        let $key := if($type ="doc") then "person" else "key"
        let $search_terms := concat('("type","',$key,'"),"work","',$id,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};