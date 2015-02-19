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
            <ul id="re-navi" >
                {page:createMainNav()}
                <li>                    
                 <a href="#" class="glyphicon glyphicon-search" onclick="hide('searchbox')" role="tab" data-toggle="tab"></a>                     
                </li>
            </ul>
    let $SubNav := page:createSubNav()

    let $search := <div class="container-4" id="searchbox">
                            <input type="search" id="search" placeholder="Search..." />
                            <button class="icon" id="button" onclick="search()"><i class="fa fa-search" ></i>
                                </button>
                        </div>      
    let $switchlang := <script>
        function switchlang(value){{location.href="{concat($helpers:app-root,substring-after($helpers:request-path,"pessoa/"))}?plang="+value;}}
        
    </script>
    let $return := ($MainNav,$search, $switchlang, $SubNav)
    return $return
};


declare function page:createMainNav() as node()* {
let $type := ("autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto")
let $doc := doc("/db/apps/pessoa/data/lists.xml")
for $target in $type 
    let $name := if($helpers:web-language = "pt") then $doc//tei:term[@xml:lang = $helpers:web-language and @xml:id= $target]
                                  else $doc//tei:term[@xml:lang = $helpers:web-language and @corresp= concat("#",$target)]
    
  return <li><a href="#{$target}" role="tab" data-toggle="tab" onclick="u_nav({concat("'","nav_",$target,"'")})">{$name}</a></li>
};



declare function page:createSubNav() as node()* {
    let $lists := doc("/db/apps/pessoa/data/lists.xml")
    for $tab in  $lists//tei:list[@type="navigation"]/tei:item/tei:term[@xml:lang="pt"]/attribute()[2]
        return page:createSubNavTabs($tab)
};

declare function page:createSubNavTabs($tab as xs:string) as node()* {
    let $SubNav := 
        <div class="navbar" id="{concat("nav_",$tab)}"  > 
            <ul class="nav_tabs">
            {page:createContent($tab)}
            </ul>
        </div>
    let $ThirdNav := if($tab = "documentos" or $tab = "cronologia") then
            <div class="navbar" id="{concat("nav_",$tab,"_sub")}" style="display:none" > 
                {page:createThirdNavTab($tab)}
            </div>
            else ()
        return ($SubNav,$ThirdNav)
};
declare function page:createContent($type as xs:string) as node()* {
    if($type != "documentos" and $type != "cronologia") then
        for $item in page:createItem($type,"")
        return <li class="{concat("nav_",$type,"_tab")}" ><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
    else  let $result := page:createThirdNav($type)
    return $result
};


declare function page:createThirdNav($type as xs:string) as node()* {
    if($type ="documentos") then
        for $nr in (1 to 9)
        return <li  class="{concat("nav_",$type,"_tab")}">
            <a href="#"  
            onclick="u_nav({concat("'nav_",$type,"_sub_",$nr,"'")})">
            {concat($nr,"0")}
            </a></li>
        else if ($type = "cronologia") then for $date in ("1900 - 1909","1910 - 1919","1920 - 1929","1930 - 1935", doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item[5]/tei:list/tei:item/tei:term[@xml:lang=$helpers:web-language]/attribute()[2])
        return if ($date = "timeline" or $date = "#timeline") then
            <li class="{concat("nav_",$type,"_tab")}"><a href="#">{doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item[5]/tei:list/tei:item/tei:term[@xml:lang=$helpers:web-language]/data(.)}</a></li>
        else <li class="{concat("nav_",$type,"_tab")}">
            <a href="#" 
            onclick="u_nav({concat("'nav_",$type,"_sub_",(index-of(("1900 - 1909","1910 - 1919","1920 - 1929","1930 - 1935"),$date)-1),"'")})">
            {$date}
            </a></li>
        else ()
};

declare function page:createThirdNavTab($type as xs:string) as node()* {
   if ($type = "documentos") then for $indikator in (1 to 9) return
    <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
    <ul class="nav_sub_tabs">
    {page:createThirdNavContent($type,$indikator)}
         </ul>   </div>
    else if ($type = "cronologia") then for $indikator in (0 to 3) return 
         <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
         <ul class="nav_sub_tabs">        
        {page:createThirdNavContent($type,$indikator)}
        </ul></div>
     else ()
};

declare function page:createThirdNavContent($type as xs:string, $indikator as xs:string) as node()* {
        if ($type = "documentos") then for $item in page:createItem($type, $indikator) 
            return <li class="{concat("nav_",$type,"_sub_tab")}"><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
        else if ($type = "cronologia") then for $item in page:createItem($type,$indikator)
            return <li class="{concat("nav_",$type,"_sub_tab")}"><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
           else ()
};


declare function page:createItem($type as xs:string, $indikator as xs:string?) as item()* {
    if($type ="autores")
        then for $pers in doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person/tei:persName/data(.)
             order by $pers collation "?lang=pt"
             return <item label="{$pers}" ref="{$helpers:app-root}/author/{tokenize(lower-case($pers), '\s')[last()]}/all" /> 
   else if($type = "genero") 
        then for $genre in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="genres"][@xml:lang=$helpers:web-language]/tei:item   
            let $label :=$genre/data(.)
            let $ref := if($helpers:web-language = "pt") then $genre/attribute()
                        else substring-after($genre/attribute(), "#")
            order by $genre collation "?lang=pt" 
            return <item label="{$label}"  ref="{$helpers:app-root}/page/genre_{$ref}.html" /> 
   else if($type = "documentos") 
        then for $hit in xmldb:get-child-resources("/db/apps/pessoa/data/doc")
            let $label :=   if(substring-after($hit, "BNP_E3_") != "") then substring-after(replace(substring-before($hit, ".xml"), "_", " "), "BNP E3 ")
                            else if(substring-after($hit,"MN") != "") then substring-after(replace(substring-before($hit, ".xml"), "_", " "), "MN")
                            else ()
                let $ref := concat($helpers:app-root, "/doc/", substring-before($hit, ".xml"))         
                      order by $hit collation "?lang=pt" 
                      return if(substring-after(replace(substring-before($hit, ".xml"), "_", " "), concat("BNP E3 ",$indikator)) 
                      or 
                      substring-after(replace(substring-before($hit, ".xml"), "_", " "), concat("MN",$indikator))) then
                      <item label="{$label}" ref="{$ref}?plang={$helpers:web-language}"  />
                      else ()
   else if($type = "cronologia")
        then for $date in (xs:integer(concat("19",$indikator,"0")) to xs:integer(concat("19",$indikator,"9")))
        for $para in ("date","date_when","date_notBefore","date_notAfter","date_from","date_to")
                let $db := collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                let $result := search:date_search($db,$para,$date) 
                for $hit in $result
                    let $label := if(substring-after(root($hit)/util:document-name(.), "BNP") != "") then substring-after(replace(substring-before(root($hit)/util:document-name(.), ".xml"), "_", " "), "BNP E3 ")
                                  else if(substring-after(root($hit)/util:document-name(.),"MN") != "") then substring-after(replace(substring-before(root($hit)/util:document-name(.), ".xml"), "_", " "), "MN")
                                  else if(    substring-after(root($hit)/util:document-name(.),"Caeiro") != "" 
                                           or substring-after(root($hit)/util:document-name(.),"Pessoa") != "" 
                                           or substring-after(root($hit)/util:document-name(.),"Campos") != ""
                                           or substring-after(root($hit)/util:document-name(.),"Reis") != "")
                                           then substring-after(replace(substring-before(root($hit)/util:document-name(.),".xml"),"-", " "),"_")
                                  else ()
                    let $ref := if(substring-after(root($hit)/util:document-name(.),"BNP")!= "" or substring-after(root($hit)/util:document-name(.),"MN")!= "") 
                    then  concat($helpers:app-root, "/doc/", substring-before(root($hit)/util:document-name(.), ".xml"))
                    else concat($helpers:app-root, "/pub/", substring-before(root($hit)/util:document-name(.), ".xml"))
                return <item label="{$label}" ref="{$ref}"/>
   else if ($type ="bibliografia")
        then for $bibl in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item[6]/tei:list/tei:item/tei:term[@xml:lang=$helpers:web-language]   
            let $label :=$bibl/data(.)
            let $ref := if($helpers:web-language = "pt") then $bibl/attribute()[2]
                        else substring-after($bibl/attribute()[2],"#")
            return <item label="{$label}"  ref="{$helpers:app-root}/page/bibliografia.html?type={$ref}" /> 
   else for $a in "10" return <item label="nothin" ref="#"/>
};


(: SEARCH PAGE :)

declare function page:singleElement($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as node()* {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')    
    return page:singleAttribute($doc,$xmltype,$xmlid)     
};

declare function page:singleAttribute($doc as node(),$type as xs:string,$id as xs:string) as node()? {
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry
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
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]
        let $input := <input type="{$btype}" name="{$name}" value="{$id}" id="{$id}"/>
        let $label := <label for="{$id}">{$entry}</label>
        return ($input,$label)
};

declare function page:createInput_term($xmltype as xs:string, $btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node()) as node()* {
    for $id in $value
        let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                      else $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
        let $input := <input type="{$btype}" name="{$name}" value="{$id}" id="{$id}"/>
        let $label := <label for="{$id}">{$entry}</label>
        return ($input,$label)
};

declare function page:createOption($xmltype as xs:string, $value as xs:string*,$doc as node()) as node()* {
    for $id in $value
         let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]
        return <option value="{$id}">{$entry}</option>

};


