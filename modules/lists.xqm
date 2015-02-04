xquery version "3.0";

module namespace lists="http://localhost:8080/exist/apps/pessoa/lists";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
declare namespace ngram ="http://exist-db.org/xquery/ngram";

declare function lists:get-navi-list($node as node(), $model as map(*), $type as text(), $indikator as xs:string?) as item()*{
    if ($type = "autores")
    then for $pers in doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person/tei:persName/data(.)
         order by $pers collation "?lang=pt"
         return <item label="{$pers}" ref="{$helpers:app-root}/author/{tokenize(lower-case($pers), '\s')[last()]}/all" />
    else if ($type = "genero")
    then for $genre in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="genres"][@n="2"]/tei:item   
        let $label :=$genre/data(.)
        let $ref := $genre/attribute() 
         order by $genre collation "?lang=pt" 
         return <item label="{$label}"  ref="{$helpers:app-root}/page/genre_{$ref}.html" />      
    else if ($type = "documentos")
    then for $res in xmldb:get-child-resources("/db/apps/pessoa/data/doc")
         let $label := if(substring-after($res, "BNP") != "") then substring-after(replace(substring-before($res, ".xml"), "_", " "), "BNP E3 ")
                        else if(substring-after($res,"X") != "") then substring-after(replace(substring-before($res, ".xml"), "_", " "), "X")
                        else ()
         
         let $ref := concat($helpers:app-root, "/doc/", substring-before($res, ".xml"))         
         order by $res collation "?lang=pt" 
         return if(doc(concat("/db/apps/pessoa/data/doc/",$res))//tei:sourceDesc/tei:msDesc and (substring-after($res,concat("E3_",$indikator))!="" ) or (substring-after($res,concat("X_",$indikator))!="" ))
                then (<item label="{$label}" ref="{$ref}?plang={$helpers:web-language}"  />) else()
    else if ($type = "publicacoes")
    then for $res in xmldb:get-child-resources("/db/apps/pessoa/data/pub")
        let $label := doc(concat("/db/apps/pessoa/data/pub/",$res))/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]
        let $ref := concat($helpers:app-root, "/pub/", substring-before($res, ".xml"))  
        order by $label collation "?lang=pt" 
        return <item label="{$label}" ref="{$ref}?plang={$helpers:web-language}"></item>
        (:for $item in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="works"][@n="2"]/tei:item
         let $ref := concat($helpers:app-root, "/pub/", lists:get-doc-uri($item))
         order by $item/tei:title
         return <item label="{$item/tei:title}" ref="{$ref}">
                    {if ($item/tei:list)
                    then lists:get-sub-list($node, $model, $item)
                    else ()}
                </item> :)
    else if($type ="cronologia")
    then for $years in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="years"]/tei:item 
         order by $years collation "?lang=pt"
        return if ( ends-with($years, $indikator)
        (:substring-before($years,concat("0",$indikator))!="" or substring-before($years,concat("1",$indikator))!="" or substring-before($years,concat("2",$indikator))!="" or substring-before($years,concat("3",$indikator))!="" :) )
            then <item label="{$years}" ref="{$helpers:app-root}/page/year_{$years}.html" id="{$years}"/>              
         else ()
    else for $item in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type=$type]/tei:item/data(.)
         order by $item collation "?lang=pt"         
         return <item label="{$item}" ref="#" />
};

declare function lists:get-sub-list($node as node(), $model as map(*), $item as node()){
    for $subitem in $item/tei:list/tei:item
    let $ref := lists:get-doc-uri($subitem)
    return <item label="{$subitem/tei:title}" ref="{$ref}">
              {if ($subitem/tei:list) then lists:get-sub-list($node, $model, $subitem) else()}
           </item>
};

declare function lists:get-doc-uri($item){
    if (collection("/db/apps/pessoa/data/doc")//tei:titleStmt/tei:title[normalize-space(.) = normalize-space($item/tei:title)])
    then substring-before(util:document-name(root(collection("/db/apps/pessoa/data/doc")//tei:titleStmt/tei:title[. = $item/tei:title])), ".xml")
    else "#"
};