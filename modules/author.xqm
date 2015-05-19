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
    else if($textType = "documents") then 
        <ul id="tabs"><li><a href="{$helpers:app-root}/author/{$author}/all">Publicações e Documentos</a></li>
        <li class="active"><a href="{$helpers:app-root}/author/{$author}/documents">Documentos</a></li>
        <li><a href="{$helpers:app-root}/author/{$author}/publications">Publicações</a></li></ul> 
    else if($textType ="publications") then
        <ul id="tabs"><li><a href="{$helpers:app-root}/author/{$author}/all">Publicações e Documentos</a></li>
        <li><a href="{$helpers:app-root}/author/{$author}/documents">Documentos</a></li>
        <li class ="active"><a href="{$helpers:app-root}/author/{$author}/publications">Publicações</a></li></ul>         
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
                    <div>{author:listDocuments($node, $model, $author, $orderBy)}</div>
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
    let $docs := collection("/db/apps/pessoa/data/doc/")  
    let $pubs := collection("/db/apps/pessoa/data/pub/")  
    let $texts := fn:insert-before($docs,0,$pubs)  
    return   
    let $authorKey := if($author = "pessoa") then "FP" else if($author ="reis") then "RR" else if($author ="caeiro") then "AC" else if($author="campos") then "AdC" else ()
    let $texts := 
        for $text in $texts where((fn:index-of($pubs,$text) > 0) and ($text//tei:author/tei:rs/@key =$authorKey)or ($text//tei:text//tei:rs[@type="person" and @key = $authorKey]/@role)) return $text
    let $i := if($orderBy ="alphab") then 2 else 5
    let $years := for $text in $texts return fn:substring(author:getYearOrTitle($text,$orderBy),0,$i)
    let $years := fn:distinct-values($years)
    return (author:getNavigation($years),
    for $year in $years
        let $textsInYear :=
            for $text in $texts where (fn:substring(author:getYearOrTitle($text,$orderBy),0,$i) = $year) return $text  
    order by $year
    return
        (<div id="{$year}"><h2>{$year }</h2></div>,       
         for $text in $textsInYear order by (author:getYearOrTitle($text,$orderBy))return           
            if((fn:starts-with($text//(tei:teiHeader)[1]//(tei:titleStmt)[1]//(tei:title)[1]/data(.),"BNP")) or (fn:starts-with($text//(tei:teiHeader)[1]//(tei:titleStmt)[1]//(tei:title)[1]/data(.),"MN") )) then          
                <div>{author:listDocumentByYear($text,$authorKey)}</div>    
            else (<div>{author:listPublication($text,$authorKey)}</div>)          
        )  
        )
};

declare function author:getNavigation($years){
    let $years := for $year in $years order by $year return $year
    return
    <div> 
        {for $year at $i in $years
        order by $year
            return if ($i = count($years)) then
                <a href="#{$year}">{$year}</a>
                else
                (<a href="#{$year}">{$year}</a>,<span>|</span>)
        } 
        <br/>
        <br/>
    </div>
};

declare function author:listPublications($node as node(), $model as map(*), $author, $orderBy){
    let $i := if($orderBy ="alphab") then 2 else 5
    let $pubs := collection("/db/apps/pessoa/data/pub")
    let $authorKey := if($author = "pessoa") then "FP" else if($author ="reis") then "RR" else if($author ="caeiro") then "AC" else if($author="campos") then "AdC" else ()
    let $pubs :=
        for $pub in $pubs where ($pub//tei:author/tei:rs/@key =$authorKey)
        return $pub
    let $years := 
        for $pub in $pubs return fn:substring(author:getYearOrTitleOfPublication($pub,$orderBy),0,$i)   
    
    let $years := fn:distinct-values($years)
    return (author:getNavigation($years),
    for $year in $years 
        let $pubsInYear :=
            for $pub in $pubs where (fn:substring(author:getYearOrTitleOfPublication($pub,$orderBy),0,$i) = $year ) return $pub
    order by $year 
    return (<div><h2>{$year}</h2></div>,
            for $pub in $pubsInYear order by (author:getYearOrTitleOfPublication($pub,$orderBy))return
            author:listPublication($pub,$authorKey))    
            )
};

declare function author:listPublication($pub, $authorKey){
    let $title := ($pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)[1]/data(.)
    let $author := $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:rs/@key
    return  if($author = $authorKey) then  
       (<div><a href="{$helpers:app-root}/pub/{replace(replace(replace($title," ","_"),"«",""),"»","")}">{$title}</a></div>, <br />)      
      
    else()
};

declare function author:getYearOrTitleOfPublication($pub, $orderBy){
    let $when := ($pub//tei:date)[1]/@when/data(.)
    let $from := ($pub//tei:date)[1]/@from/data(.)
    let $notBefore := ($pub//tei:date)[1]/@notBefore/data(.)
    let $notAfter := ($pub//tei:date)[1]/@notAfter/data(.)
    let $title :=  $pub//tei:teiHeader/tei:fileDesc/tei:titleStmt/(tei:title)[not(@*)]
    return
    if($orderBy="date") then
        if($when) then $when
            else if($from) then $from
            else if($notBefore) then $notBefore
            else if($notAfter) then $notAfter
            else ()
        else if($orderBy ="alphab") then
      $title[1]/data(.)
    else()  
};

declare function author:listDocuments($node as node(), $model as map(*), $author, $orderBy){
    let $i := if($orderBy ="alphab") then 2 else 5
    let $docs := collection("/db/apps/pessoa/data/doc/")
    let $authorKey := if($author ="pessoa") then "FP" else if($author ="caeiro") then "AC" else if($author = "reis") then "RR" else if($author = "campos") then "AdC" else ()
    let $docs :=
        for $doc in $docs where ($doc//tei:text//tei:rs[@type="person" and @key = $authorKey]/@role) return $doc
    let $years := 
        for $doc in $docs return fn:substring(author:getYearOrTitleOfDocument($doc,$orderBy),0, $i)
    let $years := fn:distinct-values($years)
    return 
        if($orderBy ="date") then
        (author:getNavigation($years),
            for $year in $years
                let $docsInYear := 
                    for $doc in $docs where (fn:substring(author:getYearOrTitleOfDocument($doc,$orderBy),0,$i) = $year ) return $doc
            order by $year 
            return (<div><h2>{$year}</h2></div>,
                    for $doc in $docsInYear order by author:getYearOrTitleOfDocument($doc,"date") return author:listDocumentByYear($doc,$authorKey))
                    )
        else 
            let $roles := fn:distinct-values($docs//tei:text//tei:rs[@type = 'person' and @key=$authorKey]/@role/data(.)) 
            return(author:getNavigation($roles),
            for $role in $roles return
                <p><h2>mencionado como {if($role="author") then "autor" else if($role ="translator") then "traductor" else if($role ="topic") then "tema" else $role}:</h2>{author:listDocumentsByRole($docs, $authorKey, $role, $orderBy)}</p>       
            )
};


declare function author:listDocumentsByRole($docs, $authorKey, $role, $orderBy){
    for $doc in $docs
    order by(author:getYearOrTitleOfDocument($doc,$orderBy))
    return 
    let $roles := fn:distinct-values($doc//tei:text//tei:rs[@type = 'person' and @key=$authorKey]/@role/data(.))
    return
    if ($doc//tei:text//tei:rs[@type ='person' and @key=$authorKey]) then
        if(fn:index-of($roles, $role)) then
            (<div><a href="{$helpers:app-root}/doc/{substring-before(replace(replace(($doc//tei:idno)[1]/data(.), "/","_")," ", "_"),".xml")}">{($doc//tei:title)[1]/data(.)} </a></div>,<br/>)
        else()
    else()
};

declare function author:listDocumentByYear($doc, $authorKey){ 
    let $roles := author:getRoles($doc,$authorKey)
    let $rolesNum := fn:count($roles)
    let $text := " "
    let $text := 
        for $role at $i in $roles
        return
        if($i < $rolesNum) then
        fn:concat($text,if($role="author") then "autor, " else if($role ="translator") then "traductor, " else if($role ="topic") then "tema, " else "editor, ")
        else
        fn:concat($text,if($role="author") then "autor" else if($role ="translator") then "traductor" else if($role ="topic") then "tema" else "editor")
       (: if($i > 1) then 
        fn:concat($text,if($role="author") then ", autor" else if($role ="translator") then ", traductor" else if($role ="topic") then ", tema" else ", editor" )
        else
        fn:concat($text,if($role="author") then "autor" else if($role ="translator") then "traductor" else if($role ="topic") then "tema" else "editor" )
        :)
   return  
    if(count($roles) > 0) then    
       (<div><a href="{$helpers:app-root}/doc/{substring-before(replace(replace(($doc//tei:idno)[1]/data(.), "/","_")," ", "_"),".xml")}">{($doc//tei:title)[1]/data(.)} </a>  <span class="mencionadoComo"> (mencionado como:{$text})</span></div>, <br />)    
    else ()
  
};

declare function author:getYearOrTitleOfDocument($doc, $orderBy){
    let $when := $doc//tei:origDate/@when/data(.)
    let $from := $doc//tei:origDate/@from/data(.)
    let $notBefore := $doc//tei:origDate/@notBefore/data(.)
    let $notAfter := $doc//tei:origDate/@notAfter/data(.)
    let $signature :=  author:formatDocID(($doc//tei:idno)[1]/data(.))
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
   if(fn:contains($id,"BNP_E3_")) then
        let $numPart := fn:substring-after($id,"BNP_E3_")
        let $numPart := fn:tokenize($numPart,'[A-Z,a-z,-]')[1]
        let $length := fn:string-length($numPart)
        let $diff := 4-$length
        let $newNumber := fn:concat(fn:substring("0000",0,$diff),$numPart)
        return fn:concat("BNP_E3_",$newNumber, fn:substring-after($id,$numPart))
    else if(fn:starts-with($id,"MN")) then
        let $numPart := if (fn:contains($id,"-")) then fn:substring-after(fn:substring-before($id,"-"),"MN") else fn:substring-after(fn:substring-before($id,".xml"),"MN")
        let $length := fn:string-length($numPart)
        let $diff := 4-$length
        let $newNumber := fn:concat(fn:substring("0000",0,$diff),$numPart)
        return fn:concat("MN",$newNumber, fn:substring-after($id,$numPart))
    else $id 
};

declare function author:getRoles($doc, $authorKey){
    let $roles := $doc//tei:text//tei:rs[@type = 'person' and @key=$authorKey]/@role/data(.)
    let $uniqueRoles := fn:distinct-values($roles)
    return
    $uniqueRoles
};

declare function author:getYearOrTitle($text, $orderBy){
    let $pub := author:getYearOrTitleOfPublication($text,$orderBy)
    let $doc := author:getYearOrTitleOfDocument($text, $orderBy)
    return if($pub) then $pub
    else if($doc) then $doc
    else ()
};

declare function author:getrecorder($node as node(), $model as map(*)){
let $script := <script type="text/javascript">
        
        function reorder(){{
        var url = window.location.href;
        var i = url.lastIndexOf("/");
        var substr = url.substring(0,i);
        i = substr.lastIndexOf("/");
        var author = substr.substring(i+1,substr.length);
        var textType = url.substring(url.lastIndexOf("/")+1,url.length);
        if ($("#date").is(":checked"))
        {{
        $("#tab").load("http://localhost:8080/exist/apps/pessoa/{$helpers:web-language}/page/author/"+author+"/"+textType+"?orderBy=date");
        
        }}
        else{{
        $("#tab").load("http://localhost:8080/exist/apps/pessoa/{$helpers:web-language}/page/author/"+author+"/"+textType+"?orderBy=alphab"); 
        }}
        }}
    </script> 
    return $script
};