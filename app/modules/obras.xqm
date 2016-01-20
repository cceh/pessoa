xquery version "3.0";

module namespace obras="http://localhost:8080/exist/apps/pessoa/obras";


import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";


declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";

declare function obras:test($node as node(), $model as map(*),$id as xs:string) {
 xmldb:decode-uri($id)
};


declare function obras:SearchObras($node as node(), $model as map(*), $id as xs:string ) {

    let $list :=  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]
     let $xmlid := for $name in $list/tei:item return if($name/tei:title[1]/data(.)  = xmldb:decode-uri($id)) then $name/@xml:id/data(.) else ()
    
    
    let $list := doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$xmlid]
    
    let $AltTitle := $list/tei:title[@type="alt"]/data(.) 
    
    return map {
        "MainTitle" := $list/tei:title[1]/data(.),
        "AltTitle" := string-join($AltTitle,", "),
        "FirstRef" := obras:buildSearch($xmlid,"doc"),
        "Works" := $list/tei:list/tei:item,
        "xmlid" := $xmlid        
    }     
};



declare function obras:ScanWorksDeep ($works as node()* ) {
    let $return := if(data($works/attribute()) != "") then $works
            else $works/tei:list/tei:item
            return $return
};


declare function obras:AnalyzeWorks($node as node(), $model as map(*)) {
    let $db := $model("Work") 
    let $id := data($db/attribute())
    (:  :)

    return map {
        "WorkName" := $db/tei:title[1]/data(.),
        "WorkAltName" := $db/tei:title[@type="alt"]/data(.),
        "WorkId" :=$id ,
        "SubWorks" := $db/tei:list/tei:item,
        "ref" := if($id != "") then obras:buildSearch($id,"pub") else ""
        
    }
};

declare function obras:CheckSubWorks($node as node(), $model as map(*)) {
    let $db := $model("SubWork")
    return map {
     "SubWorkTitle" := $db/tei:title/data(.),
     "SubWorkId" := $db/@xml:id,
     "ThirdWorks" :=   if (exists($db/tei:list)) then $db/tei:list  else ()
     }
};


declare function obras:PrintSubWorks($node as node(), $model as map(*)) {    
    if($model("ThirdWorks") != "") then 
        <div class="Obras-SubNav">
            <div class="Obras-SubNav-Publication olink">{$model("SubWorkTitle")}</div>
            <ul class="Obras-PubList">
            <li class="Obras-PubList-Publicacao">{
            let $ref := obras:buildSearch($model("SubWorkId"),"pub")
             let $doc := if($ref != "") then  substring-before(root($ref)/util:document-name(.),".xml") else ""
             let $link := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc,"#",$model("SubWorkId"))
            return 
            if( $doc != "" ) then  
            <a href="{$link}" class="olink">{page:singleElement_xquery("obras","publication")}</a> 
            else ()
            }</li>
                {for $work in $model("ThirdWorks")/tei:item
                    let $ref := obras:buildSearch(concat("#",$work/@xml:id),"pub-div")
                    let $doc := if($ref != "") then  substring-before(root($ref)/util:document-name(.),".xml") else ""
                    let $link := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc,"#",$work/@xml:id)
                   return <li> {
                        if( $doc != "" ) then  
                        (<div class="Obras-SubNav-Publicacao olink">{$work/tei:title/data(.)}</div>,
                        <span style="display:none"><a href="{$link}" class="clink">{page:singleElement_xquery("obras","publication")}</a></span>)
                      (:  <a href="{$link}" class="olink">{$work/tei:title/data(.)}</a> :)
                        else <span id="{$work/@xml:id}">{$work/tei:title/data(.)}</span>
                       } </li>
                }
                </ul>
         </div>
         else  
             let $ref := obras:buildSearch($model("SubWorkId"),"pub")
             let $doc := if($ref != "") then  substring-before(root($ref)/util:document-name(.),".xml") else ""
             let $link := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc,"#",$model("SubWorkId"))
            return 
            <div class="Obras-SubNav"> {
            if( $doc != "" ) then  (
            <div class="Obras-SubNav-Publicacao Obras-SubNav-Alone olink">{$model("SubWorkTitle")}</div>,
            <span style="display:none"><a href="{$link}" class="clink">{page:singleElement_xquery("obras","publication")}</a></span>)
            else <span>{$model("SubWorkTitle")}</span>
           } </div>
};


(:
declare function obras:PrintSubWorks($node as node(), $model as map(*)) {
    let $db := $model("SubWork")
    let $ref := if($model("ref") != "") then $model("ref") else obras:buildSearch(data($db/attribute()),"pub")
    let $doc := if($ref != "") then  substring-before(root($ref)/util:document-name(.),".xml") else ""
    let $link := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc,"#",data($db/attribute()) )
    return if( $doc != "" ) then <a href="{$link}" class="olink">{$db/tei:title/data(.)}</a> else $db/tei:title/data(.)
};:)



declare function obras:buildSearch($xmlid as xs:string, $type as xs:string) as node()* {
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
};

declare function obras:CheckForDocs ($node as node(), $model as map(*)) {
    if ($model("docs") != "") then <div class="Obras-SubNav olink">{page:singleElement_xquery("navigation","documentos")}</div> else ""
};

declare function obras:CheckForWorks($node as node(), $model as map(*)) {
if($model("ref")  != "") then  
  let $db := $model("ref") 
    let $doc := substring-before(root($db)/util:document-name(.),".xml")
    let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc)
   return if($model("SubWorks") != "") then (<div><a href="{$ref}" class="olink">{page:singleElement_xquery("obras","publication")}</a></div>,
            <div class="Obras-SubNav Obras-SubNav-Pub"><h8>{page:singleElement_xquery("navigation","publicacoes")}</h8></div>) 
            else <a href="{$ref}" class="olink">{page:singleElement_xquery("obras","publication")}</a>
 else <div class="Obras-SubNav olink">{page:singleElement_xquery("navigation","publicacoes")}</div>
};

declare function obras:PrintLinks($node as node(), $model as map(*), $folder as xs:string, $name as xs:string?) {
   
     if ( $model("ref")  != "") then 
      let $db :=$model("ref")
         let $doc := substring-before(root($db)/util:document-name(.),".xml")
        let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/",$folder,"/",$doc)
        let $docn := if($name != "") then  page:singleElement_xquery("navigation","publicacoes") else $doc     
       return  <a href="{$ref}" class="olink">{$docn}</a>
        else  page:singleElement_xquery("navigation","publicacoes")
};

declare function obras:PrintDocLinks($node as node(), $model as map(*)) {
    let $id := $model("xmlid")
    return
     if ( $model("ref")  != "") then 
      let $db :=$model("ref")
         let $doc := substring-before(root($db)/util:document-name(.),".xml")
        let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/doc/",$doc)
        let $workn := $db//tei:rs[@type="work" and @key=$id]/@style
        let $list :=  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]
        let $mentioned := $list/tei:title[@subtype=$workn]/data(.)
       return  <a href="{$ref}" class="olink">
                            <span class="Obras-DocList-Doc">{$doc}</span>
                            { if( exists($mentioned)) then   
                            <span class="Obras-DocList-Mention"> ({page:singleElement_xquery("roles","mentioned-as")}: <i>{$mentioned})</i></span> 
                                else () }
       
       </a>
   else ()
};

declare function obras:printData($node as node(), $model as map(*), $type as xs:string) {
    $model($type)
};

declare function obras:printWorkName($node as node(), $model as map(*))  {
    let $mainName := $model("WorkName")
    let $AltName := if($model("WorkAltName") != "") then <i class="Obras-AltTitle">{concat(',',string-join($model("WorkAltName"),",")) } </i> else ()
    return ($mainName, $AltName)
};