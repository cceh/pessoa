xquery version "3.0";

module namespace obras="http://localhost:8080/exist/apps/pessoa/obras";


import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";


declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";

declare function obras:test($node as node(), $model as map(*), $id as xs:string?) as node()* {
    let $test := "Hello"
    return <p>{$test, $id}</p>
};

declare function obras:getObras($node as node(),$model as map(*), $id as xs:string) as node()* {
    let $list := doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]
   
   return for $firstitem in $list/tei:title return
        if(exists($firstitem[@type])) then 
            <h4 class="t_obras_alt">{$firstitem/data(.)} </h4>
            else <h4 class="t_obras">{$firstitem/data(.)}</h4>
            ,
           
            if (exists(obras:getLinks( doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]/attribute(),"doc"))) then 
             let $list := doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id] 
         return <div><span class="ObLink" id="link_{$list/attribute()}">{page:singleElement_xquery("navigation","documentos")}</span><ul class="oul"  id="{$list/attribute()}">{
            for $link in obras:getLinks( $list/attribute(),"doc") return 
                <a href="{$link/@ref/data(.)}" class="olink"><li>{$link/@doc/data(.)}</li></a>} 
                
         </ul></div>
         else ()
         
         ,
         let $list := doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]
        for $secitem in $list/tei:list/tei:item return <div class="sec"> { 
            if (exists($secitem[@xml:id])) then
                if (exists(obras:getLinks($secitem/attribute(),"pub"))) then
                        <a href="{obras:getLinks($secitem/attribute(),"pub")/@ref}" class="wlink">{$secitem/tei:title/data(.)}</a> 
                        else  <p>{$secitem/tei:title/data(.)}</p> 
                 else <p>{$secitem/tei:title/data(.)}</p>}       
                 {if(exists($secitem[@xml:id]) and exists(obras:getLinks($secitem/attribute(),"doc"))) then 
             <div ><span class="ObLink" id="link_{$secitem/attribute()}">{page:singleElement_xquery("navigation","documentos")}</span><ul class="oul" id="{$secitem/attribute()}">{ 
                    for $link in obras:getLinks($secitem/attribute(),"doc") 
                            return <a href="{$link/@ref/data(.)}" class="olink"><li>{$link/@doc/data(.)}</li></a> } 
                   </ul> </div>
                            else ()  }  {
            if(exists($secitem/tei:list)) then <ul class="wul">  {
                for $thirditem in $secitem/tei:list/tei:item return 
                    <li class="third">
                    { 
            if (exists($thirditem[@xml:id])) then 
                if(contains($thirditem/attribute(), "O3-5")) then <a href="{concat(obras:getLinks("O3-5","pub")/@ref,"#",substring-after($thirditem/attribute(),"O3-5-"))}" class="wlink">{$thirditem/tei:title/data(.)}</a> 
                else  if (exists(obras:getLinks($thirditem/attribute(),"pub"))) then
                           <a href="{obras:getLinks($thirditem/attribute(),"pub")/@ref}" class="wlink">{$thirditem/tei:title/data(.)}</a> 
                      else  <p class="third-sec">{$thirditem/tei:title/data(.)}</p> 
                 else
                    <p>{$thirditem/tei:title/data(.)}</p>    }   
                    {if(exists($thirditem[@xml:id]) and exists(obras:getLinks($thirditem/attribute(),"doc"))) then 
                    <div><span class="ObLink" id="link_{$thirditem/attribute()}">{page:singleElement_xquery("navigation","documentos")}</span>
                        <ul class="oul">{ 
                            for $link in obras:getLinks($thirditem/attribute(),"doc") return 
                            <a href="{$link/@ref/data(.)}" class="olink"><li>{$link/@doc/data(.)}</li></a> } 
                        </ul> </div>
                       else () } 
                    </li>} 
                   </ul> else () }
               </div>
};


declare function obras:getTitles ($id as xs:string, $stage as xs:integer) as item()* {
   if($stage = 0) then 
        for $item in  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id]
            let $ref := if(exists(obras:buildSearch($item/attribute(),"pub")) ) then concat($helpers:app-root,"/",$helpers:web-language,"/pub/", substring-before(root(obras:buildSearch($item/attribute(),"pub"))/util:document-name(.),".xml")) else ""
             return <item title="{$item/tei:title/data(.)}" key="{$item/attribute()}" ref="{$ref}"/>
    else if ($stage = 1) then    for $item in  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id] /tei:list/tei:item 
            let $ref :=if(exists($item/attribute())) then
                                if(obras:buildSearch($item/attribute(),"pub") != "" ) then concat($helpers:app-root,"/",$helpers:web-language,"/pub/", substring-before(root(obras:buildSearch($item/attribute(),"pub"))/util:document-name(.),".xml")) else ""
                                else ""
            return (<item title="{$item/tei:title/data(.)}" key="{$item/attribute()}" ref="{$ref}"/>,
            if(exists($item/tei:list)) then 
                for $subitem in  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=$id] /tei:list/tei:item/tei:list/tei:item 
                let $ref := if(exists(obras:buildSearch($subitem/attribute(),"pub")) ) then concat($helpers:app-root,"/",$helpers:web-language,"/pub/",substring-before(root(obras:buildSearch($subitem/attribute(),"pub"))/util:document-name(.),".xml")) else ""
                     return <item title="{$subitem/tei:title/data(.)}" key="{$subitem/attribute()}" ref="{$ref}"/>
                    else () )
   else ()

};

declare function obras:getLinks($id as xs:string, $lib as xs:string) as item()* {
        for $item in obras:buildSearch($id,$lib) 
        let $doc := substring-before(root($item)/util:document-name(.),".xml")
        let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/",$lib,"/",$doc)
        return <item doc="{$doc}"  ref="{$ref}"/>
};

declare function obras:buildSearch($id as xs:string, $type as xs:string) as node()* {
        let $db := if($type = "doc") then collection( "/db/apps/pessoa/data/doc")
                           else collection( "/db/apps/pessoa/data/pub")
        let $key := if($type ="doc")  then "person" else "key"
        let $search_terms := concat('("type","',$key,'"),"work","',$id,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};





declare function obras:SearchObras($node as node(), $model as map(*)) {
    let $list :=  doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item[@xml:id=substring-after($helpers:request-path,"obras/")]
    let $AltTitle := if($list/tei:title[@type="alt"]) then $list/tei:title[@type="alt"]/data(.) else ()
    
    return map {
        "MainTitle" := $list/tei:title[1]/data(.),
        "AltTitle" := string-join($AltTitle,", "),
        "FirstRef" := obras:buildSearch(substring-after($helpers:request-path,"obras/"),"doc"),
        "Works" := obras:ScanWorksDeep($list/tei:list/tei:item)
        
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
        "ref" := obras:buildSearch($id,"pub"),
        "docs" := obras:buildSearch($id,"doc")
    }
};

declare function obras:CheckForDocs ($node as node(), $model as map(*)) {
    if ($model("docs") != "") then <div class="SubNav olink">{page:singleElement_xquery("navigation","documentos")}</div> else ""
};

declare function obras:CheckForWorks($node as node(), $model as map(*)) {
    let $db := $model("ref") 
    let $doc := substring-before(root($db)/util:document-name(.),".xml")
    let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc)
   return if($model("SubWorks") != "") then <div class="SubNav olink">{page:singleElement_xquery("navigation","publicacoes")}</div> else <a href="{$ref}" class="olink">{page:singleElement_xquery("navigation","publicacoes")}</a>

};

declare function obras:PrintSubWorks($node as node(), $model as map(*)) {
    let $db := $model("SubWork")
    
    let $doc := substring-before(root($model("ref"))/util:document-name(.),".xml")
    let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/pub/",$doc,"#",substring-after(data($db/attribute()),concat($model("WorkId"),"-")) )
    return <a href="{$ref}" class="olink">{$db/tei:title/data(.)}</a>
};

declare function obras:PrintLinks($node as node(), $model as map(*), $folder as xs:string, $name as xs:string?) {
    let $db := $model("ref") 
    let $doc := substring-before(root($db)/util:document-name(.),".xml")
        let $ref := concat($helpers:app-root,"/",$helpers:web-language,"/",$folder,"/",$doc)
        let $docn := if($name != "") then  page:singleElement_xquery("navigation","publicacoes") else $doc     
        return <a href="{$ref}" class="olink">{$docn}</a>
};

declare function obras:printData($node as node(), $model as map(*), $type as xs:string) {
    $model($type)
};

declare function obras:printWorkName($node as node(), $model as map(*))  {
    let $mainName := $model("WorkName")
    let $AltName := if($model("WorkAltName") != "") then <i class="AltTitle">{concat(',',string-join($model("WorkAltName"),",")) } </i> else ()
    return ($mainName, $AltName)
};