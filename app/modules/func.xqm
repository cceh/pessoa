xquery version "3.1";

module namespace func="http://localhost:8080/exist/apps/pessoa/func";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace admin="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/admin" at "admin.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare function func:createDocXML() {
let $input := 
                    <docs> {
                    
                    for $indikator in ("1-9", "10","20","30","40","50","60","70","80","90","100","CP")  return
                        <list id="{$indikator}"> {
                            for $item in func:items($indikator)
                                        let $label := substring-before(replace($item/@label,("BNP_E3_|CP"),""),".xml")
                                         let $front := if(contains($label,"-")) then substring-before($label,"-") else $label
                                        order by $front, xs:integer(replace($label, "^\d+[A-Z]?\d?-?([0-9]+).*$", "$1")) 
                                        return <doc>{$item/@label/data(.)}</doc>
                                        }
                        </list>
                        }
                    </docs>
                    
return 
                                   xmldb:store("/db/apps/pessoa/data","doclist.xml",$input))
};


declare function func:items($indikator) {
    for $hit in collection("/db/apps/pessoa/data/doc")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="filename"]/data(.)
                let $label :=   if(substring-after($hit, "BNP_E3_") != "") then substring-after(replace(substring-before($hit, ".xml"), "_", " "), "BNP E3 ")
                                else if(substring-after($hit,"CP") != "") then  substring-after(substring-before($hit, ".xml"),"CP")
                                else ()
                    let $title :=  $hit 
                          return if( $indikator !="1-9" 
                                            and func:getCorrectDoc($label, $indikator) = xs:boolean("true") 
                                            and $indikator != "CP" and contains($hit,"BNP")) 
                                                then <item label="{$title}"/>
                                        else if ($indikator = "CP" and contains($hit,"CP")) 
                                                then <item label="{$title}"/>
                                        else if($indikator = "1-9" and func:getCorretDoc_alphabetical($label,2) = xs:boolean("true")) 
                                                then <item label="{$title}"/>
                                        else ()
                                        };


declare function func:getCorrectDoc($label as xs:string, $indi as xs:string) as xs:boolean+ {
    if(contains(substring($label,1,1),substring($indi,1,1)) ) then
        let $c_label := if( contains($label,"-") ) 
            then substring-before($label,"-") 
            else $label
        for $pos in ( 1 to string-length($c_label))
            return if (func:getCorretDoc_alphabetical($c_label,$pos) = xs:boolean("true") 
                            or $pos = string-length($c_label)) 
                                then func:getCorrectDoc_Step2($label,$indi,$pos) else xs:boolean("false")
    else xs:boolean("false")
};


declare function func:getCorrectDoc_Step2($c_label as xs:string, $indi as xs:string,$pos as xs:integer) as xs:boolean{
    if( ($pos = 2  or $pos = 3) 
            and string-length($indi) = 2 
            and func:getCorrectDoc_nummeric($c_label,2) = xs:boolean("true") 
            and not( func:getCorrectDoc_nummeric($c_label,3) = xs:boolean("true"))) 
                then xs:boolean("true") 
    else if ( ($pos = 3 or $pos = 4) 
                    and string-length($indi) = 3 
                    and func:getCorrectDoc_nummeric($c_label,3) = xs:boolean("true")) 
                        then xs:boolean("true") 
    else if( ($pos = 3 or $pos = 2 or $pos = 1) 
                and string-length($indi) = 1 
                and (  func:getCorretDoc_alphabetical($c_label,$pos)  = xs:boolean("true") 
                or   func:getCorretDoc_alphabetical($c_label,2)  = xs:boolean("true") 
                or   func:getCorretDoc_alphabetical($c_label,3)  = xs:boolean("true")) ) 
                    then xs:boolean("true")
    else xs:boolean("false")
};


declare function func:getCorretDoc_alphabetical($label as xs:string, $pos as xs:integer) as xs:boolean? {
    for $cut in ( "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y" ,"z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y" ,"Z","-") 
    return if (contains(substring($label,$pos,1),xs:string($cut) )) then xs:boolean("true") else ()

};

declare function  func:getCorrectDoc_nummeric($label as xs:string, $pos as xs:integer) as xs:boolean? {
    for $cut in (0 to 9)
    return if (contains(substring($label, $pos, 1),xs:string($cut))) then xs:boolean("true") else  ()
};