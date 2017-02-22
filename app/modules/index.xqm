
module namespace index="http://localhost:8080/exist/apps/pessoa/index";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace obras="http://localhost:8080/exist/apps/pessoa/obras" at "obras.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";

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

declare function index:printDocLinks($node as node(), $model as map(*),$ref) {
    let $doc := $model($ref)
    let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/doc/",$doc/@link/data(.))
    return <span><a href="{$ref}" class="olink">{$doc/@title/data(.)}</a>{if($doc/@coma/data(.) eq "yes") then "," else ()}</span>
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
                                                            else "CP"
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
                                            {replace($item/@title/data(.),"/E3","")}
                                        </a>
                                        </div>
                                )
                            }       
                         </div>                         
    return ($navigation,$list)
  
};


(:####### TEXT INDEX #######:)

declare function index:collectTexts($node as node(), $model as map(*)) {
    let $texts := for $text in  search:search_range_simple("type","title",collection('/db/apps/pessoa/data/doc'))
                                for $single in $text//tei:rs[@type = "title"][not(child::tei:choice/tei:abbr)][not(child::tei:pc)]
                                order by $single
                            return $single
                            (:<item title="{$single}" well="{replace(replace(replace($single,'"',''),'“',''),'”','')}"/>:)
                            
   let $docs := for $doc in $texts
                            return <item name="{$doc}"  ref="{substring-before(root($doc)/util:document-name(.),".xml")}" 
                                                    title="{replace(doc(concat('/db/apps/pessoa/data/doc/',root($doc)/util:document-name(.)))//tei:title[1]/data(.),"/E3","")}"
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
    (:let $well := for $a in (1 to count($well)) 
                                let $coma := if($a != count($well)) then "yes" else "no" 
                                return <item 
                                ref="{$well/@ref/data(.)}"
                                title="{$well[$a]/@title/data(.)}" 
                                well="{$well[$a]/@well/data(.)}" 
                                type="{$well[$a]/@type/data(.)}" 
                                letter="{$well[$a]/@letter/data(.)}" 
                                coma="{$coma}"/>:)
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
             let $docs := for $doc in $aDocs where $doc/@name eq $text/@title  return <item link="{$doc/@ref/data(.)}" title="{$doc/@title/data(.)}"/>
             let $docs := for $a in (1 to count($docs)) let $coma := if($a != count($docs)) then "yes" else "no" return <item link="{$docs[$a]/@link/data(.)}" title="{$docs[$a]/@title/data(.)}" coma="{$coma}"/>
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
                            order by $hit/tei:persName[1]
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
    let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson[2]
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
                                for $doc in search:searchRange_ex_two($coll,"person","style",$id,$db/@style) where $doc//tei:rs[@type = "name" and  @key = $id and @style=$db/@style] return $doc
                                else
                                for $doc in search:search_range_simple("person",$id,$coll) where $doc//tei:rs[@type = "name" and  @key = $id] return $doc
    
    let $res := for $doc in $docs
                                let $cota := ($doc//tei:title)[1]/data(.)
                                let $link := substring-before(root($doc)/util:document-name(.),".xml")
                          (:     let $cota2 := if(contains($cota,"-")) then replace(substring-before($cota,"-"), "(BNP/E3|CP)\s?([0-9]+)([^0-9]+.*)?", "$2")
                                                        else replace($cota, "(BNP/E3|CP)\s?([0-9]+)([^0-9]+.*)?", "$2")
                                      :)            
                                      let $label := replace($link,("BNP_E3_|CP"),"")
                                    let $front := if(contains($label,"-")) then substring-before($label,"-") else $label
                                order by $front, xs:integer(replace($label, "^\d+[A-Z]?\d?-?([0-9]+).*$", "$1"))
                                return <item link="{$link}" title="{replace($cota,"/E3","")}"/>
                                
                                
   let $ref_amount := count($res)
    let $ADocs := for $ref in (1 to $ref_amount -1) return <item link="{$res[$ref]/@link}" title="{$res[$ref]/@title}" coma="yes"/>     
    let $BDocs := if($ref_amount != 0) then <item link="{$res[$ref_amount]/@link}" title="{$res[$ref_amount]/@title}" coma="no"/> else ()(:$res[$ref_amount] :)                            
    
    return map {
       "docs" := ($ADocs,$BDocs),
        "name" := $name,
        "id" := $id
    }
};

declare function index:printAuthor($node as node(), $model as map(*)) {
    <span id="{$model("id")}">{$model("name")}</span>
};

declare function index:plottAlpha($ndoe as node(), $mode as map(*)) {
        let $lists := doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson[2]/tei:person
        let $letters := for $person in  $lists/tei:persName order by $person return fn:substring($person,1,1)
        let $letters := distinct-values($letters)
        return map {
            "letters" := $letters
        }
};

(:#### Periodicals / Journals #### :)

declare function index:collectJournals($node as node(), $model as map(*)) {
    let $journals := for $journal in  doc('/db/apps/pessoa/data/lists.xml')//tei:list[@type = "periodical"]/tei:item
                                let $key := $journal/@xml:id/data(.)
                                order by $journal/data(.)                                
                                return <item key="{$key}" name="{$journal/data(.)}" letter="{substring($journal/data(.),1,1)}">
                                                {for $item in index:FindJournalsEntrys($key)
                                                    order by $item/@date/data(.)
                                                    return $item
                                                }
                                            </item>
    
    let $nav := for $item in $journals return $item/@letter/data(.)
    let $nav := distinct-values($nav)
    return map {
        "journals" := $journals,
        "letters" := $nav
    }
};

declare function index:FindJournalsEntrys($key as xs:string) {
    ( for $item in search:search_range_simple("person",$key,collection("/db/apps/pessoa/data/doc/"))
                        return <item title="{replace($item//tei:titleStmt/tei:title[1]/data(.),"/E3","")}" 
                                               date="{search:dateDoc($item)}" 
                                               ref="{concat("doc/",substring-before($item//tei:idno[@type="filename"]/data(.),".xml"))}"/>
      ,
     for $item in search:search_range_simple("journal",$key,collection("/db/apps/pessoa/data/pub/"))
                        return <item title="{$item//tei:titleStmt/tei:title[1]/data(.)}"
                                                date="{search:datePub($item)}"
                                                ref="{concat("pub/",substring-before($item//tei:idno[@type="filename"]/data(.),".xml"))}"/>
   )
};

declare function index:mapJournals($node as node(), $model as map(*)) {
    let $letter := $model("letter")
    let $journal := $model("journals")[@letter =$letter]    
    return map {
        "journal" := $journal
    }
};

declare function index:mapSingleJournal($node as node(), $model as map(*)) {
    let $mentoined := $model("single")/item
    let $mentoined := for $a in (1 to count($mentoined))
                                    let $coma := if($a != count($mentoined)) then "yes" else "no"
                                    return <item title="{$mentoined[$a]/@title/data(.)}" date="{$mentoined[$a]/@date/data(.)}" ref="{$mentoined[$a]/@ref/data(.)}" coma="{$coma}"/>
   return map {
   "journal" := $model("single"),
    "mentioned" := $mentoined
   }
};


declare function index:printJournal($node as node(), $model as map(*)) {
$model("journal")/@name/data(.)
};

declare function index:printJournalLinks($node as node(), $model as map(*),$ref) {
    let $doc := $model($ref)
    let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/",$doc/@ref/data(.))
    return <span><a href="{$ref}" class="olink">{$doc/@title/data(.)}</a>{if($doc/@coma/data(.) eq "yes") then "," else ()}</span>
};
