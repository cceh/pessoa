xquery version "3.1";
module namespace ownZip="http://localhost:8080/exist/apps/pessoa/zip";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace request = "http://exist-db.org/xquery/request";
declare option output:method "binary";
declare option output:media-type "application/zip";

declare function ownZip:compress($file as xs:string) {
    let $URL := "/db/apps/pessoa/data/"

    let $list := doc(concat($URL,"doclist.xml"))

    let $docList := for $item in $list/list/docs[@dir = $file]/doc

         let $entry := concat($URL,$file,"/",$item/data(.))
        where $item/@availability eq "free"
        return <entry name="{$item/data(.)}" type="xml" method="store">
            {doc($entry)}
    </entry>

    let $compressed-collection :=  compression:zip($docList,false())
    return response:stream-binary($compressed-collection, "application/zip", concat($file,".zip"))

};