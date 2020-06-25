xquery version "3.0";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";

(: adapt config paths to remote system :)
(: internal: http://projects.cceh.uni-koeln.de:8080/apps/pessoa :)
declare function local:adapt-conf(){
    let $conf-file := doc("/db/apps/pessoa/conf.xml")
    return
        (
            update replace $conf-file//webapp-root with <webapp-root>http://www.pessoadigital.pt</webapp-root>,
            update replace $conf-file//request-path with <request-path>/apps/pessoa</request-path>
        )
};

local:adapt-conf()