
module namespace index="http://localhost:8080/exist/apps/pessoa/index";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare function index:getPersonIndex($node as node(), $model as map(*)) {
    let $letter :=  $model("letter")

    let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson/tei:person
    
     (:      let $key if (contains($hit,"#")) then substring-after($hit,"#") else $hit :)
   let $keys := for $hit in $lists/attribute()/data(.)
                            for $person in $lists[@xml:id = $hit]/tei:persName/data(.) return
                            if( substring($person,1,1) eq $letter) then
                            let $key := if (contains($hit,"#")) then substring-after($hit,"#") else $hit
                            order by $person
                            return $key
                            else ()
                  
   (:
    let $keys := for $person in $lists/tei:persName[1]
                let $hit := if($lists/tei:persName[1] = $person) then 
                let $key := if (contains($hit/parent::tei:person/attribute()/data(.),"#")) then substring-after(../$hit/tei:person/attribute()/data(.),"#") else ../$hit/tei:person/attribute()/data(.)
                order by $person
                return $key
        else ():)           
     return map {
     "keys" := $keys 
     }

};


declare function index:ScanDB($node as node(), $model as map(*)) {
    let $coll:= collection("/db/apps/pessoa/data/doc/") 
    let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson
    let $db := $model("key")
    let $author := for $person in $lists/tei:person
                             return if( $person/attribute()/data(.) =$db) then
                              for $name in $person/tei:persName return
                                  if(substring($name,1,1) = $model("letter")) then $name  else () 
                             else ()
   let $styles := if(exists($author/@type)) then $author/@type else ""
   let $author := for $hit in $author return $hit/data(.)
  (:  let $style := $lists//tei:persName/@type :)
    
    let $docs := if($styles != "" ) then
                            for $style in $styles return
                            for $doc in search:searchRange_ex_two($coll,"person","style",$db,$style)
                              let $cota := ($doc//tei:title)[1]/data(.)
                              order by xs:integer(replace($cota, "(BNP/E3|MN)\s?([0-9]+)([^0-9]+.*)?", "$2"))
                             return $doc
                           else for $doc in search:search_range_simple("person",$db,$coll)
                              let $cota := ($doc//tei:title)[1]/data(.)
                              order by xs:integer(replace($cota, "(BNP/E3|MN)\s?([0-9]+)([^0-9]+.*)?", "$2"))
                             return $doc
    
    return map {
        "docs" := $docs,
       
        "style" := $styles
    }
};

declare function index:printAuthorName($node as node(), $model as map(*)) {
    let $db := $model("key")
    

    
    let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson/tei:person
    
    for $person in $lists
    return if( $person/attribute()/data(.) =$db) then
     for $name in $person/tei:persName return
         if(substring($name,1,1) = $model("letter")) then $name  else () 
    else ()

};

declare function index:printValue($node as node(), $model as map(*), $get as xs:string) {
    $model($get)

};

declare function index:printDocLinks($node as node(), $model as map(*)) {
let $db := $model("ref")
let $doc := substring-before(root($db)/util:document-name(.),".xml")
 let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/doc/",$doc)
return <a href="{$ref}" class="olink">{$doc}</a>
};

declare function index:plottAlpha($ndoe as node(), $mode as map(*)) {
        let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson/tei:person
        let $letters := for $person in  $lists/tei:persName order by $person return fn:substring($person,1,1)
        let $letters := distinct-values($letters)
        
        return map {
        "letters" := $letters
        
        }
        
};

declare function index:printLetter($node as node(), $model as map(*)) {
    let $letter := $model("letter")
    return <h2 id="{$letter}">{$letter}</h2>
};

declare function index:printNavigation($node as node(), $model as map(*)) {
<div class="navigation">{for $letter in $model("letters") return ( <a href="#{$letter}">{$letter}</a>,<span>|</span>)}</div>

};