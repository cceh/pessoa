xquery version "3.0";

module namespace obras="http://localhost:8080/exist/apps/pessoa/obras";


import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";


declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";


declare function obras:SearchObras($node as node(), $model as map(*), $id as xs:string ) {
    let $list :=  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]
    let $AltTitle := $list/tei:title[@type="alt"]/data(.) 
    
    return map {
        "MainTitle" := $list/tei:title[1]/data(.),
        "AltTitle" := string-join($AltTitle,", "),
        "FirstRef" := obras:buildSearch($id,"doc"),
        "Works" := $list/tei:list/tei:item
        
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

declare function obras:buildSearch($id as xs:string, $type as xs:string) as node()* {
        let $db := if($type = "doc") then collection( "/db/apps/pessoa/data/doc")
                           else collection( "/db/apps/pessoa/data/pub")
        let $key := if($type ="doc")  then "person" else "work-index"
        let $search_terms := if($type ="doc") then  
                                                concat('("type","person"),"work","',$id,'"')
                                             else
                                                concat('("work-index"),"',$id,'"')
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
   return if($model("SubWorks") != "") then <div class="Obras-SubNav olink">{page:singleElement_xquery("navigation","publicacoes")}</div> else <a href="{$ref}" class="olink">{page:singleElement_xquery("navigation","publicacoes")}</a>
else <div class="Obras-SubNav olink">{page:singleElement_xquery("navigation","publicacoes")}</div>
};

declare function obras:PrintSubWorks($node as node(), $model as map(*)) {
    let $db := $model("SubWork")
    let $ref := if($model("ref") != "") then $model("ref") else obras:buildSearch(data($db/attribute()),"pub")
    let $doc := if($ref != "") then  substring-before(root($ref)/util:document-name(.),".xml") else ""
    let $link := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc,"#",data($db/attribute()) )
    return if( $doc != "" ) then <a href="{$link}" class="olink">{$db/tei:title/data(.)}</a> else $db/tei:title/data(.)
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

declare function obras:PrintDocLinks($node as node(), $model as map(*), $id as xs:string) {
   
     if ( $model("ref")  != "") then 
      let $db :=$model("ref")
         let $doc := substring-before(root($db)/util:document-name(.),".xml")
        let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/doc/",$doc)
        let $role :=  $db//tei:rs[@type="work" and @key=$id]//tei:rs[@role]
        let $role2 := for $rolen in $role/@role return page:singleElement_xquery("roles",$rolen)
        let $rolename := distinct-values(($role2,$role2))
        let $docn := if( exists($rolename)) then  concat($doc," (", page:singleElement_xquery("roles","mentioned-as"),":" ,$rolename,")") 
                                
                                else $doc
       return  <a href="{$ref}" class="olink">{$doc}{ if( exists($rolename)) then   <i> ({page:singleElement_xquery("roles","mentioned-as")}: {$rolename})</i> 
                                
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