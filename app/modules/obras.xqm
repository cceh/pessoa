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


declare function obras:PrintRef($node as node(), $model as map(*), $ref as xs:string, $dir as xs:string) {
   if($model($ref) != "") then (
   let $refer := substring-before(root($model($ref))/util:document-name(.),".xml") 
         let $title := doc(concat("/db/apps/pessoa/data/",$dir,"/",$refer,".xml"))//tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[1]/data(.)
    return <a href="{$helpers:app-root}/{$helpers:web-language}/{$dir}/{$refer}">    
        {helpers:copy-all-class($node)}
        {templates:process($node/node(), $model)}
        {$title}</a>
        )
        else ()
};

declare function obras:PrintSubRef($node as node(), $model as map(*), $ref as xs:string, $dir as xs:string) {
 if($model($ref) != "") then (
        if(exists(obras:buildSearch($model($ref),"pub"))) then (
            let $refer :=  substring-before(root(obras:buildSearch($model($ref),"pub"))/util:document-name(.),".xml") 
            let $doc := doc(concat("/db/apps/pessoa/data/",$dir,"/",$refer,".xml"))
             let $title := $doc//tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[1]/data(.)
            return <a href="{$helpers:app-root}/{$helpers:web-language}/{$dir}/{$refer}#{$model($ref)}">    
                {helpers:copy-all-class($node)}
                {templates:process($node/node(), $model)}
                {$title}</a>
                )
                else ()
        )
        else ()
};


declare function obras:mentionedAs($node as node(), $model as map(*), $ref as xs:string, $dir as xs:string) {
        let $refer :=  substring-before(root($model($ref))/util:document-name(.),".xml") 
        let $doc := doc(concat("/db/apps/pessoa/data/",$dir,"/",$refer,".xml"))
        let $workn := $doc//tei:rs[@type="work" and @key=$model("xmlid")]/@style/data(.)
        let $list :=  $model("listEntry")
         let $mentioned := $list/tei:title[@subtype=$workn]/data(.)
        return if(exists($mentioned)) then <span class="Obras-DocList-Mention"> ({page:singleElement_xquery("roles","mentioned-as")}: <i>{$mentioned})</i></span> 
                                else ()
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
        "FirstRef" := obras:buildSearch($xmlid,"doc"),
        "listEntry" := $list,
        "Works" := $list/tei:list/tei:item,
        "xmlid" := $xmlid        
    }     

};

declare function obras:AnalyticObras($node as node(), $model as map(*), $ref as xs:string) {
    let $work := $model($ref)
    let $title := $work/tei:title/data(.)
    
    return map {
        "title" := $title,
        "refs" := obras:buildSearch($work/@xml:id/data(.),"doc"),
        "subworks" := obras:ScanSubWorks($work),
        "XMLID" := $work/@xml:id/data(.),
        "PubRef" := obras:buildSearch($work/@xml:id/data(.),"pub")
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