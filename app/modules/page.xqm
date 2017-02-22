xquery version "3.0";

module namespace page="http://localhost:8080/exist/apps/pessoa/page";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace app="http://localhost:8080/exist/apps/pessoa/templates" at "app.xql";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";

declare %templates:wrap function page:construct($node as node(), $model as map(*)) as node()* {
    let $MainNav :=                
        <div id="navi_main">
            <ul id="navi_elements" >
                {page:createMainNav()}
                <li>                    
                 <a href="#" class="glyphicon glyphicon-search" id="search_button" role="tab" data-toggle="tab"></a>                     
                </li>
            </ul>
            </div>
    let $SubNav := page:createSubNav()
    let $ExtNav := page:createExtNav()
    let $return := ($MainNav,page:construct_search() ,$SubNav, $ExtNav)
    return $return            
};
declare function page:construct_search() as node()* {
let $search := <div class="container-4" id="searchbox" style="display:none">
                            <input type="search" id="search" placeholder="{concat(page:singleAttribute(doc("/db/apps/pessoa/data/lists.xml"),"search","term"),"....")}" />
                            <span class="icon2" id="nav_searchButton" onclick="search()">{page:singleAttribute(doc("/db/apps/pessoa/data/lists.xml"),"search","search_verb")}</span>
                            <a class="small_text" id="search-link" href="{$helpers:app-root}/{$helpers:web-language}/search">{page:singleAttribute(doc("/db/apps/pessoa/data/lists.xml"),"search","search_noun_ext")}</a>
                        </div>      
    let $clear :=  <div class="clear"></div>
    let $request-path := if($config:request-path != "") then $config:request-path else "index.html"
    let $page :=     if(contains($config:request-path,concat("/",$helpers:web-language,"/"))) then substring-after($request-path,concat("/",$helpers:web-language,"/")) else substring-after($request-path,"pessoa//")
    
    let $switchlang := if(contains($config:request-path,"search")) then 
    <script>
        function switchlang(value){{
       location.href="{$helpers:app-root}/"+value+"/{$page}{page:search_SwitchLang()}";
        }}
    </script>
    else <script>
        function switchlang(value){{location.href="{$helpers:app-root}/"+value+"/{$page}";}}
    </script>
    return ($search,$clear,$switchlang, search:search-function())
};

declare function page:search_SwitchLang() as xs:string {
let $return := 
    if(  request:get-parameter("search",'') = "simple") then
    string-join(("?term=",search:get-parameters("term"),"&amp;search=simple"),'')
    else string-join(("?term",substring-after(search:mergeParameters("html"),"term")),'')
    return $return
};

declare function page:createMainNav() as node()* {
let $type := ("autores","documentos","publicacoes","obras","genero","cronologia","index","projeto")
let $doc := doc("/db/apps/pessoa/data/lists.xml")
for $target in $type 
    let $name := if($helpers:web-language = "pt") then $doc//tei:term[@xml:lang = $helpers:web-language and @xml:id= $target]
                                  else $doc//tei:term[@xml:lang = $helpers:web-language and @corresp= concat("#",$target)]
    
  return <li class="mainNavTab {page:HighlightPage($target)}" id="navMain_{$target}">{$name/data(.)}</li>
};


declare function page:HighlightPage($target) {
  let $pagename :=   switch($target) 
                                    case "autores" return "author"
                                    case "publicacoes" return "pub"
                                    case "obras" return "obras"
                                    case "genero" return "genre"
                                    case "index" return ("bibliografia","names","titles","periodicals")
                                    case "documentos" return "doc"
                                    case "projeto" return ("about","team","documentation","download")
                                   default return "nothin"
   return for $page in $pagename  where contains($helpers:request-path,$page) return "highlight"                                
};

declare function page:createSubNav() as node()* {
    let $lists := doc("/db/apps/pessoa/data/lists.xml")
    for $tab in  $lists//tei:list[@type="navigation"]/tei:item/tei:term[@xml:lang="pt"]/attribute()[2]
        return page:createSubNavTabs($tab)
};

declare function page:createSubNavTabs($tab as xs:string) as node()* {
    let $SubNav := 
        <div class="navbar" id="{concat("nav_",$tab)}"  style="display:none"> 
            <ul class="nav_tabs">
            {page:createContent($tab)}
            </ul>
        </div>
    let $ThirdNav := if($tab = "documentos" or $tab = "cronologia" or $tab ="publicacoes" or $tab = "index") then
            <div class="navbar" id="{concat("nav_",$tab,"_sub")}" style="display:none" > 
                {page:createThirdNavTab($tab)}
            </div>
            else ()
        return ($SubNav,$ThirdNav)
};
declare function page:createContent($type as xs:string) as node()* {
    if($type != "documentos" and $type != "cronologia"  and $type != "publicacoes" and $type != "index") then
        for $item in page:createItem($type,"")
        return <li class="{concat("nav_",$type,"_tab")}" ><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
    else  let $result := page:createThirdNav($type)
    return $result
};


declare function page:createThirdNav($type as xs:string) as node()* {
    if($type ="documentos") then
        for $nr in ("1-9", "10","20","30","40","50","60","70","80","90","100","CP")
        return if( $nr != "1-9") then <li  class="{concat("nav_",$type,"_tab")}" id="navtab_{$type}_sub_{$nr}">
            {$nr}
            </li>
            else <li  class="{concat("nav_",$type,"_tab")}" id="navtab_{$type}_sub_{$nr}">
            1 - 9
            </li>
    else if ($type = "cronologia") then 
    let $time := ("1913-1915","1916-1919","1920-1927","1928-1935")
    (:     let $time := ("1902-1912","1913-1915","1916-1919","1920-1927","1928-1935") :)
    for $date in ($time, (doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item/tei:list[@type="cronologia"]/tei:item/tei:term[@xml:lang=$helpers:web-language]/data(.)))
            return if (contains($date, "1") != xs:boolean("true") ) then
                        <li class="{concat("nav_",$type,"_tab")}"> <span class="step">|</span> 
                        <a href="{concat($helpers:app-root,"/",$helpers:web-language,"/timeline")}" target="_blank">
                        {$date}
                        </a></li>
                    else if(substring-after($date,"19")!= "") then  <li class="{concat("nav_",$type,"_tab")}"  id="navtab_{$type}_sub_{index-of(($time,(doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item/tei:list[@type="cronologia"]/tei:item/tei:term[@xml:lang=$helpers:web-language]/data(.))),$date)-1}">
                        {$date}</li>
                        else ()
    else if ($type ="publicacoes") then for $authors in doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person
        return <li class="{concat("nav_",$type,"_tab")}" id="navtab_{$type}_sub_{$authors/attribute()}">
                    {$authors/tei:persName/data(.)}
                    </li>
     else if($type = "index") then for $indexies in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="index"]/tei:item/tei:term[@xml:lang=$helpers:web-language]
        let $id := if( contains($indexies/attribute()[2],"#")) then substring-after($indexies/attribute()[2],"#")
                        else $indexies/attribute()[2]
        return  if(contains($indexies/attribute()[2],"bibliografia")) then   <li class="{concat("nav_",$type,"_tab")}" id="navtab_{$type}_sub_{$id}">
                    {$indexies/data(.)}
            </li>
            else <li class="{concat("nav_",$type,"_tab")}"><a href="{concat($helpers:app-root,"/",$helpers:web-language,"/page/",$id)}">
                    {$indexies/data(.)}
                    </a>
            </li>
    else ()
};

declare function page:createThirdNavTab($type as xs:string) as node()* {
   if ($type = "documentos") then for $indikator in ("1-9", "10","20","30","40","50","60","70","80","90","100","CP") return
          <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
            <ul class="nav_sub_tabs">
            {page:createThirdNavContent($type,$indikator)}
         </ul>   </div>
    else if ($type = "cronologia") then for $indikator in (0 to 3) return 
    (:     else if ($type = "cronologia") then for $indikator in (0 to 4) return  :)
         <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
            <ul class="nav_sub_tabs">        
           {page:createThirdNavContent($type,$indikator)}
        </ul></div>
         (:  
        else if ($type = "obras") then for $indikator in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item/attribute() return
        <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
            <ul class="nav_sub_tabs">        
           {page:createThirdNavContent($type,$indikator)}
        </ul></div> :)
     else if($type= "publicacoes") then for $indikator in doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person/attribute() return
        <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
            <ul class="nav_sub_tabs">        
           {page:createThirdNavContent($type,$indikator)}
        </ul></div>
     else if ($type ="index") then 
        <div  id="{concat("nav_",$type,"_sub_bibliografia")}" style="display:none"> 
            <ul class="nav_sub_tabs">        
           {page:createThirdNavContent("bibliografia","")}
        </ul></div>
     else ()
};

declare function page:createThirdNavContent($type as xs:string, $indikator as xs:string) as node()* {
        if ($type = "documentos") then for $item in page:createItem($type, $indikator) 
        let $title := 
                for $elem in doc(concat("/db/apps/pessoa/data/doc/",$item/@label))//tei:titleStmt/tei:title/node() return
                if(exists($elem/node())) 
                    then <span class="doc_superscript">{$elem/node()/data(.)}</span> 
                else (
                    if(contains($elem,"BNP/E3")) then replace($elem,"BNP/E3 ","") 
                    else if(contains($elem,"CP")) then replace($elem,"CP ","") 
                    else $elem 
                    )
             let $title := ($title,<span class="doc_superscript"/>)
             let $label := substring-before(replace($item/@label,("BNP_E3_|CP"),""),".xml")
             let $front := if(contains($label,"-")) then substring-before($label,"-") else $label
            order by $front, xs:integer(replace($label, "^\d+[A-Z]?\d?-?([0-9]+).*$", "$1")) 
            return <a href="{$item/@ref/data(.)}"><li class="{concat("nav_",$type,"_sub_tab")}" >{$title}</li></a>
       else if ($type = "cronologia" ) then
        let $field := (13,16,20,28,15,19,27,35)
        (:        let $field := (2,13,16,20,28,12,15,19,27,35) :)
        let $indi := sum(xs:integer($indikator)+1)
       for $nr in ($field[$indi] to $field[sum($indi + 4)])
       (:        for $nr in ($field[$indi] to $field[sum($indi + 4)]) :)
       let $nr := if($nr < 10) then concat(0,$nr) else $nr
         return   if( page:createItem("cronologia",$nr)  ) then
                    <li class="{concat("nav_",$type,"_sub_tab")}" id="exttab_cro_{$nr}">{concat("'",$nr)}</li>
            else <li class="{concat("nav_",$type,"_sub_tab")} emptyTab" id="exttab_cro_{concat($indikator,$nr)}">{concat("'",$indikator,$nr)}</li> 
    (:
    else if ($type = "cronologia" and $indikator = "3") then for $nr in (0 to 5) 
            return <li class="{concat("nav_",$type,"_sub_tab")}"  id="exttab_cro_{concat($indikator,$nr)}">{concat("'",$indikator,$nr)}</li>
      :)      
        (:      
       else if ($type = "obras") then for $item in page:createItem($type, $indikator)
            return <a href="{$item/@ref/data(.)}"><li class="{concat("nav_",$type,"_sub_tab")}">{$item/@label/data(.)}</li></a>
            :)
      else if ($type = "publicacoes") then for $item in page:createItem($type, $indikator)
            return <a href="{$item/@ref/data(.)}"><li class="{concat("nav_",$type,"_sub_tab")}">{$item/@label/data(.)}</li></a>
      else if ($type = "bibliografia") then for $item in page:createItem($type, "")
            return <a href="{$item/@ref/data(.)}"><li class="{concat("nav_",$type,"_sub_tab")}">{$item/@label/data(.)}</li></a>
       else ()
};


declare function page:createExtNav() {
        let $type := "cronologia"
        return <div class="navbar" id="{concat("nav_",$type,"_sub_ext")}"  style="display:none"> 
            {page:createExtNavTab($type)}
        </div>
};

declare function page:createExtNavTab($type as xs:string) as node()* {
    if($type = "cronologia")then for $indikator in (0 to 3) 
        for $nr in (0 to 9) return if($indikator != 3) then
         <div id="{concat("nav_",$type,"_sub_ext_",$indikator,$nr)}" style="display:none">
             <ul class="nav_sub_tabs">
             {page:createExtendedTabsContent($type, concat($indikator,$nr))}
             </ul></div>
        else if($indikator = 3 and $nr <=5) then
         <div id="{concat("nav_",$type,"_sub_ext_",$indikator,$nr)}" style="display:none">
             <ul class="nav_sub_tabs">
             {page:createExtendedTabsContent($type, concat($indikator,$nr))}
             </ul></div>
             else ()
        else ()
        
};

declare function page:createExtendedTabsContent($type as xs:string, $indikator as xs:string) as node()* {
        if($type = "cronologia") then
        for $item in page:createItem($type,$indikator)
            return <a href="{$item/@ref/data(.)}"><li class="{concat("nav_",$type,"_sub_ext_tab")}">{$item/@label/data(.)}</li></a>
            else ()
};

declare function page:createItem($type as xs:string, $indikator as xs:string?) as item()* {
    if($type ="autores")
        then for $pers in doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person/tei:persName/data(.)
             order by $pers collation "?lang=pt"
             return <item label="{$pers}" ref="{concat($helpers:app-root,'/',$helpers:web-language)}/author/{tokenize(lower-case($pers), '\s')[last()]}/all" /> 
   else if($type = "genero") 
        then for $genre in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="genres"][@xml:lang=$helpers:web-language]/tei:item   
            let $label :=$genre/data(.)
            let $ref := if($helpers:web-language = "pt") then $genre/attribute()
                        else substring-after($genre/attribute(), "#")
            order by $genre collation "?lang=pt" 
            return <item label="{$label}"  ref="{concat($helpers:app-root,'/',$helpers:web-language)}/genre/{$ref}" /> 
   else if($type = "documentos") then
        for $item in doc("/db/apps/pessoa/data/doclist.xml")//docs[@dir = "doc"]/doc
        where $item[@indi = $indikator]
        return <item label="{$item/data(.)}" ref="{concat($helpers:app-root,'/',$helpers:web-language, "/doc/", $item/@id/data(.))}"/>
   else if($type = "cronologia")
        then let $date := concat("19",$indikator)
        for $para in ("date","date_when","date_notBefore","date_notAfter","date_from","date_to")
                let $db := collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                let $result := search:result_union(search:date_search($db,$para,$date))
                for $hit in $result
                    let $label := if(substring-after(root($hit)/util:document-name(.), "BNP") != "") then 
                                    substring-after(replace(substring-before(root($hit)/util:document-name(.), ".xml"), "_", " "), "E3")
                                  else if(substring-after(root($hit)/util:document-name(.),"CP") != "") then 
                                    substring-after(replace(substring-before(root($hit)/util:document-name(.), ".xml"), "_", " "), "CP")
                                  else if(page:clearPublikation($hit) != "") then page:clearPublikation($hit) 
                                  else ()
                    let $ref := if(substring-after(root($hit)/util:document-name(.),"BNP")!= "" or substring-after(root($hit)/util:document-name(.),"CP")!= "") 
                    then  concat($helpers:app-root,'/',$helpers:web-language, "/doc/", substring-before(root($hit)/util:document-name(.), ".xml"))
                    else concat($helpers:app-root,'/',$helpers:web-language, "/pub/", substring-before(root($hit)/util:document-name(.), ".xml"))
                return <item label="{$label}" ref="{$ref}"/>
   else if ($type ="bibliografia")
        then for $bibl in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="bibliografia"]/tei:item/tei:term[@xml:lang=$helpers:web-language]   
            let $label := $bibl/data(.)
            let $ref := if($helpers:web-language = "pt") then $bibl/attribute()[2]
                        else substring-after($bibl/attribute()[2],"#")
            return <item label="{$label}"  ref="{concat($helpers:app-root,'/',$helpers:web-language)}/page/bibliografia/{$ref}" /> 
   else if ($type = "projeto") 
        then for $projeto in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item/tei:list[@type="projeto"]/tei:item/tei:term[@xml:lang=$helpers:web-language]
            let $label := $projeto/data(.)
                let $ref := if($helpers:web-language = "pt") then $projeto/attribute()[2]
                            else substring-after($projeto/attribute()[2],"#")
            return <item label="{$label}"  ref="{concat($helpers:app-root,'/',$helpers:web-language)}/page/{$ref}" /> 
   else if ($type = "obras")
         then for $works in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"]/tei:item
         let $label := $works/tei:title[1]/data(.)
          return <item label="{$label}" ref="{concat($helpers:app-root,'/',$helpers:web-language)}/obras/{$works/tei:title[1]/data(.)}"/>
          (:return <item label="{$label}" ref="{concat($helpers:app-root,'/',$helpers:web-language)}/page/obras/ {$works/attribute()}"/>:)
    else if($type ="publicacoes")
        then for $hit in xmldb:get-child-resources("/db/apps/pessoa/data/pub")
            let $label :=  doc(concat("/db/apps/pessoa/data/pub/",$hit))//tei:fileDesc/tei:titleStmt/tei:title/data(.) 
                    order by $label
           return if(doc(concat("/db/apps/pessoa/data/pub/",$hit))//tei:author/tei:rs[@key=$indikator]) 
                        then <item label="{$label}" ref="{concat($helpers:app-root,'/',$helpers:web-language)}/pub/{substring-before($hit,".xml")}" />
                        else ()
   else for $a in "10" return <item label="nothin" ref="#"/>
};



declare function page:clearPublikation($pub as node()) as xs:string {
    for $author in ("Caeiro","Pessoa","Campos","Reis")
     return   if(substring-after(root($pub)/util:document-name(.),$author) != "")
            then substring-after(replace(replace(substring-before(root($pub)/util:document-name(.),".xml"),"-", " "),"_"," "),$author)
            else ()
};


declare function page:getPath() {
let $path := <div id="path">{ substring-after( $helpers:request-path,$helpers:web-language)}</div>
return $path
};



(:###### CALL LIST ELEMENTS ######:)

declare %templates:wrap function page:singleElement($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')    
    return page:singleAttribute($doc,$xmltype,$xmlid)     
};

declare function page:singleElement_xquery($type as xs:string,$id as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')   
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry/data(.)
};

declare function page:singleElementList_xquery($type as xs:string,$id as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')   
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]
                  else $doc//tei:list[@type=$type and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]
     return $entry/data(.)
};

declare function page:singleAttribute($doc as node(),$type as xs:string,$id as xs:string) as xs:string? {
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry/data(.)
};


(:
declare function page:page_singeAttribute_term($doc as node(),$type as xs:string,$id as xs:string, $lang as xs:string) as node()? {
    let $entry := if($lang = "pt") 
                  then $doc//tei:list[@type=$type]/tei:term[@xml:lang=$lang and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:term[@xml:lang=$lang and @corresp=concat("#",$id)]
     return $entry
};
:)
declare function page:createInput_item($xmltype as xs:string,$btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node()) as node()* {
    for $id in $value
        let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]/data(.)
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]/data(.)
        let $input := <input class="{concat($name,"_input-box")}" type="{$btype}" name="{$name}" value="{$id}" id="{$id}"/>
        let $label := <label class="{concat($name,"_input-label")}" for="{$id}">{$entry}</label>
        let $breaked := <br />
        return ($input,$label,$breaked)
};

declare function page:createInput_term($xmltype as xs:string, $btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node(), $checked as xs:string?) as node()* {
    for $id in $value
        let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]/data(.)
                      else $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]/data(.)
        let $input := if($checked = "checked") then <input class="{concat($name,"_input-box")}" type="{$btype}" name="{$name}" value="{$id}" id="{$id}" checked="checked"/>
                       else <input class="{concat($name,"_input-box")}" type="{$btype}" name="{$name}" value="{$id}" id="{$id}" />
        let $label := <label class="{concat($name,"_input-label")}" for="{$id}">{$entry}</label>
        let $breaked := <br />
        return ($input,$label,$breaked)
};

declare function page:createOption($xmltype as xs:string, $value as xs:string*,$doc as node()) as node()* {
    for $id in $value
         let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]/data(.)
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]/data(.)
        return <option value="{$id}">{$entry}</option>

};

(:###### TIMELINE ######:)
declare %templates:wrap function page:createTimelineBody($node as node(), $model as map(*)) as node()* {
    let $lists := doc('/db/apps/pessoa/data/lists.xml')    
    let $headline := page:singleAttribute($lists,"timeline","timeline_title")
    
    
    let $body := <body onload="onLoad();" onresize="onResize();">
         <h1><u>{$headline}</u></h1>

       <div id="my-timeline" style="height: 1500px; border: 1px solid #aaa; border-radius: 10px;" ></div>
        </body>
    
    return  $body
};

declare  function page:createTimelineHeader($node as node(), $model as map(*)) as node()* {
let $lists := doc('/db/apps/pessoa/data/lists.xml') 
 let $script3 := <script type="text/javascript">
         var tl;
        function onLoad() {{
            var eventSource = new Timeline.DefaultEventSource(0);
            
            var theme = Timeline.ClassicTheme.create();
            theme.event.bubble.width = 300;
            theme.event.bubble.height = 150;
			theme.event.tape.height = 10;
			theme.event.track.gap = -7;
		
			
			
        
			
            var data = Timeline.DateTime.parseGregorianDateTime("Oct 02 1905")
            var bandInfos = [
                Timeline.createBandInfo({{
                    width:          "3%",
                    intervalUnit:   Timeline.DateTime.DECADE, 
                    intervalPixels: 800,
                    date:           data,
                    showEventText:  false,
                    theme:          theme
                }}),
				
            Timeline.createBandInfo({{
                    width:          "3%", 
                    intervalUnit:   Timeline.DateTime.YEAR, 
                    intervalPixels: 80,
                    date:           data,
                    showEventText:  false,
                    theme:          theme
				
                }}),
				
                Timeline.createBandInfo({{
                    width:          "94%", 
                    intervalUnit:   Timeline.DateTime.YEAR, 
                    intervalPixels: 80,
                    eventSource:    eventSource,
                    date:           data,
					position:       false,
                    theme:          theme
				
                }})
            ];
            bandInfos[0].etherPainter = new Timeline.YearCountEtherPainter({{
                startDate:  "Jun 13 1888 ",
                multiple:   1,
                theme:      theme
           }});
			
			
			
			
          
			bandInfos[0].syncWith = 2;
		    bandInfos[1].syncWith = 2;
            bandInfos[1].highlight = false;
            bandInfos[0].decorators = [
                new Timeline.SpanHighlightDecorator({{
                    startDate:  "Jun 13 1888 ",
                    endDate:    "Nov 30 1935 ",
                    startLabel: "{page:singleAttribute($lists,"timeline","birth")}",
                    endLabel:   "{page:singleAttribute($lists,"timeline","death")}",
                    color:      "#B8B8E6",
                    opacity:    50,
                    theme:      theme
                }})
            ];
            			
			
			
            tl = Timeline.create(document.getElementById("my-timeline"), bandInfos, Timeline.HORIZONTAL);
            tl.loadXML("../events.xml", function(xml, url) {{
                eventSource.loadXML(xml, url);
            }});
        }}
    </script>		
    return $script3
};


(: ########### Mehrsprachigkeit ##############:)


