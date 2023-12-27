xquery version "3.1";
module namespace index="http://localhost:8080/exist/apps/pessoa/index";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";


(:######### MODULAR #######:)

declare function index:printLetter($node as node(), $model as map(*)) {
    let $letter := $model("letter")
    return <h2 id="{$letter}">{$letter}</h2>
};

declare function index:printNavigation($node as node(), $model as map(*)) {
<div class="navigation">
{for $letter in $model("letters")
let $letters := $model("letters")return ( <a href="#{$letter}">{$letter}</a>,if( index-of($letters,$letter) != count($letters) ) then <span>|</span> else ())}</div>

};

declare function index:printDocLinks($node as node(), $model as map(*),$ref) {
    let $doc := $model($ref)
    let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/",$doc/@link/data(.))
    return <span>
        {if($doc/@published/data(.) eq "free") then
            <a href="{$ref}" class="olink">{$doc/@title/data(.)}</a>
        else <span class="link-res">{$doc/@title/data(.)}</span>}
        {if($doc/@coma/data(.) eq "yes") then "," else ()}</span>
};

(:### Genre Index ####:)

declare function index:collectGenre($node as node(), $model as map(*), $type as xs:string, $orderBy as xs:string) {
    (: retrieve the genre key from lists.xml :)
    let $type := $helpers:lists//tei:list[@type='genres']/tei:item[@xml:id=$type]/tei:note[@type='range']/data(.)
    (: get the items for that genre :)
    let $items := for $fold in ("doc","pub")
                    let $para := if ($fold = "doc") then "doc_genre" else "pub_genre"
                    let $db := search:search_range_simple($para,$type,collection(concat("/db/apps/pessoa/data/",$fold,"/")))
                    for $doc in $db
                        (: get the title :)
                        let $title := $doc//tei:titleStmt/tei:title/data(.)
                        (: get the link to the item :)
                        let $refer := substring-before(root($doc)/util:document-name(.),".xml")
                        (: what should it be ordered by alphabetically? (first letter, etc.) :)
                        let $first := if ($fold = "doc")
                                      then if(substring($doc//tei:titleStmt/tei:title/data(.),1,1) eq "B") then "BNP" else "CP"
                                      else translate(substring($doc//tei:titleStmt/tei:title/data(.),1,1),"Á&quot;","AA")
                        return
                            (: return one item per resource for alphabetical order :)
                            if ($orderBy = "alphab")
                            then <item folder="{$fold}" doc="{$refer}" title="{$title}" crit="{$first}"/>
                            (: return one item per document one possibly several per publication for chronological order :)
                            else
                                if ($fold="doc")
                                then 
                                    (: get the date for documents :)
                                    let $date := if(exists($doc//tei:origDate/@when)) 
                                               then $doc//tei:origDate/@when/data(.)
                                               else if(exists($doc//tei:origDate/@notBefore)) then $doc//tei:origDate/@notBefore/data(.)
                                               else if(exists($doc//tei:origDate/@from)) then $doc//tei:origDate/@from/data(.)
                                               else "?"
                                    (: get the year of the date :)
                                    let $date := if($date eq "?") 
                                                 then "?"  
                                                 else (if(contains($date,"-")) then substring-before($date,"-") else $date)
                                    return <item folder="{$fold}" doc="{$refer}" title="{$title}" crit="{$date}"/>
                           (: for publications: return one item per journal publication :)
                                else
                                    for $pubdate in $doc//tei:imprint/tei:date
                                    (: get the date for the journal publication :)
                                    let $date := if(exists($pubdate/@when)) then $pubdate/@when/data(.)
                                                else if(exists($pubdate/@notBefore)) then $pubdate/@notBefore/data(.)
                                                else if(exists($pubdate/@from)) then $pubdate/@from/data(.)
                                                else "?"
                                    (: get the year of the date :)
                                    let $date := if($date eq "?") 
                                                then "?"  
                                                else (if(contains($date,"-")) then substring-before($date,"-") else $date)
                                    let $title := if (count($doc//tei:imprint/tei:date) > 1) 
                                                  then $pubdate/ancestor::tei:biblStruct//tei:title[@level="a"]/data(.)
                                                  else $title
                                    return <item folder="{$fold}" doc="{$refer}" title="{$title}" crit="{$date}"/>  
     (: order all the items :)
     let $items := for $it in $items
                   let $crit := $it/@crit
                   let $title := $it/@title
                   order by $crit, $title
                   return $it 
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
declare function index:collectTitleLetters($node as node(), $model as map(*)) {
    (: get the first letters of all the titles in alphabetical order :)
    let $letters := doc("/db/apps/pessoa/data/titles-raw-sorted.xml")//letter
    let $letters := for $l in distinct-values($letters)
                    order by $l
                    return $l
    return map {
        "letters" : $letters 
   }
    
};

declare function index:collectTitles($node as node(), $model as map(*)) {
(: return the titles and the list of documents/publications they occur in 
for a specific letter :)
let $titles := doc("/db/apps/pessoa/data/titles-raw-sorted.xml")//entry
let $titles_selected := for $t in $titles
                        where $t/letter/data(.) = $model("letter")
                        return $t
return
    <div class="index-text">
    { for $t in $titles_selected
      let $title-text := $t/title/data(.)
      order by translate(lower-case($title-text),'“"(','')
      return
        <span class="index-title">{$title-text}
            <div class="docList">
                {for $hit in $t//link
                return <span><a href="{concat($helpers:app-root,"/",$helpers:web-language,"/",$hit/type,"/",$hit/parentLink/substring-before(.,'.xml'))}" class="olink">{$hit/parentName}</a>
                {if(index-of($t//link,$hit) > count($t//link)) then "," else()}
                </span>}
                <div class="clear"/>
            </div>
        </span>
    }
                                
    </div>
};

(:######## PERSON INDEX #######:)


declare function index:getPersonIndex($node as node(), $model as map(*)) {
    let $lists := doc('/db/apps/pessoa/data/indices.xml')//tei:listPerson[@type = 'all']
    let $docs:= collection("/db/apps/pessoa/data/doc/")
    let $pubs:= collection("/db/apps/pessoa/data/pub/")
    let $persons := for $person in $lists/tei:person
                        let $id := $person/attribute()/data(.)
                        let $id := if(contains($id,"#")) then substring-after($id,"#") else $id
                        let $name := $person/tei:persName[@type="main"]
                        let $viaf := $person/tei:idno[@type="viaf"][1]
                        order by $name collation '?lang=pt'
                        return <item id="{$id}" letter="{translate(substring($name,1,1),'ÁÂ','AA')}" name="{$name}">
                                    {
                                    (: get documents for the person; here only cases are retrieved, where person names
                                    are mentioned in the text of the documents :)
                                    let $name-a := ("rs_type","rs_key")
                                    let $case-a := ("eq","eq")
                                    let $content-a := ("name",$id)
                                    let $a :=
                                        for $item in search:Search_MultiStats($docs,$name-a,$case-a,$content-a)
                                        let $title := $item//tei:titleStmt/tei:title[1]/data(.)
                                        let $link := substring-before($item//tei:idno[@type="filename"]/data(.),".xml")
                                        return <item title="{$title}" link="doc/{$link}" published="{$item//tei:availability/@status/data(.)}" viaf="{$viaf}"/>
                                    (: get publications for the person; here the names can be of the authors of the publication
                                    or they can be mentioned inside of the text of the publications :)
                                    let $name-b := ("pub_author","rs_type","rs_key")
                                    let $case-b := ("eq","eq","eq")
                                    let $content-b := ($id,"name",$id)
                                    let $b :=
                                        for $item in search:Search_MultiStats($pubs,$name-b,$case-b,$content-b)
                                        let $title := $item//tei:titleStmt/tei:title[1]/data(.)
                                        let $link := substring-before($item//tei:idno[@type="filename"]/data(.),".xml")
                                        return <item title="{$title}" link="pub/{$link}" published="{$item//tei:availability/@status/data(.)}" viaf="{$viaf}"/>
                                    return
                                        for $se in $a union $b
                                        order by $se/@title/data(.) collation '?lang=pt'
                                        return $se
                                    }
                                </item>
    let $letters := for $let in $persons return $let/@letter/data(.)
    let $letters := distinct-values($letters)
    return map {
        "persons" : $persons,
        "letters" : $letters
    }
};

declare function index:getPerson($node as node(), $model as map(*)) {
    let $letter := $model("letter")
    let $persons := $model("persons")
    let $persons := for $pers in $persons where $pers/@letter/data(.) eq $letter return $pers

    return map {
    "sort" : $persons
    }

};

declare function index:createPerson($node as node(), $model as map(*)) {
    let $pers := $model("pers")
    let $docs := $pers/item
    let $docs := for $doc in $docs
            let $coma := if(helpers:index-of-node($docs,$doc) != count($docs)) then "yes" else "no"
            return <item title="{$doc/@title/data(.)}" link="{$doc/@link/data(.)}" coma="{$coma}" published="{$doc/@published/data(.)}"/>
    return
        map {
        "name" : $pers/@name/data(.),
        "id" : $pers/@id/data(.),
        "docs" : $docs
        }
};

declare function index:printAuthor($node as node(), $model as map(*)) {
    <span id="{$model("id")}">{$model("name")}</span>
};
(:#### Periodicals / Journals #### :)

declare function index:collectJournals($node as node(), $model as map(*)) {
    let $journals := for $journal in  doc('/db/apps/pessoa/data/indices.xml')//tei:list[@type = "periodical"]/tei:item
                                let $key := $journal/@xml:id/data(.)
                                order by $journal/data(.)                                
                                return <item key="{$key}" name="{$journal/title/data(.)}" letter="{substring($journal/title/data(.),1,1)}">
                                                {for $item in index:FindJournalsEntrys($key)
                                                    order by $item/@date/data(.)
                                                    return $item
                                                }
                                            </item>
    
    let $nav := for $item in $journals return $item/@letter/data(.)
    let $nav := distinct-values($nav)
    return map {
        "journals" : $journals,
        "letters" : $nav
    }
};

declare function index:FindJournalsEntrys($key as xs:string) {
    ( (: journals mentioned in documents :)
      for $item in search:search_range_simple("rs_key",$key,collection("/db/apps/pessoa/data/doc/"))
                        return <item title="{replace($item//tei:titleStmt/tei:title[1]/data(.),"/E3","")}" 
                                               date="{search:dateDoc($item)}" 
                                               ref="{concat("doc/",substring-before($item//tei:idno[@type="filename"]/data(.),".xml"))}"
                                                published="{$item//tei:availability/@status/data(.)}"/>
      ,
      (: journals mentioned in publications or in which publications appeared :)
      for $item in search:search_range_simple("rs_key",$key,collection("/db/apps/pessoa/data/pub/"))
                        return <item title="{$item//tei:titleStmt/tei:title[1]/data(.)}" 
                                               date="{search:datePub($item)}" 
                                               ref="{concat("pub/",substring-before($item//tei:idno[@type="filename"]/data(.),".xml"))}"
                                                published="{$item//tei:availability/@status/data(.)}"/>
   )
};

declare function index:mapJournals($node as node(), $model as map(*)) {
    let $letter := $model("letter")
    let $journal := $model("journals")[@letter =$letter]    
    return map {
        "journal" : $journal
    }
};

declare function index:mapSingleJournal($node as node(), $model as map(*)) {
    let $mentoined := $model("single")/item
    let $mentoined := for $a in (1 to count($mentoined))
                                    let $coma := if($a != count($mentoined)) then "yes" else "no"
                                    return <item title="{$mentoined[$a]/@title/data(.)}" date="{$mentoined[$a]/@date/data(.)}" ref="{$mentoined[$a]/@ref/data(.)}" coma="{$coma}" published="{$mentoined[$a]/@published/data(.)}"/>
   return map {
   "journal" : $model("single"),
    "mentioned" : $mentoined
   }
};


declare function index:printJournal($node as node(), $model as map(*)) {
$model("journal")/@name/data(.)
};

declare function index:printJournalLinks($node as node(), $model as map(*),$ref) {
    let $doc := $model($ref)
    let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/",$doc/@ref/data(.))
    return <span>{if($doc/@published/data(.) eq "free") then
        <a href="{$ref}" class="olink">{$doc/@title/data(.)}</a>
    else <span class="link-res">{$doc/@title/data(.)}</span>
    }
        {if($doc/@coma/data(.) eq "yes") then "," else ()}</span>
};
