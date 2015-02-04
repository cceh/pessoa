xquery version "3.0";

module namespace author="http://localhost:8080/exist/apps/pessoa/author";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";

declare function author:getTitle($node as node(), $model as map(*), $author){
    if($author = "pessoa") then
        <h1>Fernando Pessoa</h1>
    else if($author="reis") then
        <h1>Ricardo Reis</h1>
    else if($author="caeiro") then
        <h1>Alberto Caeiro</h1>
    else if($author="campos") then
        <h1>Álvaro de Campos</h1>
    else ()
        };

declare function author:reorder($node as node(), $model as map(*),$orderBy, $textType, $author){
    author:getTabContent($node,$model,$textType,$author, $orderBy)
};

declare function author:getTabs($node as node(), $model as map(*), $textType as xs:string?, $author as xs:string?){
            if ($textType = "all") then
                    <ul id="tabs"><li class="active"><a href="{$helpers:app-root}/author/{$author}/all">Publicações e Documentos</a></li>
                    <li><a href="{$helpers:app-root}/author/{$author}/documents">Documentos</a></li>
                    <li><a href="{$helpers:app-root}/author/{$author}/publications">Publicações</a></li></ul> 
                
           else if($textType = "documents") then (
                    <ul id="tabs"><li><a href="{$helpers:app-root}/author/{$author}/all">Publicações e Documentos</a></li>
                    <li class="active"><a href="{$helpers:app-root}/author/{$author}/documents">Documentos</a></li>
                     <li><a href="{$helpers:app-root}/author/{$author}/publications">Publicações</a></li></ul> 
                ) 
           else if($textType ="publications") then(
                  <ul id="tabs"><li><a href="{$helpers:app-root}/author/{$author}/all">Publicações e Documentos</a></li>
                     <li><a href="{$helpers:app-root}/author/{$author}/documents">Documentos</a></li>
                    <li class ="active"><a href="{$helpers:app-root}/author/{$author}/publications">Publicações</a></li></ul>     
                )
           else()                   
};

declare function author:getTabContent($node as node(), $model as map(*), $textType, $author, $orderBy){
    if ($textType = "all") then
        <ul id="tab">
            <li class ="active">
                <div id="all">
                    <div>{author:listAll($node, $model, $author, $orderBy)}</div>
                </div>                           
            </li>
            <li>
                <div id="documents">
                    <div>{ author:listDocuments($node, $model, $author,$orderBy)}</div>
                </div>
            </li>
            <li>
                <div id="publications">
                     <div>{author:listPublications($node, $model, $author,$orderBy)}</div>  
                </div>
            </li>
         </ul>
   else if ($textType="documents") then               
         <ul id="tab">
            <li>
                <div id="all">
                    <div>{author:listAll($node, $model, $author, $orderBy)}</div>
                </div>
            </li>
            <li class ="active">
                <div id="documents">
                    <div>{ author:listDocuments($node, $model, $author, $orderBy)}</div>
                </div>
            </li>
            <li>
                <div id="publications">
                    <div>{author:listPublications($node, $model, $author,$orderBy)}</div>  
                </div>
            </li>
        </ul>               
    else if($textType = "publications") then
        <ul id="tab">
            <li>
                <div id="all">
                    <div>{author:listAll($node, $model, $author, $orderBy)}</div>
                </div>                      
            </li>
            <li>
                <div id="documents">
                    <div>{ author:listDocuments($node, $model, $author, $orderBy)}</div>
                </div>
            </li>
            <li class="active">
                <div id="publications">
                    <div>{author:listPublications($node, $model, $author, $orderBy)}</div>  
                </div>
            </li>
        </ul>
    else()             
};

declare function author:listAll($node as node(), $model as map(*), $author, $orderBy){
    let $texts := collection("/db/apps/pessoa/data/")
    let $docs := collection("/db/apps/pessoa/data/doc")
    let $pubs := collection("/db/apps/pessoa/data/pub")
    let $key := if($author = "pessoa") then "FP" else if($author ="reis") then "RR" else if($author ="caeiro") then "AC" else if($author="campos") then "AdC" else ()
    let $years :=  
        for $text in $docs where (($text//tei:text//tei:rs[@type="person" and @key = $key]/@role) or ($text//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:rs/@key = $key ))
            return 
            if($orderBy = "date") then fn:substring(author:orderText($text, $orderBy),0,5) else fn:substring(author:orderText($text, $orderBy),0,2)
    let $years := fn:distinct-values($years)
    for $year in $years order by $year return 
        (<div>{$year}</div>,
        (: ?????? :)
        for $text at $i in $docs 
            let $isDoc := fn:starts-with($text//(tei:teiHeader)[1]//(tei:titleStmt)[1]//(tei:title)[1]/data(.),"BNP")
            let $p := fn:index-of($pubs,$text)
            order by (author:orderText($text, $orderBy))
            return
            if(count($p) >= 1) then 
                let $order := author:orderPublication($text,$orderBy)
                let $currentYear := if($orderBy = "date") then fn:substring($order,0,5) else fn:substring($order,0,2)
                return  
                if($currentYear = $year) then       
                    author:listPublication($text,$key)
                else ()
            else if($isDoc) then 
                let $order := author:orderDocument($text,$orderBy)
                let $currentYear := if($orderBy = "date") then fn:substring($order,0,5) else fn:substring($order,0,2)
                return 
                if($currentYear = $year) then
                    author:listDocument($text,$key)
                    else ()
            else())
            
};

declare function author:listPublications($node as node(), $model as map(*), $author, $orderBy){
    let $pubs := collection("/db/apps/pessoa/data/pub/")
    let $key := if($author = "pessoa") then "FP" else if($author ="reis") then "RR" else if($author ="caeiro") then "AC" else if($author="campos") then "AdC" else ()
    let $years := 
    for $pub in $pubs where $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:rs/@key = $key 
    return if($orderBy = "date") then fn:substring(author:orderPublication($pub, $orderBy)/data(.),0,5) else fn:substring(author:orderPublication($pub, $orderBy)/data(.),0,2)
    let $years := fn:distinct-values($years)
    for $year in $years order by $year return
    (<div>{$year}</div>,
    for $pub in $pubs 
    let $order := author:orderPublication($pub, $orderBy)/data(.)
    let $currentYear := if($orderBy = "date") then fn:substring($order,0,5) else fn:substring($order,0,2)
    order by (author:orderPublication($pub, $orderBy))
    return 
        if($currentYear = $year) then   
            author:listPublication($pub,$key)
        else () )
};

declare function author:listPublication($pub, $key){
    let $title := ($pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)[1]/data(.)
    let $author := $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:rs/@key
    return  if($author = $key) then  
       (<div><a href="{$helpers:app-root}/pub/{replace(replace(replace($title," ","_"),"«",""),"»","")}">{$title}</a></div>, <br />)      
    else()
};

declare function author:orderPublication($pub, $orderBy){
    let $when := ($pub//tei:date)[1]/@when
    let $from := ($pub//tei:date)[1]/@from
    let $notBefore := ($pub//tei:date)[1]/@notBefore
    let $notAfter := ($pub//tei:date)[1]/@notAfter
    let $title :=  $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/(tei:title)[not(@*)]
    return
    if($orderBy="date") then
        if($when) then $when
            else if($from) then $from
            else if($notBefore) then $notBefore
            else if($notAfter) then $notAfter
            else ()
        else if($orderBy ="alphab") then
      $title[1]
    else()  
};

declare function author:listDocuments($node as node(), $model as map(*), $author, $orderBy){
    let $docs := collection("/db/apps/pessoa/data/doc/")
    let $key := if($author ="pessoa") then "FP" else if($author ="caeiro") then "AC" else if($author = "reis") then "RR" else if($author = "campos") then "AdC" else ()
    let $allRoles := fn:distinct-values($docs//tei:text//tei:rs[@type = 'person' and @key=$key]/@role/data(.))   
    return 
    if($orderBy="date") then
        let $years := 
        for $doc in $docs where $doc//tei:text//tei:rs[@type="person" and @key = $key]
        return if($orderBy = "date") then fn:substring(author:orderDocument($doc, $orderBy)/data(.),0,5) else fn:substring(author:orderDocument($doc, $orderBy)/data(.),0,2)
        let $years := fn:distinct-values($years)
        for $year in $years return
        (<div>{$year}</div>,
        for $doc in $docs
        let $order := author:orderDocument($doc, $orderBy)
        let $currentYear := if($orderBy = "date") then fn:substring($order,0,5) else fn:substring($order,0,2)
        order by (author:orderDocument($doc, $orderBy))
        return 
        if($currentYear = $year) then
            author:listDocument($doc, $key)
        else () )
    else if($orderBy ="alphab") then
        for $role in $allRoles 
        return <p>mencionado como {if($role="author") then "autor" else if($role ="translator") then "traductor" else if($role ="topic") then "tema" else $role}:{author:listDocumentsByRole($docs, $key, $role, $orderBy)}</p>          
    else()
};

declare function author:listDocumentsByRole($docs, $key, $role, $orderBy){
    for $doc in $docs
    order by(author:orderDocument($doc,$orderBy))
    return 
    let $roles := fn:distinct-values($doc//tei:text//tei:rs[@type = 'person' and @key=$key]/@role/data(.))
    return
    if ($doc//tei:text//tei:rs[@type ='person' and @key=$key]) then
        if(fn:index-of($roles, $role)) then
            (<div><a href="{$helpers:app-root}/doc/{replace(replace($doc//tei:idno/data(.), "/","_")," ", "_")}">{$doc//tei:idno/data(.)} </a></div>,<br/>)
        else()
    else()
};

declare function author:listDocument($doc, $key){   
    let $roles := author:getRoles($doc,$key)
    return 
    let $text := "mencionado como: "
    for $role in $roles
    let $text := fn:concat($text,if($role="author") then "autor" else if($role ="translator") then "traductor" else if($role ="topic") then "tema" else $role)
    return  
    if(count($roles) > 0) then
       
       (<div><a href="{$helpers:app-root}/doc/{replace(replace($doc//tei:idno/data(.), "/","_")," ", "_")}">{$doc//tei:idno/data(.)} </a>  ({$text})</div>, <br />)
      
    else () 
};

declare function author:orderDocument($doc, $orderBy){
    let $when := $doc//tei:origDate/@when
    let $from := $doc//tei:origDate/@from
    let $notBefore := $doc//tei:origDate/@notBefore
    let $notAfter := $doc//tei:origDate/@notAfter
    let $signature :=  author:formatDocID($doc//tei:idno/data(.))
    return 
    if($orderBy = "date") then
        if($when) then $when
        else if($from) then $from
        else if($notBefore) then $notBefore
        else if($notAfter) then $notAfter
        else ()
        else if($orderBy = "alphab") then $signature
    else() 
};

declare function author:formatDocID($id){
   let $id := $id
   return
   if(fn:contains($id,"BNP/E3 ")) then
        let $num := fn:substring-after($id,"BNP/E3 ")
        let $num := fn:tokenize($num,'[A-Z,a-z,-]')[1]
        let $length := fn:string-length($num)
        let $diff := 4-$length
        let $newNumber := fn:concat(fn:substring("0000",0,$diff),$num)
        return fn:concat("BNP/E3 ",$newNumber, fn:substring-after($id,$num))
    else $id 
};

declare function author:getRoles($doc, $key){
    let $roles := $doc//tei:text//tei:rs[@type = 'person' and @key=$key]/@role/data(.)
    let $uniqueRoles := fn:distinct-values($roles)
    return
    $uniqueRoles
};

declare function author:orderText($text, $orderBy){
    let $pub := author:orderPublication($text,$orderBy)
    let $doc := author:orderDocument($text, $orderBy)
    return if($doc) then $doc
    else if($pub) then $pub
    else ()
};