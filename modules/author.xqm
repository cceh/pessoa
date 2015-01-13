xquery version "3.0";

module namespace author="http://localhost:8080/exist/apps/pessoa/author";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";


declare function author:getTabs($node as node(), $model as map(*), $textType){
    let $textType := $textType
    return if ($textType = "all") then (
                   <ul id="tabs"><li class="active"><a href="#all">Publicações e Documentos</a> </li>
                    <li><a href="#documents">Documentos</a></li>
                    <li><a href="#publications">Publicações</a></li></ul> 
                )
           else if($textType = "documents") then (
                    <ul id="tabs"><li><a href="#all">Publicações e Documentos</a> </li>
                    <li class="active"><a href="#documents">Documentos</a></li>
                    <li><a href="#publications">Publicações</a></li></ul> 
                ) 
           else if($textType ="publications") then(
                  <ul id="tabs"><li><a href="#all">Publicações e Documentos</a> </li>
                    <li><a href="#documents">Documentos</a></li>
                    <li class ="active"><a href="#publications">Publicações</a></li></ul>    
                )
                else()
                    
};

declare function author:list-texts($node as node(), $model as map(*), $textType, $author, $orderBy){
    let $textType := $textType
    return if ($textType = "all") then
                    <ul id="tab">
                        <li class ="active">
                            <div id="all">
                                <div>{author:list-all($node, $model, $author)}</div>
                            </div>
                            
                        </li>
                        <li>
                            <div id="documents">
                                <div>{ author:list-documents($node, $model, $author, $orderBy)}</div>
                            </div>
                        </li>
                        <li>
                            <div id="publications">
                                <div>{author:list-publications($node, $model, $author,$orderBy)}</div>  
                            </div>
                        </li>
                    </ul>
                    else if ($textType="documents") then
                    <ul id="tab">
                        <li>
                            <div id="all">
                                <div>{author:list-all($node, $model, $author)}</div>
                            </div>
                            
                        </li>
                        <li class="active">
                            <div id="documents">
                                <div>{ author:list-documents($node, $model, $author, $orderBy)}</div>
                            </div>
                        </li>
                        <li>
                            <div id="publications">
                                <div>{author:list-publications($node, $model, $author, $orderBy)}</div>  
                            </div>
                        </li>
                    </ul>
                    else if($textType = "publications") then
                     <ul id="tab">
                        <li>
                            <div id="all">
                                <div>{author:list-all($node, $model, $author)}</div>
                            </div>
                            
                        </li>
                        <li>
                            <div id="documents">
                                <div>{ author:list-documents($node, $model, $author, $orderBy)}</div>
                            </div>
                        </li>
                        <li class="active">
                            <div id="publications">
                                <div>{author:list-publications($node, $model, $author, $orderBy)}</div>  
                            </div>
                        </li>
                    </ul>
                    else()
                    
};


declare function author:list-publications($node as node(), $model as map(*), $author, $orderBy){
    let $pubs := collection("/db/apps/pessoa/data/pub/")
    for $pub in $pubs 
    order by (author:orderPublication($pub, $orderBy))
    return
    if($author ="pessoa") then
        author:list-publication($pub,"FP")
    else if ($author = "caeiro") then
        author:list-publication($pub,"AC")
    else if ($author = "campos") then
            author:list-publication($pub,"AdC")
    else if ($author ="reis") then author:list-publication($pub,"RR")
    else(<div>kein Autor</div>)
};



declare function author:list-documents($node as node(), $model as map(*), $author, $orderBy){
    let $docs := collection("/db/apps/pessoa/data/doc/")
    let $key := if($author ="pessoa") then "FP" else if($author ="caeiro") then "AC" else if($author = "reis") then "RR" else if($author = "campo") then "AdC" else ()
    let $allRoles := fn:distinct-values($docs//tei:text//tei:rs[@type = 'person' and @key=$key]/@role/data(.))
        return if($orderBy="date") then
            for $doc in $docs
            order by (author:orderDocument($doc, $orderBy))
            return author:list-document($doc,$key)
            
        else if($orderBy ="alphab") then
        for $role in $allRoles return 
            <p>{$role}{author:list-documents-byRole($docs, $key, $role)}</p>
        else()

};

declare function author:list-documents-byRole($docs, $key, $role){
    for $doc in $docs return 
    let $roles := fn:distinct-values($doc//tei:text//tei:rs[@type = 'person' and @key=$key]/@role/data(.))
    return
    if ($doc//tei:text//tei:rs[@type ='person' and @key=$key]) then
        if(fn:index-of($roles, $role)) then
        author:list-document($doc,$key)
        else()
    else()
};

declare function author:list-all($node as node(), $model as map(*), $author){
    let $texts := collection("/db/apps/pessoa/data/")
    for $text in $texts
    order by (author:orderText($text))
    return 
    if($author = "pessoa") then
            if(author:list-document($text,"FP")) then
                author:list-document($text,"FP")
            else if(author:list-publication($text,"FP")) then
                author:list-publication($text,"FP")
            else ()
     else if( $author ="caeiro") then  
            if(author:list-document($text,"AC")) then
                author:list-document($text,"AC")
            else if(author:list-publication($text,"AC")) then
                author:list-publication($text,"AC")
            else ()
     else if($author = "campos") then
            if(author:list-document($text,"AdC")) then
                author:list-document($text,"AdC")
            else if(author:list-publication($text,"AdC")) then
                author:list-publication($text,"AdC")
            else ()
     else if ($author = "reis") then
            if(author:list-document($text,"RR")) then
                author:list-document($text,"RR")
            else if(author:list-publication($text,"RR")) then
                author:list-publication($text,"RR")
            else ()
     else()
    
};

declare function author:orderDocument($doc, $orderBy){
    let $when := $doc//tei:origDate/@when
    let $from := $doc//tei:origDate/@from
    let $notBefore := $doc//tei:origDate/@notBefore
    let $notAfter := $doc//tei:origDate/@notAfter
    let $signature :=  $doc//tei:idno/data(.)
    return if($orderBy = "date") then
    if($when) then $when
     else if($from) then $from
        else if($notBefore) then $notBefore
        else if($notAfter) then $notAfter
        else ()
    else if($orderBy = "alphab") then
     ()
    else()
    
};

declare function author:list-document($doc, $key){
    let $doc := $doc
    let $roles := author:getRoles($doc,$key)
return 
if($doc//tei:text//tei:rs[@type ='person' and @key=$key]) then
       (<div><a href="{$helpers:app-root}/doc/{replace(replace($doc//tei:idno/data(.), "/","_")," ", "_")}">{ $doc//tei:idno/data(.)} </a>  ({$roles})</div>, <br />)
       else () 
};



declare function author:getRoles($doc, $key){
    let $roles := $doc//tei:text//tei:rs[@type = 'person' and @key=$key]/@role/data(.)
    let $uniqueRoles := fn:distinct-values($roles)
    return 
    $uniqueRoles
};



declare function author:orderText($text){
    let $docDate := author:orderDocument($text, "date")
    let $pubDate := author:orderPublication($text,"date")
    return if($docDate) then $docDate/data(.)
    else if($pubDate) then $pubDate/data(.)
    else ()
};

declare function author:list-publication($pub, $key){
    let $title := ($pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)[1]/data(.)
    let $author := $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:rs/@key
    return  if($author = $key) then
       ( <div><a href="{$helpers:app-root}/pub/{replace(replace(replace($title," ","_"),"«",""),"»","")}">{$title}</a></div>, <br />)
        else()
};

declare function author:orderPublication($pub, $orderBy){
    let $when := ($pub//tei:date)[1]/@when
    let $from := ($pub//tei:date)[1]/@from
    let $notBefore := ($pub//tei:date)[1]/@notBefore
    let $notAfter := ($pub//tei:date)[1]/@notAfter
    let $title :=  $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/(tei:title)[not(@*)]/data(.)
    return
    if($orderBy="date") then
        if($when) then $when
        else if($from) then $from
        else if($notBefore) then $notBefore
        else if($notAfter) then $notAfter
        else ()
    else if($orderBy ="alphab") then
        ($pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)[1]/data(.)
    else()  
};





