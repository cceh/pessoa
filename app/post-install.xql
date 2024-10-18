xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace functx = "http://www.functx.com";

declare function local:mkcol-recursive($base, $path) {
  if (exists($base) and exists($path)) then (
    if (not(xmldb:collection-available(concat($base, $path[1])))) then (
      xmldb:create-collection($base, $path[1])
    ) else (),
    local:mkcol-recursive(concat($base, "/", $path[1]), subsequence($path, 2))
  ) else ()
};

declare function local:mkcol($collection) {
  let $path := tokenize($collection, "/")
  return local:mkcol-recursive($path[1], subsequence($path, 2))
};

(: move search index to system and reindex :)
declare function local:move-index(){
	let $app-path := "/db/apps/pessoa"
	let $conf-path := "/db/system/config/db/apps/pessoa/data"
	return
    	(
    	local:mkcol(concat($app-path, "/data/doc")),
    	local:mkcol(concat($app-path, "/data/pub")),
    	local:mkcol(concat($conf-path, "/doc")),
    	local:mkcol(concat($conf-path, "/pub")),

    	if (file:exists(concat($app-path, "collection_doc.xconf"))) then (
    		xmldb:move($app-path, concat($conf-path, "/doc"), "collection_doc.xconf"),
    		xmldb:rename(concat($conf-path, "/doc"), "collection_doc.xconf", "collection.xconf")
    	) else (),

    	if (file:exists(concat($app-path, "collection_pub.xconf"))) then (
    		xmldb:move($app-path, concat($conf-path, "/pub"), "collection_pub.xconf"),
    		xmldb:rename(concat($conf-path, "/pub"), "collection_pub.xconf", "collection.xconf")
    	) else (),

    	xmldb:reindex(concat($app-path, "/data/doc")),
    	xmldb:reindex(concat($app-path, "/data/pub"))
	)
};

declare function local:createXML() {
    let $docs := local:createDocXML()
    let $Sdocs := count($docs)
    let $docs := <docs dir="doc">
                    {for $a in (1 to $Sdocs)
                        let $doc := doc(concat("/db/apps/pessoa/data/doc/",$docs[$a]/@label/data(.)))
                        let $date := $doc//tei:origDate
                        return <doc from="{local:getDateDoc("from",$date)}" to="{local:getDateDoc("to",$date)}" availability="{$doc//tei:availability/@status}" pos="{$a}" indi="{$docs[$a]/@indi/data(.)}" id="{substring-before($docs[$a]/@label/data(.),".xml")}" >{$docs[$a]/@label/data(.)}</doc>}
                </docs>
    let $pub := local:createPubXML()
    let $Spub := count($pub)
    let $pub := <docs dir="pub">
                    {for $a in (1 to $Spub)
                    let $doc := doc(concat("/db/apps/pessoa/data/pub/",$pub[$a]/@label/data(.)))
                    let $date := $doc//tei:imprint/tei:date
                        return <doc from="{local:getDateDoc("from",$date)}" to="{local:getDateDoc("to",$date)}" availability="{$doc//tei:availability/@status}" pos="{$a}" indi="{$pub[$a]/@indi/data(.)}" id="{substring-before($pub[$a]/@label/data(.),".xml")}">{$pub[$a]/@label/data(.)}</doc>}
                </docs>
    let $input := <list>
                    <meta>
                        <sum id="doc">{$Sdocs}</sum>
                        <sum id="pub">{$Spub}</sum>
                    </meta>
                    {$pub}
                    {$docs}
                  </list>
    let $input := $input
    return xmldb:store("/db/apps/pessoa/data", "doclist.xml", $input)
};


declare function local:getDateDoc($set,$doc) {
    let $tags := ("when","notBefore","notAfter","from","to")
    let $date := for $tag in $tags
                   return switch($tag)
                            case "when" return $doc/@when
                            case "notBefore" return $doc/@notBefore
                            case "notAfter" return $doc/@notAfter
                            case "from" return $doc/@from
                            case "to" return $doc/@to
                            default return "Error"

    let $date := for $d in $date return if(contains($d,"-")) then substring-before($d,"-") else $d

    let $date := for $d in $date order by $d return $d
    let $date := if(count($date) != 0) then $date  else (99,99)
    return if($set = "from") then $date[1] else $date[count($date)]
};

declare function local:createPubXML() {
  let $items := for $indikator in ("Pessoa","Caeiro","Campos","Reis","Soares") return local:pubItems($indikator)
  let $items := for $item in $items order by local:anaIndi($item/@indi/data(.)),$item/@label/data(.)
                        return <item label="{$item/@label/data(.)}"  indi="{local:getAuthorShort($item/@indi/data(.))}"/>
  return $items
};


declare function local:getAuthorShort($indi as xs:string) {
    switch($indi)
        case "Pessoa" return "FP"
        case "Caeiro" return "AC"
        case "Campos" return "AdC"
        case "Reis" return "RR"
        case "Soares" return "BS"
        default return "UH"
};

declare function local:pubItems($indikator) {
    for $hit in xmldb:get-child-resources("/db/apps/pessoa/data/pub") 
    where contains($hit,$indikator)
    return <item label="{$hit}" indi="{$indikator}"/>
};

declare function local:createDocXML() {
let $items := for $indikator in ("1-9", "10","20","30","40","50","60","70","80","90","100","600","700","CP")  return local:docItems($indikator)
let $items := for $item in $items 
                    let $title := substring-before(replace($item/@label,("BNP_E3_|CP"),""),".xml")
                     let $front := if(contains($title,"-")) then substring-before($title,"-") else $title
                     let $end := xs:string(xs:integer(replace($title, "^\d+[A-Z]?\d?-?([0-9]+).*$", "$1")))
                     let $end := substring-after($title,$end)
                    order by local:anaIndi($item/@indi/data(.)),$front, xs:integer(replace($title, "^\d+[A-Z]?\d?-?([0-9]+).*$", "$1")),$end 
                    return <item label="{$item/@label/data(.)}"  indi="{$item/@indi/data(.)}"/>
return $items
};


declare function local:anaIndi($indi) {
    if($indi = "1-9" or $indi = "Pessoa") then 1
    else if($indi = "10" or $indi = "Caeiro" ) then 2
    else if($indi = "20" or $indi = "Campos") then 3
    else if($indi = "30" or $indi = "Reis") then 4
    else if($indi = "40" or $indi = "Soares") then 5
    else if($indi = "50") then 6
    else if($indi = "60") then 7
    else if($indi = "70") then 8
    else if($indi = "80") then 9
    else if($indi = "90") then 10
    else if($indi = "100") then 11
    else if($indi = "CP") then 12
    else "Wrong"
};

declare function local:docItems($indikator) {
    for $hit in collection("/db/apps/pessoa/data/doc")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="filename"]/data(.)
    let $label := if(substring-after($hit, "BNP_E3_") != "") then substring-after(replace(substring-before($hit, ".xml"), "_", " "), "BNP E3 ")
                  else if(substring-after($hit,"CP") != "") then  substring-after(substring-before($hit, ".xml"),"CP")
                  else ()
    let $title :=  $hit 
      return if( $indikator !="1-9" 
                        and local:getCorrectDoc($label, $indikator) = xs:boolean("true") 
                        and $indikator != "CP" and contains($hit,"BNP")) 
                            then <item label="{$title}" indi="{$indikator}"/>
                    else if ($indikator = "CP" and contains($hit,"CP")) 
                            then <item label="{$title}" indi="{$indikator}"/>
                    else if($indikator = "1-9" and local:getCorretDoc_alphabetical($label,2) = xs:boolean("true")) 
                            then <item label="{$title}" indi="{$indikator}"/>
                    else ()
                    };


declare function local:getCorrectDoc($label as xs:string, $indi as xs:string) as xs:boolean+ {
    if(contains(substring($label,1,1),substring($indi,1,1)) ) then
        let $c_label := if( contains($label,"-") ) 
            then substring-before($label,"-") 
            else $label
        for $pos in ( 1 to string-length($c_label))
            return if (local:getCorretDoc_alphabetical($c_label,$pos) = xs:boolean("true") or $pos = string-length($c_label)) 
                   then local:getCorrectDoc_Step2($label,$indi,$pos) else xs:boolean("false")
                   else xs:boolean("false")
};


declare function local:getCorrectDoc_Step2($c_label as xs:string, $indi as xs:string,$pos as xs:integer) as xs:boolean{
    if( ($pos = 2  or $pos = 3) 
            and string-length($indi) = 2 
            and local:getCorrectDoc_nummeric($c_label,2) = xs:boolean("true") 
            and not( local:getCorrectDoc_nummeric($c_label,3) = xs:boolean("true"))) 
                then xs:boolean("true") 
    else if ( ($pos = 3 or $pos = 4) 
                    and string-length($indi) = 3 
                    and local:getCorrectDoc_nummeric($c_label,3) = xs:boolean("true")) 
                        then xs:boolean("true") 
    else if( ($pos = 3 or $pos = 2 or $pos = 1) 
                and string-length($indi) = 1 
                and (  local:getCorretDoc_alphabetical($c_label,$pos)  = xs:boolean("true") 
                or   local:getCorretDoc_alphabetical($c_label,2)  = xs:boolean("true") 
                or   local:getCorretDoc_alphabetical($c_label,3)  = xs:boolean("true")) ) 
                    then xs:boolean("true")
    else xs:boolean("false")
};


declare function local:getCorretDoc_alphabetical($label as xs:string, $pos as xs:integer) as xs:boolean? {
    for $cut in ( "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y" ,"z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y" ,"Z","-") 
    return if (contains(substring($label,$pos,1),xs:string($cut) )) then xs:boolean("true") else ()

};

declare function  local:getCorrectDoc_nummeric($label as xs:string, $pos as xs:integer) as xs:boolean? {
    for $cut in (0 to 9)
    return if (contains(substring($label, $pos, 1),xs:string($cut))) then xs:boolean("true") else  ()
};

declare function local:FindFirstLetter-new($text as xs:string, $pos as xs:integer) {
    if(matches(substring($text,$pos,1),'[A-z\d]')) then substring($text,$pos,1)
    else if ($pos > string-length($text)) then concat("Error/",$pos)
    else local:FindFirstLetter-new($text,$pos +1)
};

declare function local:scanDocs($text, $aDocs) {
            (: let $docs := for $doc in $aDocs where $doc/@name eq $text  return <item link="{$doc/@ref/data(.)}" title="{$doc/@title/data(.)}"/>
             let $docs := for $a in (1 to count($docs)) let $coma := if($a != count($docs)) then "yes" else "no" return <item link="{$docs[$a]/@link/data(.)}" title="{$docs[$a]/@title/data(.)}" coma="{$coma}"/>
             return $docs:)
             for $doc in $aDocs where $doc/@name eq $text  return $doc/@ref/data(.)
};


declare function local:get-titles(){
 (: all the titles of publications and titles mentioned in
 : documents and publications are collected and saved as a list,
 : which is used as a basis for the title index :)
    (: get all the titles :)
    let $titles-doc-rs := collection('/db/apps/pessoa/data/doc')//tei:rs[@type="title"]
    let $titles-pub-rs := collection('/db/apps/pessoa/data/pub')//tei:rs[@type="title"]
    let $titles-pub := collection('/db/apps/pessoa/data/pub')//tei:title[@level="a"]
    (: create an XML file with a list of all the titles :)
    let $title-xsl := doc("/db/apps/pessoa/xslt/title.xsl")
    let $title-xml := <list>
        {for $t in $titles-doc-rs
        let $clean-t := transform:transform($t, $title-xsl, ())
        return <entry>
            <type>doc</type>
            <title>{$clean-t/normalize-space(.)}</title>
            <parentName>{$t/ancestor::tei:TEI//tei:titleStmt/tei:title/normalize-space(.)}</parentName>
            <parentLink>{$t/ancestor::tei:TEI//tei:idno[@type="filename"]/data(.)}</parentLink>
        </entry>}
        {for $t in $titles-pub-rs
        let $clean-t := transform:transform($t, $title-xsl, ())
        return <entry>
            <type>pub</type>
            <title>{$clean-t/normalize-space(.)}</title>
            <parentName>{$t/ancestor::tei:TEI//tei:titleStmt/tei:title/normalize-space(.)}</parentName>
            <parentLink>{$t/ancestor::tei:TEI//tei:idno[@type="filename"]/data(.)}</parentLink>
        </entry>}
        {for $t in $titles-pub
        let $clean-t := transform:transform($t, $title-xsl, ())
        return <entry>
            <type>pub</type>
            <title>{$clean-t/normalize-space(.)}</title>
            <parentName>{$t/ancestor::tei:TEI//tei:titleStmt/tei:title/normalize-space(.)}</parentName>
            <parentLink>{$t/ancestor::tei:TEI//tei:idno[@type="filename"]/data(.)}</parentLink>
        </entry>}
    </list>
    return xmldb:store("/db/apps/pessoa/data","titles-raw.xml",$title-xml)
};

declare function local:clean-titles(){
    (: group the titles and sort alphabetically :)
    let $titles-raw := doc("/db/apps/pessoa/data/titles-raw.xml")//entry
    let $title-xml := <list>
        {for $entry in $titles-raw
        let $title := $entry/title/data(.)
        group by $title
        return <entry>
            <letter>{translate(substring(replace(upper-case($title),'^[“”"(\.\s«‘]+',''),1,1),'ÁÀÓ','AAO')}</letter>
            <title>{$title}</title>
            <links>
                {for $e in $entry
                let $pl := $e/parentLink
                group by $pl
                order by $e[1]/parentName
                return
                    <link>
                        <type>{$e[1]/type/data(.)}</type>
                        <parentName>{$e[1]/parentName/data(.)}</parentName>
                        <parentLink>{$e[1]/parentLink/data(.)}</parentLink>
                    </link>}
            </links>
        </entry>}
    </list>
    return xmldb:store("/db/apps/pessoa/data","titles-raw-sorted.xml",$title-xml)
};


(: join elements of a path :)
declare function local:path-join($path-elements as xs:string+) as xs:string{
    string-join($path-elements, "/")
};

(: set the rights of xquery files correctly :)
declare function local:set-rights($collection-uri as xs:string){
    (: scan the app for xquery files :)
    let $files := xmldb:get-child-resources($collection-uri)
    let $xqueries := $files[ends-with(.,(".xq", ".xql", ".xqm"))]
    let $child-collections := xmldb:get-child-collections($collection-uri)
    return  (
        for $qu in $xqueries
        return sm:chmod(xs:anyURI(local:path-join(($collection-uri, $qu))), "rwxr-xr-x"),
        if (not(empty($child-collections)))
        then for $ch in $child-collections
             return local:set-rights(local:path-join(($collection-uri, $ch)))
        else()
    )
};


(
local:move-index(),
local:createXML(),
local:get-titles(),
local:clean-titles(),
local:set-rights("/db/apps/pessoa")
)
