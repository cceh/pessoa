xquery version "1.0";


(: adapt config paths to remote system :)
declare function local:adapt-conf(){
	let $conf-file := doc("/db/apps/pessoa/conf.xml")
	return 
    	(
    		update replace $conf-file//webapp-root with <webapp-root>http://projects.uni-koeln.de/pessoa</webapp-root>,
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
	xmldb:rename(concat($conf-path, "/pub"), "SUCHE_pub-collection.xconf", "collection.xconf")
	)
};



(
local:adapt-conf(),
local:move-index()
)
