xquery version "3.0";

module namespace doc="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/doc";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace helpers="http://projects.uni-koeln.de:8080/apps/pessoa/helpers" at "helpers.xqm";

(: declare variable $ms:id := request:get-parameter("id", ()); :)

declare function doc:get-text($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $xml := doc:get-xml($id)
    let $stylesheet := doc("/db/apps/pessoa/xslt/doc.xsl")
    return transform:transform($xml, $stylesheet, ())
};
declare function doc:get-genre($node as node(), $model as map(*), $type as xs:string) as item()*{    
    let $docs := collection("/db/apps/pessoa/data")    
    return for $doc in $docs
           return if($doc//tei:rs[@key=$type]) 
                  then
                    if ($doc//tei:sourceDesc/tei:msDesc)
                    then ( <a href="{$helpers:app-root}/doc/{replace(replace($doc//tei:idno/data(.), "/","_")," ", "_")}">{ $doc//tei:idno/data(.)}</a>,<br />)                              
                    else (<a href="{$helpers:app-root}/{substring-before(substring-after(document-uri($doc),"/db/apps/pessoa/data"),".xml")}">{$doc//tei:sourceDesc/tei:biblStruct[1]/tei:analytic/tei:title[1]/data(.)}</a>,<br />)
                  else ( )
};
declare function doc:get-image($node as node(), $model as map(*), $id as xs:string) as item()+{
    let $file-names := doc:get-xml($id)//tei:graphic/@url/data(.)
    return for $file-name in $file-names
           return <a class="fancybox" rel="group" href="{$helpers:webfile-path}/{$file-name}"><img src="{$helpers:webfile-path}/{$file-name}" alt="img" width="350" height="auto" /></a>
};


declare function doc:get-year($node as node(), $model as map(*), $year as xs:string)as item()*{
    let $docs := collection("/db/apps/pessoa/data")    
    return for $doc in $docs
        return if($doc//tei:origDate[@when])
            then 
                if($doc//tei:origDate[@when=$year])
                then (<a href="{$helpers:app-root}/doc/{replace(replace($doc//tei:idno/data(.), "/","_")," ", "_")}">{ $doc//tei:idno/data(.)}</a>,<br />)
                else ()
          
   
           else ()
                
};

declare function doc:get-xml($id){
    let $file-name := concat($id, ".xml")
    return doc(concat("/db/apps/pessoa/data/doc/", $file-name)) 
};

