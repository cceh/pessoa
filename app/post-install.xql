xquery version "3.0";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";

(: move search index to system :)
declare function local:move-index(){
	let $app-path := "/db/apps/pessoa"
	let $conf-path := "/db/system/config/db/apps/pessoa/data"
	return
    	(
	xmldb:move($app-path, concat($conf-path, "/doc"), "SUCHE_doc-collection.xconf"),
	xmldb:move($app-path, concat($conf-path, "/pub"), "SUCHE_pub-collection.xconf"),
	xmldb:rename(concat($conf-path, "/doc"), "SUCHE_doc-collection.xconf", "collection.xconf"),
	xmldb:rename(concat($conf-path, "/pub"), "SUCHE_pub-collection.xconf", "collection.xconf"),
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
                            {$docs}
                            {$pub}
                        </list>
    let $input := $input
    return xmldb:store("/db/apps/pessoa/data","doclist.xml",$input)
};
(:)"date_when","date_notBefore","date_notAfter","date_from","date_to:)

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
  let $items := for $indikator in ("Pessoa","Caeiro","Campos","Reis") return local:pubItems($indikator)
  let $items := for $item in $items order by local:anaIndi($item/@indi/data(.))
                        return <item label="{$item/@label/data(.)}"  indi="{local:getAuthorShort($item/@indi/data(.))}"/>
  return $items
};

declare function local:getAuthorShort($indi as xs:string) {
    switch($indi)
        case "Pessoa" return "FP"
        case "Caeiro" return "AC"
        case "Campos" return "AdC"
        case "Reis" return "RR"
        default return "UH"
};

declare function local:pubItems($indikator) {
    for $hit in xmldb:get-child-resources("/db/apps/pessoa/data/pub") 
    where contains($hit,$indikator)
    return <item label="{$hit}" indi="{$indikator}"/>
};
declare function local:createDocXML() {
let $items := for $indikator in ("1-9", "10","20","30","40","50","60","70","80","90","100","CP")  return local:docItems($indikator)
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
    else if($indi = "40") then 5
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
                let $label :=   if(substring-after($hit, "BNP_E3_") != "") then substring-after(replace(substring-before($hit, ".xml"), "_", " "), "BNP E3 ")
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
            return if (local:getCorretDoc_alphabetical($c_label,$pos) = xs:boolean("true") 
                            or $pos = string-length($c_label)) 
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

declare function local:search_range_simple($para as xs:string,$hit as xs:string, $db as node()*) as node()* {
 
     (:   let $para := if($para = "person")then  "author" else () :)
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};


declare function local:saveTitleXML() {
let $html := local:createTitleXML()
return xmldb:store("/db/apps/pessoa/data","titlelist.xml",$html)
};
declare function local:createTitleXML() {
    let $well := local:collectTexts()
    let $well := for $item in $well order by $item/@well/data(.) return $item
    let $letters := for $letter in $well/@letter order by $letter return $letter
    let $letters := distinct-values($letters)
    let $letters := for $letter in $letters return local:highLetters($letter)
    let $letters := distinct-values($letters)
    return <titles>
                    { for $a in $letters return
                    <list letter="{$a}">     {
                        for $item in $well where $item/@letter eq $a return
                           <item>
                            <name type="{$item/@type/data(.)}" ref="{$item/@ref/data(.)}">{$item/@well/data(.)}</name>
                            {if($item/@type eq "doc") then 
                            for $hit in $item/item return
                            <item ref="{$hit/@link/data(.)}">{$hit/@title/data(.)}</item> 
                            else ()
                            }
                             </item>
                            }
                        </list>
                    }                    
                </titles>

};

declare function local:titleTest() {
for $text in  local:search_range_simple("type","title",collection('/db/apps/pessoa/data/doc'))
                                for $single in $text//tei:rs[@type = "title"]
                                order by $single
                            return  local:transformTitle($single)
};



declare function local:transformTitle($title as node()) {
    let $stylesheet := doc("/db/apps/pessoa/xslt/title.xsl")
    return transform:transform($title, $stylesheet, (<parameters/>))

};



declare function local:collectTexts() {
    let $texts := for $text in  local:search_range_simple("type","title",collection('/db/apps/pessoa/data/doc'))
                                for $single in $text//tei:rs[@type = "title"]
                                order by $single
                            return <item name="{local:transformTitle($single)}" ref="{substring-before(root($single)/util:document-name(.),".xml")}"/>
                            
   let $docs := for $doc in $texts
                            return <item 
                                                    name="{$doc/@name/data(.)}"  
                                                    ref="{$doc/@ref/data(.)}" 
                                                    title="{replace(doc(concat('/db/apps/pessoa/data/doc/',$doc/@ref/data(.),".xml"))//tei:title[1]/data(.),"/E3","")}"
                           />
    let $docs := $docs | $docs                       
    let $names :=$texts/@name/data(.)
    let $names := distinct-values($names)
    let $well := for $name in $names
                    return <item title="{$name}" well="{$name}" type="doc"  letter="{local:FindFirstLetter-new($name,1)}">
                                {  let $ref :=   local:scanDocs($name,$docs)
                                    let $ref := distinct-values($ref)
                                    return for $item in $ref return <item link="{$item}" title="{replace(doc(concat('/db/apps/pessoa/data/doc/',$item,".xml"))//tei:title[1]/data(.),"/E3","")}"/>
                                }
                                </item>
    let $pubs := collection('/db/apps/pessoa/data/pub')
    let $pubs_title := for $hit in $pubs//tei:teiHeader/tei:fileDesc
                                    return <item 
                                                        ref="{substring-before($hit//tei:publicationStmt/tei:idno[@type="filename"]/data(.),".xml")}" 
                                                        well="{$hit//tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title[@level = "a"]/data(.)}" 
                                                        type="pub"
                                                        letter="{local:FindFirstLetter-new($hit//tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title[@level = "a"]/data(.),1)}"/>

    let $well := ($well, $pubs_title)
    return $well
};

declare function local:FindFirstLetter-new($text as xs:string, $pos as xs:integer) {
    if(matches(substring($text,$pos,1),'[A-z]')) then substring($text,$pos,1)
    else if ($pos > string-length($text)) then concat("Error/",$pos)
    else local:FindFirstLetter-new($text,$pos +1)
};

declare function local:scanDocs($text, $aDocs) {
            (: let $docs := for $doc in $aDocs where $doc/@name eq $text  return <item link="{$doc/@ref/data(.)}" title="{$doc/@title/data(.)}"/>
             let $docs := for $a in (1 to count($docs)) let $coma := if($a != count($docs)) then "yes" else "no" return <item link="{$docs[$a]/@link/data(.)}" title="{$docs[$a]/@title/data(.)}" coma="{$coma}"/>
             return $docs:)
             for $doc in $aDocs where $doc/@name eq $text  return $doc/@ref/data(.)
};
declare function local:highLetters($letter) {
    switch($letter)
            case "A" case "a" return("A")
            case "B" case "b"return("B")
            case "C" case "c"return("C")
            case "D" case "d" return("D")
            case "E" case "e" return("E")
            case "F" case "f" return("F")
            case "G" case "g" return("G")
            case "H" case "h" return("H")
            case "I" case "i" return("I")
            case "J" case "j" return("J")
            case "K" case "k" return("K")
            case "L" case "l" return("L")
            case "M" case "m" return("M")
            case "N" case "n" return("N")
            case "O" case "o" return("O")
            case "P" case "p" return("P")
            case "Q" case "q" return("Q")
            case "R" case "r" return("R")
            case "S" case "s" return("S")
            case "T" case "t" return("T")
            case "U" case "u" return("U")
            case "V" case "v" return ("V")
            case "W" case "w" return("W")
            case "X" case "x" return("X")
            case "Y" case "y" return("Y")
            case "Z" case "z" return("Z")
            default return $letter
};


(
local:move-index(),
local:createXML(),
local:saveTitleXML()

)
