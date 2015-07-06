xquery version "1.0";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace admin="http://projects.cceh.uni-koeln.de:8080/apps/pessoa/admin" at "/db/apps/pessoa/modules/admin.xqm";

(: adapt config paths to remote system :)
declare function local:adapt-conf(){
	let $conf-file := doc("/db/apps/pessoa/conf.xml")
	return 
    	(
    		update replace $conf-file//webapp-root with <webapp-root>http://projects.cceh.uni-koeln.de/pessoa</webapp-root>,
    		update replace $conf-file//request-path with <request-path>/apps/pessoa</request-path>
	)
};

(: move search index to system :)
declare function local:move-index(){
	let $app-path := "/db/apps/pessoa"
	let $conf-path := "/db/system/config/db/apps/pessoa/data"
	let $log-in := xmldb:login("/db", $admin:admin-id, $admin:admin-pass)
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



(
local:adapt-conf(),
local:move-index()
)
