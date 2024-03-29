xquery version "3.1";
(:~
: Module to display author-related information
: @author Ben Bigalke, Ulrike Henny-Krahmer
: @version 1.0
:)
module namespace author="http://localhost:8080/exist/apps/pessoa/author";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";


declare function author:getAuthorId($author as xs:string) {
    for $at in $helpers:lists//tei:listPerson[@type='authors']/tei:person
            where $at/tei:note[@type='link'] eq $author
            return $at/@xml:id/data(.)
};

declare function author:getTitle($node as node(), $model as map(*), $author){
    <h1>{$helpers:lists//tei:listPerson[@type='authors']/tei:person[@xml:id=author:getAuthorId($author)]/tei:persName/data(.)}</h1>
        };

declare function author:reorder($node as node(), $model as map(*),$orderBy, $textType, $author){
    author:getTabContent($node,$model,$textType,$author, $orderBy)
};

declare function author:getTabs($node as node(), $model as map(*), $textType as xs:string?, $author as xs:string?){
    let $url := concat($helpers:app-root,'/',$helpers:web-language,'/authors/',$author)
    return <ul id="tabs">
        {for $type in ('all','documents','publications')
            let $t := if($type eq "all") then "publications-and-documents" else $type
            let $a := <a href='{$url}/{substring($type,1,3)}'>{helpers:singleElementInList_xQuery('author-pages',$t)}</a>
            return if($type eq $textType) then
                    <li class='selected'>
                        {$a}
                    </li>
                else  <li>
                        {$a}
                    </li>
        }
    </ul>
};

(:~
: Function to generate the list of documents / publications by author shown to the user
: Checks if the resource is a document or publication or if all types of resources should be searched
:
: @param $textType chosen type of resource (all,doc,pub)
: @param $author name of the author
: @param $orderBy order chronologically or alphabetically
: @return wellformed HTML content
:)
declare function author:getTabContent($node as node(), $model as map(*), $textType, $author, $orderBy) {
    let $authorKey := author:getAuthorId($author)
    let $folders := if($textType eq "all") then ("doc","pub") else $textType
    let $items := for $fold in $folders                              
                    let $db_author := if ($fold eq "pub") 
                                    then search:search_range_simple("pub_author", $authorKey, collection(concat("/db/apps/pessoa/data/",$fold,"/")))
                                    else ()
                    let $db_rs := search:search_range_simple("rs_key", $authorKey, collection(concat("/db/apps/pessoa/data/",$fold,"/")))
                    for $doc in $db_author union $db_rs
                        let $refer := substring-before(root($doc)/util:document-name(.),".xml") 
                        let $first := translate(substring($doc//tei:titleStmt/tei:title/data(.),1,1),"Á","A")
                        let $title := replace($doc//tei:titleStmt/tei:title/data(.),"/E3","")
                        return
                            (: return one item per resource for alphabetical order :)
                            if ($orderBy = "alphab")
                            then <item folder="{$fold}" doc="{$refer}"  title="{$title}" crit="{$first}"/>
                            (: return one item per document one possibly several per publication for chronological order :)
                            else
                                (: for "doc" there is just one date :)
                                (: for "doc" only mentioned names are relevant :)
                                if ($fold = "doc")
                                then let $date := if(exists($doc//tei:origDate/@when)) then $doc//tei:origDate/@when/data(.)
                                                  else if(exists($doc//tei:origDate/@notBefore)) then $doc//tei:origDate/@notBefore/data(.)
                                                  else if(exists($doc//tei:origDate/@from)) then $doc//tei:origDate/@from/data(.)
                                                  else "?"
                                     let $date := if($date eq "?") then "?"  
                                                  else (if(contains($date,"-")) then substring-before($date,"-") else $date)
                                     let $mentions := distinct-values($doc//tei:body//tei:rs[@type='name'][@key=$authorKey]/@role)
                                     return <item folder="{$fold}" doc="{$refer}"  title="{$title}" crit="{$date}" mentions="{$mentions}"/>
                                (: for publications: return one item per journal publication :)
                                else for $pubdate in $doc//tei:imprint/tei:date
                                    let $date := if(exists($pubdate/@when)) then $pubdate/@when/data(.)
                                                 else if(exists($pubdate/@notBefore)) then $pubdate/@notBefore/data(.)
                                                 else if(exists($pubdate/@from)) then $pubdate/@from/data(.)
                                                 else "?"
                                    let $date := if($date eq "?") then "?"  
                                                 else (if(contains($date,"-")) then substring-before($date,"-") else $date)
                                    let $title := $pubdate/ancestor::tei:biblStruct//tei:title[@level=("a","m")]/data(.)
                                    let $mentions := distinct-values($doc//tei:body//tei:rs[@type='name'][@key=$authorKey]/@role)
                                    let $isAuthor := if ($doc//tei:titleStmt/tei:author/tei:rs[@key=$authorKey]) then "yes" else "no"
                                    return <item folder="{$fold}" doc="{$refer}"  title="{$title}" crit="{$date}" isAuthor="{$isAuthor}" mentions="{$mentions}"/>
        
    (: order all the items :)
    let $items := for $it in $items
                  let $crit := $it/@crit
                  let $title := $it/@title
                  order by $crit, $title
                  return $it                                   
    let $criteria := for $item in $items return $item/@crit/data(.)                           
    let $criteria := distinct-values($criteria)
     
    let $navigation := <div class="navigation"> 
                         {for $crit at $i in $criteria
                             return if ($i = count($criteria)) then
                                 <a href="#{$crit}" class="authorlink">{$crit}</a>
                                 else
                                 (<a href="#{$crit}" class="authorlink">{$crit}</a>,<span>|</span>)
                         }  
                         <br/>
                         <br/>
                     </div>                         
    let $list :=   <div>
                    {for $crit in $criteria 
                        return (<div class="sub_Nav"><h2 id="{$crit}">{$crit}</h2></div>,
                                for $item in $items where $item/@crit eq $crit
                                let $author := if ($item/@isAuthor = "yes") then helpers:singleElementInList_xQuery("roles","author") else ()
                                let $roles := if ($item/@mentions != "")
                                              then concat(
                                                helpers:singleElementInList_xQuery("roles","mentioned-as"), ": ",
                                                string-join(for $m in tokenize($item/@mentions,'\s')
                                                            return helpers:singleElementInList_xQuery("roles",$m),", ")
                                                )
                                              else ()
                                let $roles_joined := string-join(($author, $roles), ", ")
                                order by $item/@title/data(.)
                                return <div class="doctabelcontent">
                                     <a href="{$helpers:app-root}/{$item/@folder/data(.)}/{$item/@doc/data(.)}">
                                         {$item/@title/data(.)}
                                     </a> <br/>
                                     <i>({$roles_joined})</i>
                               </div>
                        )
                    }       
                 </div>                         
    return ($navigation,$list)
};


declare function author:formatDocID($id){
   let $id := $id
   return
   if(fn:contains($id,"BNP_E3_")) then
        let $numPart := fn:substring-after($id,"BNP_E3_")
        let $numPart := fn:tokenize($numPart,'[A-Z,a-z,-]')[1]
        let $length := fn:string-length($numPart)
        let $diff := 4-$length
        let $newNumber := fn:concat(fn:substring("0000",0,$diff),$numPart)
        return fn:concat("BNP_E3_",$newNumber, fn:substring-after($id,$numPart))
    else if(fn:starts-with($id,"CP")) then
        let $numPart := if (fn:contains($id,"-")) then fn:substring-after(fn:substring-before($id,"-"),"CP") else fn:substring-after(fn:substring-before($id,".xml"),"CP")
        let $length := fn:string-length($numPart)
        let $diff := 4-$length
        let $newNumber := fn:concat(fn:substring("0000",0,$diff),$numPart)
        return fn:concat("CP",$newNumber, fn:substring-after($id,$numPart))
    else $id 
};

declare function author:getYearOrTitleOfDocument($doc, $orderBy){
    let $when := $doc//tei:origDate/@when/data(.)
    let $from := $doc//tei:origDate/@from/data(.)
    let $notBefore := $doc//tei:origDate/@notBefore/data(.)
    let $notAfter := $doc//tei:origDate/@notAfter/data(.)
    let $signature :=  author:formatDocID(($doc//tei:idno)[1]/data(.))
    return 
    if($orderBy = "date") then
        if($when) then $when
        else if($from) then $from
        else if($notBefore) then $notBefore
        else if($notAfter) then $notAfter
        else ()
        else if($orderBy = "alphab") then $signature
    else() 
};
declare function author:getYearOrTitleOfPublication($pub, $orderBy){
    let $when := ($pub//tei:date)[1]/@when/data(.)
    let $from := ($pub//tei:date)[1]/@from/data(.)
    let $notBefore := ($pub//tei:date)[1]/@notBefore/data(.)
    let $notAfter := ($pub//tei:date)[1]/@notAfter/data(.)
    let $title :=  $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/(tei:title)[not(@*)]
    return
    if($orderBy="date") then
        if($when) then $when
            else if($from) then $from
            else if($notBefore) then $notBefore
            else if($notAfter) then $notAfter
            else ()
        else if($orderBy ="alphab") then
      $title[1]/data(.)
    else()  
};

declare function author:getrecorder($node as node(), $model as map(*),$author,$textType){
let $script := 
<script type="text/javascript">        
        function reorder(){{
        
        if ($("#date").is(":checked"))
        {{
        $("#tab").load("{$helpers:app-root}/{$helpers:web-language}/authors/{$author}/{$textType}?orderBy=date");
        
        }}
        else{{
        $("#tab").load("{$helpers:app-root}/{$helpers:web-language}/authors/{$author}/{$textType}?orderBy=alphab");
        }}
        }}
    </script> 
    return $script
};