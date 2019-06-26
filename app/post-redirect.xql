xquery version "3.0";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";

(: adapt config paths to remote system :)
declare function local:adapt-conf(){
    let $conf-file := doc("/db/apps/pessoa/conf.xml")
    return
        (
            update replace $conf-file//webapp-root with <webapp-root>http://www.pessoadigital.pt</webapp-root>,
            update replace $conf-file//request-path with <request-path>/apps/pessoa</request-path>
        )
};

(:
declare function local:generateODD(){
let $odd := transform:transform(doc("/db/apps/pessoa/data/schema/pessoaTEI.odd"), doc("/db/apps/pessoa/xslt/odds/odd2odd.xsl"), ())
let $store-odd := xmldb:store("/db/apps/pessoa/data/schema", "pessoaTEIodd.xml", $odd)
let $html := transform:transform(doc("/db/apps/pessoa/data/schema/pessoaTEIodd.xml"), doc("/db/apps/pessoa/xslt/odds/odd2html.xsl"), ())
let $store-html := xmldb:store("/db/apps/pessoa/data/schema", "pessoaTEI.html", $html)
return ()
};
:)

(:
(local:adapt-conf(),
local:generateODD())
:)

local:adapt-conf()