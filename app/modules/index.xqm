
module namespace index="http://localhost:8080/exist/apps/pessoa/index";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace obras="http://localhost:8080/exist/apps/pessoa/obras" at "obras.xqm";

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


declare function index:FindFirstLetter($text as xs:string,$pos as xs:integer) {
    for $a in (helpers:lettersOfTheAlphabet(),helpers:lettersOfTheAlphabeHight())
      let $pos :=  if($a eq "Z") then $pos +1
        else $pos
        let $look := substring($text,$pos,1)
        where $look eq $a
        return $look
};



(:### Genre Index ####:)

declare function index:collectGenre($node as node(), $model as map(*),$type as xs:string,$orderBy as xs:string) {
    let $items := for $fold in ("doc","pub")                                 
                                let $db := search:search_range_simple("genre",$type,collection(concat("/db/apps/pessoa/data/",$fold,"/")))
                                 for $doc in $db 
                                        let $date := if($fold ="doc") then (
                                                                if(exists($doc//tei:origDate/@when)) then $doc//tei:origDate/@when/data(.)
                                                                else if(exists($doc//tei:origDate/@notBefore)) then $doc//tei:origDate/@notBefore/data(.)
                                                                else if(exists($doc//tei:origDate/@from)) then $doc//tei:origDate/@from/data(.)
                                                                else "?"
                                                                )
                                                            else (
                                                                if(exists($doc//tei:imprint/tei:date/@when)) then $doc//tei:imprint/tei:date/@when/data(.)
                                                                else if(exists($doc//tei:imprint/tei:date/@notBefore)) then $doc//tei:imprint/tei:date/@notBefore/data(.)
                                                                else if(exists($doc//tei:imprint/tei:date/@from)) then $doc//tei:imprint/tei:date/@from/data(.)
                                                                else "?"
                                                            )
                                        let $date :=    if($date eq "?") then "?"  
                                                                else ( if(contains($date,"-")) then substring-before($date,"-") else $date )                                                   
                                        let $refer := substring-before(root($doc)/util:document-name(.),".xml") 
                                        let $first := if($fold eq "doc") then (
                                                            if(substring($doc//tei:titleStmt/tei:title/data(.),1,1) eq "B") then "BNP"
                                                            else "MN"
                                                            )
                                                            else substring($doc//tei:titleStmt/tei:title/data(.),1,1)                     
                                       let $crit := if ($orderBy = "alphab") then $first else $date
                                      order by $crit
                                      return <item folder="{$fold}" doc="{$refer}"  title="{$doc//tei:titleStmt/tei:title/data(.)}" crit="{$crit}"/>   
     let $criteria := for $item in $items return $item/@crit/data(.)                           
     let $criteria := distinct-values($criteria)
     
     let $navigation :=   <div class="navigation"> 
                                             {for $crit at $i in $criteria
                                                 return if ($i = count($criteria)) then
                                                     <a href="#{$crit}">{$crit}</a>
                                                     else
                                                     (<a href="#{$crit}">{$crit}</a>,<span>|</span>)
                                             }  
                                             <br/>
                                             <br/>
                                         </div>                         
     let $list :=   <div>
                            {for $crit in $criteria 
                                return (<div class="sub_Nav"><h2 id="{$crit}">{$crit}</h2></div>,
                                        for $item in $items where $item/@crit eq $crit
                                        return <div class="doctabelcontent">
                                        <a href="{$helpers:app-root}/{$item/@folder/data(.)}/{$item/@doc/data(.)}">
                                            {$item/@title/data(.)}
                                        </a>
                                        </div>
                                )
                            }       
                         </div>                         
    return ($navigation,$list)
    
    (:
    map {
    "db" := $sort,
    "criteria" := $criteria,
    "temp" := <h3>Test</h3>
    }
    :)
};


(:####### TEXT INDEX #######:)

declare function index:collectTexts($node as node(), $model as map(*)) {
    let $texts := for $text in  search:search_range_simple("type","text",collection('/db/apps/pessoa/data/doc'))
                                for $single in $text//tei:rs[@type = "text"][not(child::tei:choice/tei:abbr)][not(child::tei:pc)]
                                order by $single
                            return $single
                            (:<item title="{$single}" well="{replace(replace(replace($single,'"',''),'“',''),'”','')}"/>:)
                            
   let $docs := for $doc in $texts
                            return <item name="{$doc}"  ref="{substring-before(root($doc)/util:document-name(.),".xml")}" 
                           />
    
    let $pubs := collection('/db/apps/pessoa/data/pub')
    let $pubs_title := for $hit in $pubs//tei:teiHeader/tei:fileDesc
                                    return <item ref="{substring-before($hit//tei:publicationStmt/tei:idno[@type="filename"]/data(.),".xml")}" 
                                    well="{$hit//tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title[@level = "a"]/data(.)}" type="pub"
                                    letter="{index:FindFirstLetter($hit//tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title[@level = "a"]/data(.),1)}"/>
    (:let $pubs_letters := for $letter in $pubs_title return substring($letter,1,1)
    :)
    let $names := distinct-values($texts)
    let $well := for $name in $names
                  (:  let $wellformed := if(  for $let in (a to z) 
                                                           where substring($name,1,1) eq $let 
                                                           return xs:boolean
                    
                    ) then substring($name,2) else $name :)
                    return <item title="{$name}" well="{replace(replace(replace($name,'"',''),'“',''),'”','')}" type="doc"  letter="{index:FindFirstLetter($name,1)}"/>
    
    let $newletter := for $letter in $well/@well order by $letter return index:FindFirstLetter($letter,1)
    let $well := ($well, $pubs_title)
    (:<item name="{$single}"  ref="{substring-before(root($text)/util:document-name(.),".xml")}"/>:)
    let $letters := for $letter in $well/@letter order by $letter return $letter
    let $letters := distinct-values($letters)
    return map {
        "texts" := $well,
        "allDocs" := $docs,
        "letters" := $letters,
        "newletter" := $newletter        
        }

};


declare function index:scanTexts($node as node(), $model as map(*)) {
    let $texts := for $text in $model("texts") where $text/@letter eq $model("letter") return $text 
    (:substring($text/@well,1,1):)
    return map {
        "scTexts" := $texts
        }
    
};

declare function index:scanDocs($node as node(), $model as map) {
    if($model("text")/@type/data(.) eq "doc") then
             let $text := $model("text")
             let $aDocs := $model("allDocs")
             let $docs := for $doc in $aDocs where $doc/@name eq $text/@title  return $doc/@ref/data(.)
             return map {"refs" := $docs}
        else ()
};
(:
replace(replace(replace($single,' " ','' ),' “ ',' ' ),' ” ','')

replace(replace(replace(replace($text," ",''),'"',''),'(',''),')','')
:)
declare function index:printDocOrPub($node as node(),$model as map(*)) {
    if($model("text")/@type/data(.) eq "doc") then $model("text")/@well/data(.)
    else <a href="{concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$model("text")/@ref/data(.))}" class="tlink">{$model("text")/@well/data(.)}</a>
    };

declare function index:printDocButton($node as node(), $model as map(*)) {
    if($model("text")/@type/data(.) eq "doc") then <div class="docListButton">{helpers:singleElement_xquery("navigation","documentos")}</div>
    else ()
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


