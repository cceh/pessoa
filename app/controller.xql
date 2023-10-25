xquery version "3.1";
(:~
: Hautpmodul zur Kontrolle der URL-Weiterleitung und der Zugriffskontrolle von vorhandenen Resourcen
:
: @author Ben Bigalke, Ulrike Henny-Krahmer
: @version 1.0
:)

import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "modules/doc.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "modules/author.xqm";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "modules/search.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "modules/helpers.xqm";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "modules/config.xqm";
import module namespace index="http://localhost:8080/exist/apps/pessoa/index" at "modules/index.xqm";
import module namespace ownZip="http://localhost:8080/exist/apps/pessoa/zip" at "modules/zip.xq";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace sm = "http://exist-db.org/xquery/securitymanager";


declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $exist:lists := doc("/db/apps/pessoa/resources/lists.xml");
declare variable $exist:sites := (distinct-values($exist:lists//tei:list[@type="navigation"]//tei:item/tei:note[@type='directory']/data(.)));
declare variable $exist:authors := $exist:lists//tei:listPerson[@type="authors"]/tei:person/tei:note[@type='link']/data(.);
(:~
:Variable zur Abfrage ob ein Nutzer eingeloggt ist, wenn nicht, weiterleitung zur Zugriffssteuerung
: @see controller/local:Restriction
:)
declare variable $exist:permission := if(local:logged-in()) then true() else local:Restriction();

(:~
:
:)
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
    if (sm:get-user-groups(sm:id()//sm:real/sm:username/string()) = ("pessoa") ) then true() else false()
};

declare function local:Restriction() as xs:boolean{
    let $sites :=  ((for $s in ($exist:sites,"doc","pub") return concat($s,'/')),"search","timeline","network","events",'validation','works')
    return if(helpers:contains-any-of($exist:path,$sites)) then
        for $s in $sites
            let $p := replace($s,'/','')
            where contains($exist:path,$s)
            return switch($p)
                case "doc" return local:resRestriction()
                case "pub" return local:resRestriction()
                case "search" return true()
                case "timeline" return true()
                case "events" return true()
                case "network" return true()
                case "works" return true()
                case "genre" return local:DirRestriction($p)
                case "authors" return local:DirRestriction($p)
                case "validation" return true()
                default return
                    local:PathRestriction($sites)
    else false()
};

declare function local:PathRestriction($sites) as xs:boolean {
    if(helpers:contains-any-of($exist:path,$sites)) then
        for $s in $sites where contains($exist:path,$s) return
            if($s eq $exist:resource) then
                let $n := $exist:lists//tei:list[@type="navigation"]//tei:item[@xml:id eq $s]/tei:note[@type='published']/data(.)
                return if($n eq 'true') then true() else false()
            else
                let $n := $exist:lists//tei:list[@type="navigation"]//tei:item[@xml:id eq $exist:resource]/tei:note[@type='published']/data(.)
                return if($n eq 'true') then true() else false()
    else false()
};

declare function local:DirRestriction($id) as xs:boolean {
    let $n := $exist:lists//tei:list[@type="navigation"]//tei:item[@xml:id eq $id]/tei:note[@type='published']/data(.)
    return if($n eq 'true') then true() else false()
};

declare function local:pathi() {
    let $sites := ($exist:sites,"doc","pub","search","timeline-caeiro","timeline","BNP","CP","network")
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


declare function local:resRestriction() as xs:boolean {
    let $path := if(contains($exist:path,concat($helpers:web-language,'/')))
                    then substring-before(substring-after($exist:path,concat($helpers:web-language,'/')),'/')
                else if(helpers:contains-any-of($exist:path,('BNP','CP'))) then
                    'doc'
                else if(helpers:contains-any-of($exist:path,('/Caeiro_','/Pessoa_','/Campos_','/Reis_'))) then
                    'pub'
                else substring-before(substring-after($exist:path,'/'),'/')
    let $res := if(contains($exist:resource,".xml"))
                    then $exist:resource
                else if(contains($exist:path,'/doc/')) then
                    let $path := substring-after($exist:path,'/doc/')
                    let $de :=
                        if(contains($path,'/')) then substring-before($path,'/')
                        else $path
                    return concat($de,'.xml')
                else if(contains($exist:path,'/xml')) then concat(substring-after(substring-before($exist:path,concat('/',$exist:resource)),concat($path,'/')),'.xml')
                else if(helpers:contains-any-of($exist:path,('/diplomatic-transcription','/first-version','/last-version','/customized-version')))
                    then
                    let $pa := if(contains($exist:path,'BNP')) then substring-before($exist:path,'/BNP')
                                else substring-before($exist:path,'/CP')
                    let $p := substring-before(substring-after($exist:path,concat($pa,'/')),'/')
                    return concat($p,'.xml')
                        else concat($exist:resource,".xml")
    return if(doc(concat("/db/apps/pessoa/data/",$path,"/",$res))//tei:availability/@status eq "free")
                then true()
                else false()
};

(:#### No login required for what follows :)

session:create(),
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

else if ((contains($exist:resource, "network") or contains($exist:path,"network"))
            and not(helpers:contains-any-of($exist:resource,(".js",".css",".json")))) then
        (session:clear(),
        if(contains($exist:resource,'documentation')) then  (
            session:set-attribute('docu','true'),
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/page/network.html"/>
                <add-parameter name="docu" value="true" />
                <view>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
        )
        else
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
else if (contains($exist:path, "events")) then
        let $language := request:get-parameter("lang",'pt')
        let $events := concat("events",substring-before(substring-after($exist:path,"/events"),".xml"))
        let $style := concat("/db/apps/pessoa/xslt/",$events,".xsl")
        return
            transform:transform((collection("/db/apps/pessoa/data/doc")//tei:TEI | collection("/db/apps/pessoa/data/pub")//tei:TEI), doc($style), <parameters><param name="language" value="{$language}"/><param name="basepath" value="{$exist:controller}"></param></parameters>)
                        
else if ($exist:resource = "tei-odd") then
    doc("/db/apps/pessoa/data/schema/pessoaTEI.html")

else if (contains($exist:resource,".zip") ) then 
    ownZip:compress(substring-before($exist:resource,".zip"))

(: access to publications and documents that are freely available :)
else if($exist:permission) then (
    session:remove-attribute('type'),
    session:remove-attribute('author'),
    session:remove-attribute('textType'),
    session:remove-attribute('source'),

    (: documents :)
    if (contains($exist:path,  "/doc/")) then
        (: document, XML :)
        if ($exist:resource = "xml") then
            let $id := substring-before(substring-after($exist:path, "/doc/"), "/xml")
            return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/data/doc/{$id}.xml"/>
            </dispatch>
        (: document, different versions of transcription :)
        else if (helpers:contains-any-of($exist:path,("diplomatic-transcription","first-version","last-version"))) then
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
        (: document, default: diplomatic transcription :)
        else
            (session:set-attribute("id", $exist:resource),
            session:set-attribute("type", "diplomatic-transcription"),
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/page/doc.html">
                    <add-parameter name="id" value="{$exist:resource}" />
                    <add-parameter name="type" value="diplomatic-transcription" />
                </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>)
    (: publications :)
    else if (contains($exist:path, "/pub/")) then
        (: XML :)
        if ($exist:resource = "xml") then
            let $id := substring-before(substring-after($exist:path, "/pub/"), "/xml")
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/data/pub/{$id}.xml"/>
                </dispatch>
        (: default: publication view :)
        else
            let $pub-genre := doc(concat("/db/apps/pessoa/data/pub/", $exist:resource, ".xml"))//tei:note[@type='genre']/tei:rs[@type="genre"]/@key
            return
                if ($pub-genre = "prosa") then
                    (session:set-attribute("id", $exist:resource),
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/page/prosa.html">
                            <add-parameter name="id" value="{$exist:resource}" />
                        </forward>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </view>
                        <!-- 
                        <error-handler>
                            <forward url="{$exist:controller}/error-page.html" method="get"/>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </error-handler> -->
                    </dispatch>)
                (: default for publications: poesia :)
                else
                    (session:set-attribute("id", $exist:resource),
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/page/pub.html">
                            <add-parameter name="id" value="{$exist:resource}" />
                        </forward>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </view>
                        <!-- <error-handler>
                            <forward url="{$exist:controller}/error-page.html" method="get"/>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </error-handler> -->
                    </dispatch>)

    (: author pages :)
    else if (contains($exist:path, "/authors/")) then
        if (request:get-parameter("orderBy","")!="") then
            let $orderBy := request:get-parameter("orderBy", "alphab")
            let $author := substring-before(substring-after($exist:path, '/authors/'), '/')
            let $textType := $exist:resource
            return
                author:reorder(<node />, map {"test" : "test"},$orderBy, $textType, $author)
        else
            let $author := substring-before(substring-after($exist:path, '/authors/'), '/')
            let $textType := $exist:resource
            return
                (session:set-attribute("textType", $textType),
                session:set-attribute("author", $author),
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/page/authors.html" />
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/error-page.html" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>)
    (: genre pages :)
    else if(contains($exist:path, "genre") ) then
        if(request:get-parameter("orderBy",'') ) then
            let $orderBy := request:get-parameter("orderBy", '')
            let $type := $exist:resource
            return
                index:collectGenre(<node />, map {"test" : "test"}, $type, $orderBy)
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
    (: bibliography :)
    else if(contains($exist:path,"bibliography")) then
    let $type :=$exist:resource
    return (
        session:set-attribute("type",$type),
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/page/bibliography.html" />
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
            (:)
    else if (contains($exist:path,"timeline-caeiro") and not(contains($exist:path,'resources'))) then
        (
        if( not(contains($exist:path,$helpers:web-language))) then
            (
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <redirect url="{$config:app-root}/{$helpers:web-language}/timeline-caeiro" />
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
                    <forward url="{$exist:controller}/page/timeline-caeiro.html" />
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/error-page.html" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>)
                )
                :)
    (: timeline :)
    else if (contains($exist:path,"timeline") and not(contains($exist:path,'resources'))) then
        (
            let $timeline := concat("timeline",substring-after($exist:path,"/timeline"))
    
                return
    
            if( not(contains($exist:path,$helpers:web-language))) then
                (
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <redirect url="{$config:app-root}/{$helpers:web-language}/{$timeline}" />
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
                        <forward url="{$exist:controller}/page/{$timeline}.html" />
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </view>
                        <error-handler>
                            <forward url="{$exist:controller}/error-page.html" method="get"/>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </error-handler>
                    </dispatch>)
        )
    (: works :)
    else if (contains($exist:path,"works")) then
        (
            session:set-attribute("id",$exist:resource),
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/page/works.html" />
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
    (: search :)
    else if (contains($exist:path, "search")) then
        if(request:get-parameter("orderBy", '') != "" )
        then
         let $orderBy := request:get-parameter("orderBy", 'date')
         return( search:profiresult(<node />, search:profisearch(<node />, map {"test" : "test"}, request:get-parameter("term",'')), "union",$orderBy))
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
    (: html pages :)
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
    (: The following is for the About page, etc. :)
    else if (helpers:contains-any-of($exist:path, $exist:sites) and not(ends-with($exist:resource, ".html|/"))) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/page/{$exist:resource}.html"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
            <!--
            <error-handler>
                <forward url="{$exist:controller}/error-page.html" method="get"/>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </error-handler> -->
        </dispatch>
    (: download :)
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
        <redirect url="{$config:webapp-root}/{$helpers:web-language}/index.html?l=f&amp;p={$exist:path}"/>
    </dispatch>
