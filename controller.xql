xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "modules/doc.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "modules/author.xqm";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "modules/search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "modules/helpers.xqm";

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$helpers:web-language}/index.html"/>
    </dispatch>
    
(: Language Notation :)
else if (contains($exist:path, concat($helpers:web-language,"/index.html"))) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/index.html" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
else if (contains($exist:path,  "doc/versao-pessoal")) then
    let $lb := request:get-parameter("lb", "yes")
    let $abbr := request:get-parameter("abbr", "yes")
    let $version := request:get-parameter("version","diplomatic")
    let $id := request:get-parameter("id", ())
    return doc:get-text-pessoal(<node />, map {"test" := "test"}, $id, $lb, $abbr, $version)
else if (contains($exist:path,  "/doc/")) then
    if ($exist:resource = "xml") then
    let $id := substring-before(substring-after($exist:path, "/doc/"), "/xml")
    return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/data/doc/{$id}.xml"/>
    </dispatch>
    else
    (session:set-attribute("id", $exist:resource), 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/doc.html">
        <add-parameter name="id" value="{$exist:resource}" />
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>)
else if (contains($exist:path, "/pub/")) then
    (session:set-attribute("id", $exist:resource), 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/pub.html">
            <add-parameter name="id" value="{$exist:resource}" />
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
	</dispatch>)
else if (contains($exist:path, "/author/")) then
    if (request:get-parameter("orderBy","")!="") then
    let $orderBy := request:get-parameter("orderBy", "alphab")
    let $author := substring-before(substring-after($exist:path, '/page/author/'), '/')
    let $textType := $exist:resource
    return 
   author:reorder(<node />, map {"test" := "test"},$orderBy, $textType, $author)
    else
    let $author := substring-before(substring-after($exist:path, '/author/'), '/')
    let $textType := $exist:resource
    return
    (session:set-attribute("textType", $textType),
    session:set-attribute("author", $author),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/author.html" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>)
else if(contains($exist:path, "page/genre") ) then
        if(request:get-parameter("orderBy",'') ) then
        let $orderBy := request:get-parameter("orderBy", '')
        let $type := $exist:resource
        return doc:get-genre(<node />, map {"test" := "test"}, $type, $orderBy)
        else (
        session:set-attribute("type",$exist:resource),
        session:set-attribute("orderBy","alphab"),
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/genre.html" />
        <add-parameter name="type" value="{$exist:resource}" />
        <add-parameter name="orderBy" value="alphab"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
)
else if(contains($exist:path,"page/bibliografia")) then
let $type :=$exist:resource
return (
    session:set-attribute("type",$type),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/bibliografia.html" />
        <add-parameter name="type" value="{$type}" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
)

else if (contains($exist:path,"timeline")) then
    (
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/timeline.html" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>)
    else if (ends-with($exist:resource, ".html") and contains($exist:path,"page/")) then
     <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                 <forward url="{$exist:controller}/page/{substring-after($exist:path,"page/")}"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/../shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    (:Suche:)
else if (contains($exist:path, "search")) then
    if(request:get-parameter("orderBy", '') != "" ) 
    then 
       let $orderBy := request:get-parameter("orderBy", '')
       return( search:profiresult(<node />, search:profisearch(<node />, map {"test" := "test"}, request:get-parameter("term",'')), "union",$orderBy))
   else 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/search.html" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
    
    else if (contains($exist:path, "events")) then
    let $language := $helpers:web-language (: request:get-parameter("lang", "pt"):)
    return 
        transform:transform((collection("/db/apps/pessoa/data/doc"), collection("/db/apps/pessoa/data/pub"))//tei:TEI, doc("/db/apps/pessoa/xslt/events.xsl"), <parameters><param name="language" value="{$language}"/></parameters>)
    
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>