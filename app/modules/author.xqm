xquery version "3.0";

module namespace author="http://localhost:8080/exist/apps/pessoa/author";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";

declare function author:getTitle($node as node(), $model as map(*), $author){
    if($author = "pessoa") then
        <h1>Fernando Pessoa</h1>
    else if($author="reis") then
        <h1>Ricardo Reis</h1>
    else if($author="caeiro") then
        <h1>Alberto Caeiro</h1>
    else if($author="campos") then
        <h1>Álvaro de Campos</h1>
    else ()
        };

declare function author:reorder($node as node(), $model as map(*),$orderBy, $textType, $author){
    author:getTabContent($node,$model,$textType,$author, $orderBy)
};

declare function author:getTabs($node as node(), $model as map(*), $textType as xs:string?, $author as xs:string?){
    let $lists := doc('/db/apps/pessoa/data/lists.xml')
    return
    if ($textType = "all") then
        <ul id="tabs"><li class="selected"><a href="{$helpers:app-root}/author/{$author}/all">{page:singleAttribute($lists,"author-pages", "publications-and-documents")}</a></li>
        <li><a href="{$helpers:app-root}/author/{$author}/documents">{page:singleAttribute($lists, "author-pages","documents")}</a></li>
        <li><a href="{$helpers:app-root}/author/{$author}/publications">{page:singleAttribute($lists, "author-pages","publications")}</a></li></ul>                
    else if($textType = "documents") then 
        <ul id="tabs"><li><a href="{$helpers:app-root}/author/{$author}/all">{page:singleAttribute($lists, "author-pages","publications-and-documents")}</a></li>
        <li class="selected"><a href="{$helpers:app-root}/author/{$author}/documents">{page:singleAttribute($lists, "author-pages","documents")}</a></li>
        <li><a href="{$helpers:app-root}/author/{$author}/publications">{page:singleAttribute($lists, "author-pages","publications")}</a></li></ul> 
    else if($textType ="publications") then
        <ul id="tabs"><li><a href="{$helpers:app-root}/author/{$author}/all">{page:singleAttribute($lists, "author-pages","publications-and-documents")}</a></li>
        <li><a href="{$helpers:app-root}/author/{$author}/documents">{page:singleAttribute($lists, "author-pages","documents")}</a></li>
        <li class ="selected"><a href="{$helpers:app-root}/author/{$author}/publications">{page:singleAttribute($lists, "author-pages","publications")}</a></li></ul>         
    else()                   
};


declare function author:getTabContent($node as node(), $model as map(*), $textType, $author, $orderBy) {
    let $authorKey := if($author = "pessoa") then "FP" else if($author ="reis") then "RR" else if($author ="caeiro") then "AC" else if($author="campos") then "AdC" else ()
    let $folders :=  switch($textType) 
                            case "all" return ("doc","pub")
                            case "documents" return "doc"
                            case "publications" return "pub"
                            default return ()
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
                                                              {if($item/@folder/data(.) eq "doc") then <i>{concat(" (",page:singleElement_xquery("roles","mentioned-as"),":",page:singleElement_xquery("roles","author"),")")}</i> else ()}
                                                                
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

declare function author:getRoles($doc, $authorKey){
    let $roles := $doc//tei:text//tei:rs[@type = 'name' and @key=$authorKey]/@role/data(.)
    let $uniqueRoles := fn:distinct-values($roles)
    return
    $uniqueRoles
};

declare function author:getYearOrTitle($text, $orderBy){
    let $pub := author:getYearOrTitleOfPublication($text,$orderBy)
    let $doc := author:getYearOrTitleOfDocument($text, $orderBy)
    return if($pub) then $pub
    else if($doc) then $doc
    else ()
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
        $("#tab").load("{$helpers:app-root}/{$helpers:web-language}/page/author/{$author}/{$textType}?orderBy=date");
        
        }}
        else{{
        $("#tab").load("{$helpers:app-root}/{$helpers:web-language}/page/author/{$author}/{$textType}?orderBy=alphab"); 
        }}
        }}
    </script> 
    return $script
};

(:
var author = ""
        var textType = ""
        var url = window.location.href;
        var i = url.lastIndexOf("/");
        var substr = url.substring(0,i);
        i = substr.lastIndexOf("/");
        var author = substr.substring(i+1,substr.length);
        var textType = url.substring(url.lastIndexOf("/")+1,url.length);
        
:)