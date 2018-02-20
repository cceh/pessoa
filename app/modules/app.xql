xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/pessoa/templates";
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace pub="http://localhost:8080/exist/apps/pessoa/pub" at "pub.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "author.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";
import module namespace charts="http://localhost:8080/exist/apps/pessoa/charts" at "charts.xqm";
import module namespace obras="http://localhost:8080/exist/apps/pessoa/obras" at "obras.xqm";


import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";
declare namespace request="http://exist-db.org/xquery/request";

declare namespace tei="http://www.tei-c.org/ns/1.0";



(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*),$path) {
    $path
};


(:~
: Funktion für die Anzeige der Bibliographischen Einträge
: Öffnet bibl.xml und wandelt es mithilfe von bibl.xsl um
: @param $type Parameter zur erkennung welcher Bibliographischer Eintrag angezeigt werden soll
: @return Wellformed HTML
:)
declare function app:get-bibl($node as node(), $model as map(*), $type as xs:string)as item()* {
    let $xml := doc("/db/apps/pessoa/data/bibl.xml")
    let $stylesheet := doc("/db/apps/pessoa/xslt/bibl.xsl")
    let $typ :=
        switch($type)
            case "Works_of_Fernando_Pessoa" return "1"
            case 'About_the_work_of_Fernando_Pessoa' return "2"
            case 'Other_sources_of_the_work_of_Fernando_Pessoa' return "3"
            default return "1"

    return  transform:transform($xml, $stylesheet,(<parameters><param name="listNo_string" value="{$typ}"/></parameters>))

};

(:~
: Generelle Funktion zur Anzeige von Texten auf verschiedenen Seiten (u.a. Team, Docu, etc.)
: Öffnet webpage.xml um sie anschließend mithilfe von webpage.xsl zu verarbeiten und in eine Leserliche Form zu bringen
: @param $xmlid Welche Eintrag innerhalb von webpage.xml verarbeitet werden
: @return Wellformed HTML
:)
declare   function app:MultiPage($node as node(), $model as map(*),$xmlid as xs:string) {
let $doc := doc("/db/apps/pessoa/data/webpage.xml")
let $stylesheet := doc("/db/apps/pessoa/xslt/webpage.xsl")
let $text := $doc/tei:TEI/tei:text/tei:group/tei:text[@xml:id=$xmlid]/tei:group/tei:text[@xml:lang = $helpers:web-language]/tei:body
return  transform:transform($text, $stylesheet, (<parameters><param name="res" value="{$helpers:app-root}"/></parameters>))
};

(:~ Collect all Documents from the folders "doc" and "pub":)
declare function app:collections($node as node(), $model as map(*)) {
    let $docs := collection("/db/apps/pessoa/data/doc")
    let $pubs := collection("/db/apps/pessoa/data/pub")
    let $all := ($docs,$pubs)
    return map { 
        "documents" := $all,
        "count" := count($all)
        }
};

(:~ Checks the Documents from the model "doc", called the function app:validate, returns model with name and valid :)
declare function app:checkDocuments($node as node(), $model as map(*)) {
    let $document := $model("doc")
    let $doc := root($document)/util:document-name(.)
    let $valid := if(app:validate($document)) then <b style="color:green">Valid</b> else <b style="color:red">Not Valid</b>
    let $date := if(contains($doc,"BNP") or contains($doc,"CP")) then app:checkDateDoc($document) else app:checkDatePub($document)
    let $dateout := if(not(contains($date/@check, "false")) ) then <u style="color:green">{$date/@date/data(.)} | {$date/@att/data(.)}</u> else <u style="color:red">{$date/@date/data(.)} | {$date/@att/data(.)}</u>
    let $clear := validation:clear-grammar-cache()
    return map {
        "name" := $doc,
        "valid" := $valid,
        "date" := $dateout
    }
};

declare function app:countDocs($node as node(),$model as map(*)) {
    let $valid := for $doc in $model("documents") where app:validate($doc) return app:validate($doc)
    let $invalid := for $doc in $model("documents") where not(app:validate($doc)) return app:validate($doc)    
    return map {
        "validDocs" := count($valid),
        "invalidDocs" := count($invalid)
        }
};

declare function app:checkDatePub($doc as node()*) {
    let $imprint := $doc//tei:imprint
    let $range := if( exists($imprint/tei:date/attribute()[2])) then 2 else 1    
    let $check := for $x in (1 to $range) 
                            let $att := if(contains($imprint/tei:date/attribute()[$x],"-")) then substring-before( $imprint/tei:date/attribute()[$x],"-") else $imprint/tei:date/attribute()[$x]
                            return if(contains($imprint/tei:date/data(.),$att)) then true() else false()     
    let $att := if($range = 2) then ( for $x in (1 to $range) return $imprint/tei:date/attribute()[$x]  ) else $imprint/tei:date/attribute()[1]    
    return <item check="{$check}" date="{$imprint/tei:date}" att="{$att}"/>
};

declare function app:checkDateDoc($doc as node()*) {
    let $date := $doc//tei:msDesc/tei:history/tei:origin/tei:p
    
    let $range := if(exists($date/tei:origDate/attribute()[2])) then (if($date/tei:origDate/attribute()[2] != "medium") then 2 else 1) else 1
    
    let $check := for $x in (1 to $range) 
                            let $att := if(contains($date/tei:origDate/attribute()[$x],"-")) then substring-before( $date/tei:origDate/attribute()[$x],"-") else $date/tei:origDate/attribute()[$x]
                            return if(contains($date/tei:origDate/data(.),$att)) then true() else false()     
    let $att := if($range = 2) then ( for $x in (1 to $range) return $date/tei:origDate/attribute()[$x]  ) else $date/tei:origDate/attribute()[1]    
    return <item check="{$check}" date="{$date/tei:origDate}" att="{$att}"/>
};

(:~ Document Validtion :)
declare function app:validate($doc as node()*) {    
    let $schema := "/db/apps/pessoa/data/schema/pessoaTEI.rng"
    return validation:validate($doc,$schema)
};


declare function app:startDocu($node as node(), $model as map(*),$docu as xs:string?) {
    if($docu eq 'true') then
    <script type="text/javascript">
        $("#docu-con").css("width","100%");
        $(".closebtn").css('display','inline-block');
    </script>
    else ()
};


declare function app:networkSearch($node as node(), $model as map(*)) {
    <input id="myInput" name="term" placeholder="{helpers:singleElementInList_xQuery("search","term")}..." />
};