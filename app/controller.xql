xquery version "3.0";


import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "modules/doc.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "modules/author.xqm";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "modules/search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "modules/helpers.xqm";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "modules/config.xqm";
import module namespace index="http://localhost:8080/exist/apps/pessoa/index" at "modules/index.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";


declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $exist:sites := (distinct-values(doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]//tei:item/tei:note[@type='directory']/data(.)));
declare variable $exist:authors := (doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person/@xml:id,'Pessoa','Caeiro','Campos','Reis');
declare variable $exist:permission := if(local:logged-in()) then true() else local:Restriction();

declare function local:login() as xs:boolean {
    let $loginuser := request:get-parameter('user',())
    let $loginpassword := request:get-parameter('pass',())
    return
        if ($loginuser and $loginpassword) then
            xmldb:login('/db',$loginuser,$loginpassword)
        else
            false()
};

declare function local:logged-in() as xs:boolean {
    if (xmldb:get-user-groups(xmldb:get-current-user()) = ("pessoa") ) then true() else false()
};

declare function local:Restriction() as xs:boolean{
    let $sites := ($exist:sites,"doc","pub","search","timeline","BNP","CP","network")
    let $path := if(contains($exist:path,$helpers:web-language))
                    then substring-after($exist:path,concat($helpers:web-language,"/"))
                else if(contains($exist:path,'data'))
                    then substring-after(substring-after($exist:path,"data/"),"/")
                else substring-after($exist:path,'/')
    let $path := if(contains($path,"/"))
                    then substring-before($path,"/")
                    else $path
    return if(helpers:contains-any-of($exist:path,$sites)) then
                switch($path)
                    case "doc" return local:resRestritction()
                    case "pub" return local:resRestritction()
                    case "search" return true()
                    case "timeline" return true()
                    case "network" return true()
                    default return
                        let $doc := doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]//tei:item[@xml:id eq $exist:resource]
                            return
                        if($doc/tei:note[@type='directory']/data(.) eq $path and $doc/tei:note[@type='published']/data(.) eq "true")
                            then true()
                            else false()
        else false()
};


declare function local:pathi() {
    let $sites := ($exist:sites,"doc","pub","search","timeline","BNP","CP","network")
    let $path := if(contains($exist:path,$helpers:web-language))
                    then substring-after($exist:path,concat($helpers:web-language,"/"))
                else if(contains($exist:path,'data'))
                    then substring-after(substring-after($exist:path,"data/"),"/")
                else substring-after($exist:path,'/')

    let $path := if(contains($path,"/"))
                    then substring-before($path,"/")
                    else $path
    let $path := if(helpers:contains-any-of($path,("BNP","CP")))
                    then "doc"
                    else if(helpers:contains-any-of($path,$exist:authors))
                        then "pub"
                    else $path

    return $path
};

declare function local:resRestritction() as xs:boolean {
    let $path := if(contains($exist:path,concat($helpers:web-language,'/')))
                    then substring-before(substring-after($exist:path,concat($helpers:web-language,'/')),'/')
                else substring-before(substring-after($exist:path,'/'),'/')
    let $res := if(contains($exist:resource,".xml"))
                    then $exist:resource
                else if(contains($exist:path,'/xml'))
                    then concat(substring-after(substring-before($exist:path,'/xml'),concat($path,'/')),'.xml')
                else concat($exist:resource,".xml")
    return if(doc(concat("/db/apps/pessoa/data/",$path,"/",$res))//tei:availability/@status eq "free")
                then true()
                else false()
};


(:#### Der öffentlich zugängliche Bereich:)

if ($exist:path eq "/") then
(: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$helpers:web-language}/index.html"/>
    </dispatch>
else if ( $exist:path eq "") then
(: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="pessoa/{$helpers:web-language}/index.html"/>
    </dispatch>
(: Language Notation :)
else if (contains($exist:path, concat($helpers:web-language,"/index.html"))) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/index.html" />
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
        </dispatch>

    else if ( (contains($exist:resource, "network") or contains($exist:path,"network"))
                and not(helpers:contains-any-of($exist:resource,(".js",".css",".json")))) then
            (session:clear(),
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/page/network.html"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>)
        else if (contains($exist:resource,".json")) then
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/data/network/{$exist:resource}"/>
                </dispatch>
            else if(contains($exist:resource,"logout")) then(
                    let $logout :=  xmldb:login("/db","guest","guest")
                    return
                        (  session:invalidate(),
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <redirect url="index.html"/>
                        </dispatch>
                        )
                )
                else if(contains($exist:resource,"login")) then (
                        if(local:login()) then
                            if(local:logged-in()) then
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <redirect url="index.html"/>
                                </dispatch>
                            else
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <redirect url="index.html"/>
                                </dispatch>
                        else
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <redirect url="index.html"/>
                            </dispatch>
                    )
                      else  if (contains($exist:path, "events")) then
                            let $language := request:get-parameter("lang",'pt')
                            return
                                transform:transform((collection("/db/apps/pessoa/data/doc"), collection("/db/apps/pessoa/data/pub"))//tei:TEI, doc("/db/apps/pessoa/xslt/events.xsl"), <parameters><param name="language" value="{$language}"/><param name="basepath" value="{$exist:controller}"></param></parameters>)
                        else if ($exist:resource = "tei-odd") then
                            doc("/db/apps/pessoa/data/schema/pessoaTEI.html")


                    else if($exist:permission) then (

                             if (contains($exist:path,  "/doc/")) then
                                    if ($exist:resource = "xml") then
                                        let $id := substring-before(substring-after($exist:path, "/doc/"), "/xml")
                                        return
                                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                <forward url="{$exist:controller}/data/doc/{$id}.xml"/>
                                            </dispatch>
                                    else if (helpers:contains-any-of($exist:path,("transcricao-diplomatica","primeira-versao","versao-final")))
                                    then
                                        let $id := substring-before(substring-after($exist:path,"doc/"),"/")
                                        return
                                            (session:set-attribute("id", $id),
                                            session:set-attribute("type", $exist:resource),
                                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                <forward url="{$exist:controller}/page/doc.html">
                                                    <add-parameter name="id" value="{$id}" />
                                                    <add-parameter name="type" value="{$exist:resource}" />
                                                </forward>
                                                <view>
                                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                                </view>
                                                <error-handler>
                                                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                                </error-handler>
                                            </dispatch>)
                                    else if (contains($exist:path,"versao-pessoal") ) then
                                            let $lb := request:get-parameter("lb", "yes")
                                            let $abbr := request:get-parameter("abbr", "yes")
                                            let $version := request:get-parameter("version","diplomatic")
                                            let $id := substring-before(substring-after($exist:path,"doc/"),"/")
                                            return if(request:get-parameter("case",'') eq "div")
                                            then doc:get-text-pessoal(<node />, map {"test" := "test"}, $id, $lb, $abbr, $version)
                                            else (
                                                    session:set-attribute("id", $id),
                                                    session:set-attribute("type", $exist:resource),
                                                    session:set-attribute("lb", $lb),
                                                    session:set-attribute("abbr", $abbr),
                                                    session:set-attribute("version", $version),
                                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                        <forward url="{$exist:controller}/page/doc.html">
                                                            <add-parameter name="id" value="{$id}" />
                                                            <add-parameter name="type" value="{$exist:resource}" />
                                                            <add-parameter name="lb" value="{$lb}" />
                                                            <add-parameter name="abbr" value="{$abbr}" />
                                                            <add-parameter name="version" value="{$version}" />
                                                        </forward>
                                                        <view>
                                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                                        </view>
                                                        <error-handler>
                                                            <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                                        </error-handler>
                                                    </dispatch>)


                                        else
                                            (session:set-attribute("id", $exist:resource),
                                            session:set-attribute("type", "transcricao-diplomatica"),
                                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                <forward url="{$exist:controller}/page/doc.html">
                                                    <add-parameter name="id" value="{$exist:resource}" />
                                                    <add-parameter name="type" value="transcricao-diplomatica" />
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
                                        if ($exist:resource = "xml") then
                                            let $id := substring-before(substring-after($exist:path, "/pub/"), "/xml")
                                            return
                                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                    <forward url="{$exist:controller}/data/pub/{$id}.xml"/>
                                                </dispatch>
                                        else
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
                                        else if(contains($exist:path, "genre") ) then
                                                if(request:get-parameter("orderBy",'') ) then
                                                    let $orderBy := request:get-parameter("orderBy", '')
                                                    let $type := $exist:resource
                                                    return
                                                        index:collectGenre(<node />, map {"test" := "test"}, $type, $orderBy)
                                                else (
                                                    session:set-attribute("type",$exist:resource),
                                                    session:set-attribute("orderBy","date"),
                                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                        <forward url="{$exist:controller}/page/genre.html" />
                                                        <add-parameter name="type" value="{$exist:resource}" />
                                                        <add-parameter name="orderBy" value="date"/>
                                                        <view>
                                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                                        </view>
                                                        <error-handler>
                                                            <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                                        </error-handler>
                                                    </dispatch>
                                                )
                                            else if(contains($exist:path,"bibliografia")) then
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
                                                            if( not(contains($exist:path,$helpers:web-language))) then
                                                                (
                                                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                        <redirect url="{$config:app-root}/{$helpers:web-language}/timeline" />
                                                                        <view>
                                                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                                                        </view>
                                                                        <error-handler>
                                                                            <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                                                        </error-handler>
                                                                    </dispatch>)
                                                            else
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
                                                        )
                                                    else if (contains($exist:path,"obras")) then
                                                            (
                                                                session:set-attribute("id",$exist:resource),
                                                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                    <forward url="{$exist:controller}/page/obras.html" />
                                                                    <add-parameter name="id" value="{$exist:resource}" />
                                                                    <view>
                                                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                                                    </view>
                                                                    <error-handler>
                                                                        <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                                                    </error-handler>
                                                                </dispatch>

                                                            )

                                                        else if (ends-with($exist:resource, ".html") and contains($exist:path, "page/")) then
                                                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                    <forward url="{$exist:controller}/page/{substring-after($exist:path, "page/")}"/>
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
                                                                else if (contains($exist:path, "page/") and not(ends-with($exist:path, "/"))) then
                                                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                            <forward url="{$exist:controller}/page/{substring-after($exist:path, "page/")}.html"/>
                                                                            <view>
                                                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                                                            </view>
                                                                            <error-handler>
                                                                                <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                                                            </error-handler>
                                                                        </dispatch>
                                                                    else if (contains($exist:path, "page/") and not(ends-with($exist:resource, ".html"))) then
                                                                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                                <forward url="{$exist:controller}/page/{substring-before(substring-after($exist:path, "page/"), "/")}.html"/>
                                                                                <view>
                                                                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                                                                </view>
                                                                                <error-handler>
                                                                                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                                                                </error-handler>
                                                                            </dispatch>
                                                                        else if (helpers:contains-any-of($exist:path, $exist:sites) and not(ends-with($exist:resource, ".html|/"))) then
                                                                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                                    <forward url="{$exist:controller}/page/{$exist:resource}.html"/>
                                                                                    <view>
                                                                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                                                                    </view>
                                                                                    <error-handler>
                                                                                        <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                                                                    </error-handler>
                                                                                </dispatch>
                                                                        (:Suche:)
                                                                        else if (contains($exist:path, "search")) then
                                                                                if(request:get-parameter("orderBy", '') != "" )
                                                                                then
                                                                                    let $orderBy := request:get-parameter("orderBy", 'date')
                                                                                    return( search:profiresult(<node />, search:profisearch(<node />, map {"test" := "test"}, request:get-parameter("term",'')), "union",$orderBy))
                                                                                else
                                                                                    (session:clear(),
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
                                                                                    )
                                                                            else if(contains($exist:path, "download")) then
                                                                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                                        <forward url="{$exist:controller}/data/{$exist:resource}" />
                                                                                        <error-handler>
                                                                                            <forward url="{$exist:controller}/error-page.html" method="get"/>
                                                                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                                                                        </error-handler>
                                                                                    </dispatch>
                                                                                else if ( not(contains(substring-after($exist:path,"pessoa/"),"/")) and not(contains($exist:resource,".")) ) then
                                                                                         if( contains($exist:resource,"CP") or contains($exist:resource,"BNP")) then
                                                                                            let $id := $exist:resource
                                                                                            return
                                                                                                (session:set-attribute("id", $id),
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
                                                                                        else

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
                                                                                    else (: everything else is passed through :)
                                                                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                                                            <cache-control cache="yes"/>
                                                                                        </dispatch>
                        )
                        else if (contains($exist:path, "/$shared/")) then
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/../shared-resources/{substring-after($exist:path, '/$shared/')}">
                                        <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
                                    </forward>
                                </dispatch>
                            else if(contains($exist:path,"resources") or contains($exist:path,'templates')) then
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <cache-control cache="yes"/>
                                    </dispatch>
                                else

                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <redirect url="{$config:webapp-root}/{$helpers:web-language}/index.html?l=f&amp;p={local:pathi()}"/>
                                    </dispatch>
