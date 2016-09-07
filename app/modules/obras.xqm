xquery version "3.0";

module namespace obras="http://localhost:8080/exist/apps/pessoa/obras";

import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";

declare function obras:test($node as node(), $model as map(*),$id as xs:string) {
 xmldb:decode-uri($id)
};



(: Multifunktional :)
declare function obras:buildSearch($xmlid as xs:string?, $type as xs:string) as node()* {
     if($xmlid != "") then (
     let $db := if($type = "doc") then collection( "/db/apps/pessoa/data/doc")
                           else collection( "/db/apps/pessoa/data/pub")
        let $key := if($type ="doc")  then "person" else if($type = "pub-div") then "work-index-div"  else "work-index"
        let $search_terms := if($type ="doc") then  
                                                concat('("type","person"),"work","',$xmlid,'"')
                                             else
                                                concat('("',$key,'"),"',$xmlid,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
        )
        else ()
};


declare function obras:PrintRef($node as node(), $model as map(*), $ref as xs:string) {
   if(exists($model($ref))) then (
   (:
        let $refer := (if($dir eq "pub") then substring-before(root($model($ref))/util:document-name(.),".xml")  else $model($ref))
         let $title := doc(concat("/db/apps/pessoa/data/",$dir,"/",$refer,".xml"))//tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]/data(.):)
         let $item := $model($ref)
    return (
        (<a href="{$helpers:app-root}/{$helpers:web-language}/{$item/@dir/data(.)}/{$item/@doc/data(.)}">    
        {helpers:copy-all-class($node)}
        {templates:process($node/node(), $model)}
        {$item/@title/data(.)}</a>)(:, if($model("ref_amount") != 0  and $item/@dir = "pub") then "," else ():)
        )
        )
        else ($model($ref))
};

declare function obras:PrintSubRef($node as node(), $model as map(*), $ref as xs:string, $dir as xs:string) {
 if($model($ref) != "") then (
        if(exists(obras:buildSearch($model($ref),"pub"))) then (
            let $refer :=  substring-before(root(obras:buildSearch($model($ref),"pub"))/util:document-name(.),".xml") 
            let $doc := doc(concat("/db/apps/pessoa/data/",$dir,"/",$refer,".xml"))
             let $title := $doc//tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/data(.)
            return (
                 (<a href="{$helpers:app-root}/{$helpers:web-language}/{$dir}/{$refer}">    
                 {helpers:copy-all-class($node)}
                 {templates:process($node/node(), $model)}
                 {$title}</a>), if($model("ref_amount") != 0 and $dir = "pub") then "," else ()
                 )
                )
                else ()
        )
        else ()
};


declare function obras:mentionedAs($node as node(), $model as map(*), $ref as xs:string, $dir as xs:string) {
        let $refer := if($dir eq "pub") then substring-before(root($model($ref))/util:document-name(.),".xml")  else $model($ref)
        let $doc := doc(concat("/db/apps/pessoa/data/",$dir,"/",$refer,".xml"))
        let $workn := $doc//tei:rs[@type="work" and @key=$model("xmlid")]/@style/data(.)
        let $list :=  $model("listEntry")
         let $mentioned := $list/tei:title[@subtype=$workn]/data(.)
        return if(exists($mentioned)) then <span class="Obras-DocList-Mention"> ({page:singleElement_xquery("roles","mentioned-as")}: <i>{string-join($mentioned,", ")})</i>,</span> 
                                else ()
};

declare function obras:SortByDate($db as node()*) {
    let $refs := for $doc in $db 
                            let $date := if(exists($doc//tei:origDate/@when)) then $doc//tei:origDate/@when/data(.)
                                                else if(exists($doc//tei:origDate/@notBefore)) then $doc//tei:origDate/@notBefore/data(.)
                                                else if(exists($doc//tei:origDate/@from)) then $doc//tei:origDate/@from/data(.)
                                                else "Error"
                                                 let $refer := substring-before(root($doc)/util:document-name(.),".xml") 
                             order by $date
                           return <item doc="{$refer}" date="{$date}" dir="doc" title="{$doc//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]/data(.)}"/>
(:    let $return := for $item in $refs order by $item/@date return $item
:)    
    return $refs
};
(: Unikate :)

declare function obras:SearchObras($node as node(), $model as map(*),$id as xs:string) {
    let $list :=  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]
     let $xmlid := for $name in $list/tei:item return if($name/tei:title[1]/data(.)  = xmldb:decode-uri($id)) then $name/@xml:id/data(.) else ()
    
    
    let $list := doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$xmlid]
    
    let $AltTitle := $list/tei:title[@type="alt"]/data(.)     
    return map {
        "MainTitle" := $list/tei:title[1]/data(.),
        "AltTitle" := string-join($AltTitle,", "),
        "FirstRef" := obras:SortByDate(obras:buildSearch($xmlid,"doc")),
        "listEntry" := $list,
        "Works" := $list/tei:list/tei:item,
        "xmlid" := $xmlid        
    }     

};

declare function obras:AnalyticObras($node as node(), $model as map(*), $ref as xs:string) {
    let $work := $model($ref)
    let $title := $work/tei:title/data(.)
    let $refs := obras:SortByDate(obras:buildSearch($work/@xml:id/data(.),"doc"))
    let $subworks := obras:ScanSubWorks($work)
    
    
    let $PRS := obras:buildSearch($work/@xml:id/data(.),"pub") (: Publikation Referation Search :)
    let $PRSd := $PRS//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date/@when/data(.)
    let $PR := <item doc="{substring-before(root($PRS)/util:document-name(.),".xml")}" 
                                date="{if(contains($PRSd,"-")) then substring-before($PRSd,"-") else $PRSd}"
                                dir="pub"
                                 title="{$PRS//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]/data(.)}"/>
    let $allRef := ($refs,$PR)                             
    let $ref_amount := count($allRef)
    let $sortAllRef := for $item in $allRef order by $item/@date return $item
    let $Arefs := for $ref in (1 to $ref_amount -1) return $sortAllRef[$ref] 
    
    let $Brefs := $sortAllRef[$ref_amount]
    return map {
        "title" := $title,
        "refs" := $Arefs,
        "lastref" := $Brefs,
        "subworks" := $subworks,
        "XMLID" := $work/@xml:id/data(.),
        "ref_amount" := $ref_amount
    }
};



declare function obras:ScanSubWorks($Work as node()*) {
if(exists($Work/tei:list)) then (
    let $SubWork := for $Sub in $Work/tei:list/tei:item
                                        return $Sub
    return   $SubWork       
    )
    else ()
    
};