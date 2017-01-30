xquery version "1.0";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: adapt config paths to remote system :)
declare function local:adapt-conf(){
	let $conf-file := doc("/db/apps/pessoa/conf.xml")
	return 
    	(
    		update replace $conf-file//webapp-root with <webapp-root>http://www.pessoadigital.pt</webapp-root>,
    		update replace $conf-file//request-path with <request-path>/apps/pessoa</request-path>
	)
};

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


declare function local:createDocXML() {
let $items := for $indikator in ("1-9", "10","20","30","40","50","60","70","80","90","100","CP")  return local:docItems($indikator)
let $items := for $item in $items order by xs:integer(local:anaIndi($item/@indi/data(.)))
                        return <item label="{$item/@label/data(.)}"  indi="{$item/@indi/data(.)}"/>
let $sum := sum($items)                        
let $docs := <docs>
                        {for $a in (1 to  $sum - 1) return
                            <doc indi="{$items[$a]/@indi/data(.)}">{$items[$a]/@label/data(.)}</doc>
                            }
                        </docs>
let $input :=$docs                    
return xmldb:store("/db/apps/pessoa/data","doclist.xml",$input)
};


declare function local:anaIndi($indi) {
    if($indi = "1-9" or $indi = "Pessoa") then "1"
    else if($indi = "10" or $indi = "Caiero" ) then "2"
    else if($indi = "20" or $indi = "Campos") then "3"
    else if($indi = "30" or $indi = "Reis") then "4"
    else if($indi = "40") then "5"
    else if($indi = "50") then "6"
    else if($indi = "60") then "7"
    else if($indi = "70") then "8"
    else if($indi = "80") then "9"
    else if($indi = "90") then "10"
    else if($indi = "100") then "11"
    else if($indi = "CP") then "12"
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

(
local:adapt-conf(),
local:move-index(),
local:createDocXML()
)
