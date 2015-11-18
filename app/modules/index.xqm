
module namespace index="http://localhost:8080/exist/apps/pessoa/index";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";


(:######### MODULAR #######:)

declare function index:printLetter($node as node(), $model as map(*)) {
    let $letter := $model("letter")
    return <h2 id="{$letter}">{$letter}</h2>
};

declare function index:printNavigation($node as node(), $model as map(*)) {
<div class="navigation">{for $letter in $model("letters") return ( <a href="#{$letter}">{$letter}</a>,<span>|</span>)}</div>

};

declare function index:printDocLinks($node as node(), $model as map(*)) {
let $doc := $model("ref")
(:let $doc := substring-before(root($db)/util:document-name(.),".xml") :)
 let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/doc/",$doc)
return <a href="{$ref}" class="olink">{$doc}</a>
};

(:####### TEXT INDEX #######:)

declare function index:collectTexts($node as node(), $model as map(*)) {
    let $texts := for $text in  search:search_range_simple("type","text",collection('/db/apps/pessoa/data/doc'))
                                for $single in $text//tei:rs[@type = "text"][not(child::tei:choice/tei:abbr)][not(child::tei:pc)]
                                order by $single
                            return $single
                            (:<item title="{$single}" well="{replace(replace(replace($single,'"',''),'“',''),'”','')}"/>:)
                            
   let $docs := for $doc in $texts
                            return <item name="{$doc}"  ref="{substring-before(root($doc)/util:document-name(.),".xml")}"/>
                            
    let $names := distinct-values($texts)
    let $well := for $name in $names
                  (:  let $wellformed := if(  for $let in (a to z) 
                                                           where substring($name,1,1) eq $let 
                                                           return xs:boolean
                    
                    ) then substring($name,2) else $name :)
                    return <item title="{$name}" well="{replace(replace(replace($name,'"',''),'“',''),'”','')}"/>
    
    (:<item name="{$single}"  ref="{substring-before(root($text)/util:document-name(.),".xml")}"/>:)
    let $letters := for $letter in $well/@well return substring($letter,1,1)
    let $letters := distinct-values($letters)
    return map {
        "texts" := $well,
        "allDocs" := $docs,
        "letters" := $letters
    }

};


declare function index:scanTexts($node as node(), $model as map(*)) {
    let $texts := for $text in $model("texts") where substring($text/@well,1,1) eq $model("letter") return $text 
    
    return map {
        "scTexts" := $texts
        }
    
};

declare function index:scanDocs($node as node(), $model as map) {
        let $text := $model("text")
        let $aDocs := $model("allDocs")
        let $docs := for $doc in $aDocs where $doc/@name eq $text/@title  return $doc/@ref/data(.)
        
        return map {
        "refs" := $docs
        }
};

declare function index:test($node as node(), $model as map(*),$get as xs:string) {
        $model($get)/@well/data(.)

};



(:######## PERSON INDEX #######:)

declare function index:getPersonIndex($node as node(), $model as map(*)) {
    let $letter :=  $model("letter")
    let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson[2]
    let $keys := for $hit in $lists/tei:person
                            let $id := $hit/attribute()/data(.)
                         return 
                         if( exists($hit/tei:persName[2]))
                                then for $name in $hit/tei:persName
                                    where substring($name/data(.),1,1) eq $letter
                                    return <item id="{$id}" style="{$name/@type/data(.)}"/>
                                    else if(substring($hit/tei:persName/data(.),1,1) eq $letter) then <item id="{$id}"/>
                                    else ()
                               
     return map {
     "keys" := $keys 
     }

};

declare function index:ScanDB($node as node(), $model as map(*)) {
    let $coll:= collection("/db/apps/pessoa/data/doc/") 
    let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson
    let $db := $model("key")
    let $letter := $model("letter")
    let $name := if(exists($db/@style)) then 
                                 if(contains($db/@id,"#")) then 
                                    $lists/tei:person[@corresp=$db/@id]/tei:persName[@type=$db/@style]/data(.)
                                 else
                                    $lists/tei:person[@xml:id=$db/@id]/tei:persName[@type=$db/@style]/data(.)
                            else 
                                if(contains($db/@id,"#")) then 
                                   $lists/tei:person[@corresp=$db/@id]/tei:persName/data(.)
                               else 
                                   $lists/tei:person[@xml:id=$db/@id]/tei:persName/data(.)

    let $id := if(contains($db/@id,"#")) then substring-after($db/@id,"#") else $db/@id
    let $docs := if(exists($db/@style)) then 
                                for $doc in search:searchRange_ex_two($coll,"person","style",$id,$db/@style) where $doc//tei:rs[@type = "person" and  @key = $id and @style=$db/@style] return $doc
                                else
                                for $doc in search:search_range_simple("person",$id,$coll) where $doc//tei:rs[@type = "person" and  @key = $id] return $doc
    
    let $res := for $doc in $docs
                                let $cota := ($doc//tei:title)[1]/data(.)
                          (:     let $cota2 := if(contains($cota,"-")) then replace(substring-before($cota,"-"), "(BNP/E3|MN)\s?([0-9]+)([^0-9]+.*)?", "$2")
                                                        else replace($cota, "(BNP/E3|MN)\s?([0-9]+)([^0-9]+.*)?", "$2")
                                      :)                  
                                order by xs:integer(replace($cota, "(BNP/E3|MN)\s?([0-9]+)([^0-9]+.*)?", "$2"))
                                return substring-before(root($doc)/util:document-name(.),".xml") 
    
    return map {
       "docs" := $res,
        "name" := $name,
        "id" := $id
    }
};

declare function index:printAuthor($node as node(), $model as map(*)) {
    <span id="{$model("id")}">{$model("name")}</span>
};

declare function index:plottAlpha($ndoe as node(), $mode as map(*)) {
        let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson/tei:person
        let $letters := for $person in  $lists/tei:persName order by $person return fn:substring($person,1,1)
        let $letters := distinct-values($letters)
        return map {
            "letters" := $letters
        }
};


