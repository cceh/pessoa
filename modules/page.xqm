xquery version "3.0";

module namespace page="http://localhost:8080/exist/apps/pessoa/page";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";


declare %templates:wrap function page:construct($node as node(), $model as map(*)) as node()* {
    let $nav := page:createNav()
    let $lists :=                
            <ul id="navi" class="nav nav-tabs" role="tablist">
                {page:createNav()}
                <li>                    
                  <div class="box">
                        <div class="container-4">
                            <input type="search" id="search" placeholder="Search..." />
                            <button class="icon" id="button" onclick="search()"><i class="fa fa-search" ></i>
                                </button>
                        </div>
                    </div>                  
                </li>
            </ul>
   (: let $content :=
        <div id="navi2" class="tab-content">
            {page:createContent()}
        </div>:)
    let $switchlang := <script>function switchlang(value){{location.href="{concat($helpers:app-root,substring-after($helpers:request-path,"pessoa/"))}?plang="+value;}}</script>
    let $return := ($lists, $switchlang)
    return $return
};


declare function page:createNav() as node()* {
let $type := ("autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto")
let $doc := doc("/db/apps/pessoa/data/lists.xml")
let $lang := $helpers:web-language
for $target in $type 
    let $name := if($lang = "pt") then $doc//tei:term[@xml:lang = $lang and @xml:id= $target]
                                  else $doc//tei:term[@xml:lang = $lang and @corresp= concat("#",$target)]
  return <li><a href="#{$target}" role="tab" data-toggle="tab">{$name}</a></li>
};

declare function page:createContent() as node()* {
let $type := ("autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto")
for $target in $type 
    let $function := if($target != "bibliografia" and $target !="cronologia" and $target != "projeto") then 
                    <ul class="nav-cont app:list?type={$target}"></ul>
                    else ()
    let $window :=     <div class="tab-pane" id="{$target}">
                       {$function}
                       </div>
    return $window
};



(: SEARCH PAGE :)

declare function page:singleElement($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as node()* {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')
    let $lang :=  if(request:get-parameter("plang",'')!="") then request:get-parameter("plang",'') else "pt"
    return page:singleAttribute($doc,$xmltype,$xmlid,$lang)
     
};
declare function page:singleAttribute($doc as node(),$type as xs:string,$id as xs:string, $lang as xs:string) as node()? {
    let $entry := if($lang = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$lang and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$lang and @corresp=concat("#",$id)]
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
declare function page:createInput_item($xmltype as xs:string,$btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node(), $lang as xs:string) as node()* {
    for $id in $value
        let $entry := if($lang = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$lang]/tei:item[@xml:id=$id]
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$lang]/tei:item[@corresp=concat("#",$id)]
        let $input := <input type="{$btype}" name="{$name}" value="{$id}" id="{$id}"/>
        let $label := <label for="{$id}">{$entry}</label>
        return ($input,$label)
};

declare function page:createInput_term($xmltype as xs:string, $btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node(), $lang as xs:string) as node()* {
    for $id in $value
        let $entry := if($lang = "pt")
                      then $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$lang and @xml:id=$id]
                      else $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$lang and @corresp=concat("#",$id)]
        let $input := <input type="{$btype}" name="{$name}" value="{$id}" id="{$id}"/>
        let $label := <label for="{$id}">{$entry}</label>
        return ($input,$label)
};

declare function page:createOption($xmltype as xs:string, $value as xs:string*,$doc as node(),$lang as xs:string) as node()* {
    for $id in $value
         let $entry := if($lang = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$lang]/tei:item[@xml:id=$id]
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$lang]/tei:item[@corresp=concat("#",$id)]
        return <option value="{$id}">{$entry}</option>

};


