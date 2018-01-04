xquery version "3.0";
(:~
: Modul zur Anzeige der Authoren
: @author Ben Bigalke
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
: Funktion zur erstellung der Liste welche dem Nutzer angezeigt wird.
: Fragt den textTypen ab, welcher Aussagt ob die Resourcen entweder Dokumente oder Publikationen sind, bzw. ob alle Resourcen durchsucht werden sollen
:
: @param $textType Auswählter textType (all,doc,pub)
: @param $author Name des Authoren
: @param $orderBy Sortierungs form chronolgisch | alphabetisch
: @return Wellformed HTML Content
:)
declare function author:getTabContent($node as node(), $model as map(*), $textType, $author, $orderBy) {
    let $authorKey := author:getAuthorId($author)
    let $folders := if($textType eq "all") then ("doc","pub") else $textType
    let $items := for $fold in $folders                              
                                let $name := if($fold eq "doc") then ("person","role") else "person"
                                let $case := if($fold eq "doc") then ("eq","eq") else "eq"
                                let $content := if($fold eq "doc") then ($authorKey,"author") else $authorKey
                                let $db := search:Search-MultiStats(collection(concat("/db/apps/pessoa/data/",$fold,"/")),$name,$case,$content)
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
                                      return <item folder="{$fold}" doc="{$refer}"  title="{replace($doc//tei:titleStmt/tei:title/data(.),"/E3","")}" crit="{$crit}"/>   
                    let $criteria := for $item in $items return $item/@crit/data(.)                           
                     let $criteria := distinct-values($criteria)
                     
                     let $navigation :=   <div class="navigation"> 
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
                                                        return <div class="doctabelcontent">
                                                             <a href="{$helpers:app-root}/{$item/@folder/data(.)}/{$item/@doc/data(.)}">
                                                                 {$item/@title/data(.)}
                                                             </a> 
                                                              {if($item/@folder/data(.) eq "doc") then <i>{concat(" (",helpers:singleElementInList_xQuery("roles","mentioned-as"),":",helpers:singleElementInList_xQuery("roles","author"),")")}</i> else ()}
                                                                
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