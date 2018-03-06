xquery version "3.0";
(:~
: Modul zur generierung der Navigation
; Beinhaltet allgemeine Funktionen
:
: @author Ben Bigalke
: @version 1.1
:)
module namespace page="http://localhost:8080/exist/apps/pessoa/page";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace app="http://localhost:8080/exist/apps/pessoa/templates" at "app.xql";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";

(:~
 : Funktion welche mehrdimensionale Maps erzeugt, indem es mehrfach die Funktion page:catchSub aufruft.
 : Anhand der Informationen die in lists.xml stehen, werden diese durch eine for Schleife an page:catchSub weitergegeben, welche weitere ebenen innerhalb der Maps erstellt
 : @return Mehrdimensionale Map
:)
declare function page:construct($node as node(), $model as map(*)){
    let $list := doc("/db/apps/pessoa/data/lists.xml")
    let $sites := for $item in $list//tei:list[@type="navigation"]/tei:item
                    let $sub := page:catchSub($list,$item)
                    let $publ := if(contains(string-join(distinct-values(for $s in $sub return $s("publ")),"-"),"true")) then "true" else "false"
                    return map {
                                "site" := $item/tei:term[@xml:lang = $helpers:web-language]/data(.),
                                "publ" := $publ,
                                "type" := $item/@rend/data(.),
                                "id" := $item/@xml:id/data(.),
                                "sub" := $sub
                            }
    return map {
            "sites" := $sites
    }

};
(:~
: Erstellt das Fenster innerhalb der Navigation für die Suche, beinhaltet aber auch die Javascript Funktion, womit der USER die Sprache auf der Website ändern kann
: @return  HTML Content
:)
declare function page:construct_search($node as node(), $model as map(*)) as node()* {
    let $search := <div class="container-4" id="searchbox" style="display:none">
        <input type="search" id="search" placeholder="{concat(helpers:singleElementInList_xQuery("search","term"),"....")}" />
        <span class="icon2" id="nav_searchButton" onclick="search()">{helpers:singleElementInList_xQuery("search","search_verb")}</span>
        <a class="small_text" id="search-link" href="{$helpers:app-root}/{$helpers:web-language}/search">{helpers:singleElementInList_xQuery("search","search_noun_ext")}</a>
    </div>
    let $clear :=  <div class="clear"></div>
    let $page := if(contains($helpers:request-path,concat('/',$helpers:web-language,'/')))
                    then substring-after($helpers:request-path,concat('/',$helpers:web-language,'/'))
                    else substring-after($helpers:request-path,concat($helpers:app-root,'/'))
    let $switchlang := if(contains($helpers:request-path,"search")) then
        <script>
            function switchlang(value){{

            location.href="{$helpers:app-root}/"+value+"/{$page}{page:search_SwitchLang()}";
            }}
        </script>
    else <script>
            function switchlang(value){{location.href="{$helpers:app-root}/"+value+"/{$page}";}}
        </script>
    return ($search,$clear,$switchlang, search:search-function())
};

declare function page:search_SwitchLang() as xs:string {
    let $return :=
        if(  request:get-parameter("search",'') = "simple") then
            string-join(("?term=",search:get-parameters("term"),"&amp;search=simple"),'')
        else string-join(("?term",substring-after(search:mergeParameters("html"),"term")),'')
    return $return
};

(:~
: Erstellt individuel die Maps die für die generierung der Navigation verantwortlich sind
: Prüft welchen Type die node() aus der lists.xml hat und verlinkt innerhalb der Website die erforderlichen Daten
:)
declare function page:catchSub($list as node(),$item as node()) as map(*)* {
    if(exists($item/@corresp)) then
        if($item/@corresp eq "authors") then
            for $per in $list//tei:listPerson[@type="authors"]/tei:person
                return map {
                            "site" := $per/tei:persName/data(.),
                            "publ" := $item/tei:note[@type='published']/data(.),
                            "type" := "link",
                            "id" := $per/@xml:id/data(.),
                            "link" := concat($item/tei:note[@type='directory']/data(.),"/",$per/tei:note[@type='link']/data(.),"/all")
                        }
        else if($item/@corresp eq "date") then page:DATEmapping($item/@xml:id/data(.))
        else
            for $el in $list//tei:list[@type=$item/@corresp]/tei:item
                        return map {
                                    "site" := $el/tei:term[@xml:lang = $helpers:web-language]/data(.),
                                    "publ" := $item/tei:note[@type='published']/data(.),
                                    "type" := "link",
                                    "id" := $el/@xml:id/data(.),
                                    "link" := concat($item/tei:note[@type='directory']/data(.),"/",$el/@xml:id/data(.))

                                    }
    else if(exists($item/tei:note[@type='linked'])) then
        if($item/tei:note[@type='linked'] eq "doclist") then
            let $dir := if($item/@xml:id eq "documentos") then "doc" else "pub"
                let $docs := doc("/db/apps/pessoa/data/doclist.xml")//docs[@dir = $dir]
                let $indis := distinct-values(for $doc in $docs/doc return $doc/@indi)
                    return for $indi in $indis
                            let $site := if($dir eq "pub") then $list//tei:listPerson/tei:person[@xml:id=$indi]/tei:persName/data(.) else $indi
                            let $sub := page:DOCmapping($docs,$indi,$dir)
                            let $publ := if(contains(string-join(distinct-values(for $s in $sub return $s("publ")),"-"),"free")) then "true" else "false"
                                    return map {
                                                    "site" := $site,
                                                    "publ" := $publ,
                                                    "type" := "button",
                                                    "id" := $indi,
                                                    "sub" := $sub
                                                }

            else if($item/tei:note[@type='linked'] eq "works") then
                let $works := doc("/db/apps/pessoa/data/works.xml")//list[@type="works"]
                return for $work in $works/item return map {
                                "site" := $work/title[@type="main"]/data(.),
                                "publ" := $item/tei:note[@type='published'],
                                "type" := "link",
                                "id" := $work/@xml:id,
                                "link" := concat("works/",$work/title[@type="main"]/data(.))
                }
        else()
    else for $el in $item/tei:list/tei:item return page:mapping($el)
};




declare function page:mapping($item as node()) as map(*){
    let $return :=
                map {
                    "site" := $item/tei:term[@xml:lang = $helpers:web-language]/data(.),
                    "publ" := $item/tei:note[@type='published']/data(.),
                    "type" := $item/@rend/data(.),
                    "id" := $item/@xml:id/data(.)
                }
    let $return := if(exists($item/tei:list) or exists($item/@corresp)) then map:new(($return,map {"sub" := page:catchSub(doc("/db/apps/pessoa/data/lists.xml"),$item)})) else $return
    let $return := if(exists($item/tei:note[@type='directory'])) then map:new(($return,map {"link" := concat($item/tei:note[@type='directory']/data(.),"/",$item/@xml:id/data(.))})) else $return
    let $return := if($item/@rend/data(.) = 'newlink') then map:new(($return,map {"link" := $item/@xml:id/data(.)})) else $return

    let $return := if(map:contains($return,"sub")) then
                        let $publ := if(contains(string-join(distinct-values(for $s in $return("sub") return $s("publ")),"-"),"true"))
                                        then "true" else "false"
                        let $new := map:remove($return,"publ")
                        return map:new(($new,map {"publ":=$publ}))
                    else $return
    return $return
};


declare function page:DOCmapping($docs as node(), $indi as xs:string,$dir as xs:string) as map(*)* {
   for $doc in $docs/doc where $doc/@indi eq $indi
   return
       let $name := $doc/data(.)
       let $name := if(contains($name,"BNP") or contains($name,"CP")) then
                   let $title :=
                       for $elem in doc(concat("/db/apps/pessoa/data/doc/",$name))//tei:titleStmt/tei:title/node() return
                           if(exists($elem/node()))
                           then <span class="doc_superscript">{$elem/node()/data(.)}</span>
                           else (
                               if(contains($elem,"BNP/E3")) then replace($elem,"BNP/E3 ","")
                               else if(contains($elem,"CP")) then replace($elem,"CP ","")
                               else $elem
                           )
                           let $title := ($title,<span class="doc_superscript"/>)
                           let $label := substring-before(replace($name,("BNP_E3_|CP"),""),".xml")
                           let $front := if(contains($label,"-")) then substring-before($label,"-") else $label
                           order by $front, xs:integer(replace($label, "^\d+[A-Z]?\d?-?([0-9]+).*$", "$1"))
                   return $title
                    else doc(concat("/db/apps/pessoa/data/pub/",$name))//tei:fileDesc/tei:titleStmt/tei:title/data(.)

       return map {
                "site" := $name,
                "publ" := $doc/@availability,
                "type" := "link",
                "id" := $doc/@id,
                "link" :=concat($dir,"/",$doc/@id)
       }
};

declare function page:DATEmapping($indi as xs:string) {
    let $from := xs:integer(substring-after(substring-before($indi,"_"),"D"))
    let $to := xs:integer(substring-after($indi,"_"))
    for $date in ($from to $to)
    let $sub := page:DATEDOCmapping($date)
    let $publ := if(contains(string-join(distinct-values(for $s in $sub return $s("publ")),"-"),"free")) then "true" else "false"
    return map {
            "site" := concat("'",$date),
            "publ" := $publ,
            "type" := "button",
            "id" := $date,
            "sub" := $sub

    }

};

declare function page:DATEDOCmapping($date as xs:integer) {
let $docs :=
    for $doc in doc("/db/apps/pessoa/data/doclist.xml")//doc
                for $d in (xs:integer($doc/@from) to xs:integer($doc/@to))
                where  $d eq xs:integer(concat("19",$date))
                return $doc
let $mapping := for $doc in $docs
                    let $name := $doc/data(.)
                    let $dir := if(contains($name,"BNP") or contains($name,"CP")) then "doc" else "pub"
                    let $title := if(contains($name,"BNP") or contains($name,"CP")) then
                        for $elem in doc(concat("/db/apps/pessoa/data/doc/",$name))//tei:titleStmt/tei:title/node() return
                            if(exists($elem/node()))
                                then <span class="doc_superscript">{$elem/node()/data(.)}</span>
                            else (
                                if(contains($elem,"BNP/E3")) then replace($elem,"BNP/E3 ","")
                                else if(contains($elem,"CP")) then replace($elem,"CP ","")
                                else $elem
                            )
                        else replace(replace(substring-before($name,".xml"),("Caeiro|Pessoa|Campos|Reis"),""),("-| |_")," ")
                    return map {
                    "site" := ($title,<span class="doc_superscript"/>),
                    "publ" := $doc/@availability,
                    "type" := "link",
                    "id" := $doc/@id,
                    "link" :=concat($dir, "/", $doc/@id)
                    }


return $mapping
};

declare function page:catchSiteHead($node as node(), $model as map(*), $container as xs:string) {
    let $site := $model($container)
        return
        if($site("publ") eq "free" or $site("publ") eq "true" or config:logged-in()) then
                if($site("type") eq "link") then
                    <li>
                        {attribute class {($node/@class),($site("type"))}}
                        {attribute published {$site("publ")}}
                        <a href="{concat($helpers:app-root,"/",$helpers:web-language,"/",$site("link"))}">
                            <span>{$site("site")}</span>
                        </a>
                        {templates:process($node/node(), $model)}
                    </li>
                else if($site("type") eq "newlink") then
                    <li>
                        {attribute class {($node/@class),($site("type"))}}
                        {attribute published {$site("publ")}}
                        <a href="{concat($helpers:app-root,"/",$helpers:web-language,"/",$site("link"))}" target='_blank'>
                            <span>{$site("site")}</span>
                        </a>
                        {templates:process($node/node(), $model)}
                    </li>
                else
                    <li>
                        {attribute class {($node/@class),($site("type"))}}
                        {attribute active {$node/@active}}
                        {attribute published {$site("publ")}}
                        <span>{$site("site")}</span>
                        {templates:process($node/node(), $model)}
                    </li>
        else
                <li>
                    {attribute class {($node/@class),("restricted")}}
                    {attribute active {$node/@active}}
                    <span>{$site("site")}</span>
                    {templates:process($node/node(), $model)}
                </li>
};

(:###### CALL LIST ELEMENTS ######:)

(:###### TIMELINE ######:)
declare %templates:wrap function page:createTimelineBody($node as node(), $model as map(*)) as node()* {
    let $headline := helpers:singleElementInList_xQuery("timeline","timeline_title")


    let $body := <body onload="onLoad();" onresize="onResize();">
        <h1><u>{$headline}</u></h1>

        <div id="my-timeline" style="height: 1500px; border: 1px solid #aaa; border-radius: 10px;" ></div>
    </body>

    return  $body
};

declare function page:createTimelineHeader($node as node(), $model as map(*)) as node()* {
    let $lists := doc('/db/apps/pessoa/data/lists.xml')

        let $script1:=
        <script>
        Timeline_ajax_url="{$helpers:app-root}/resources/timeline/timeline_ajax/simile-ajax-api.js";
        Timeline_urlPrefix='{$helpers:app-root}/resources/timeline/timeline_js/';
        Timeline_parameters='bundle=true';
        </script>
    let $script2 :=
        <script src="{concat($helpers:app-root,'/resources/timeline/timeline_js/timeline-api.js')}"
         type="text/javascript">
       </script>
    let $script3 := <script type="text/javascript">
        var tl;
        function onLoad() {{
        var eventSource = new Timeline.DefaultEventSource(0);

        var theme = Timeline.ClassicTheme.create();
        theme.event.bubble.width = 300;
        theme.event.bubble.height = 150;
        theme.event.tape.height = 10;
        theme.event.track.gap = -7;

        var data = Timeline.DateTime.parseGregorianDateTime("Oct 02 1921")
        var bandInfos = [
        Timeline.createBandInfo({{
        width:          "3%",
        intervalUnit:   Timeline.DateTime.DECADE,
        intervalPixels: 800,
        date:           data,
        showEventText:  false,
        theme:          theme
        }}),

        Timeline.createBandInfo({{
        width:          "3%",
        intervalUnit:   Timeline.DateTime.YEAR,
        intervalPixels: 80,
        date:           data,
        showEventText:  false,
        theme:          theme

        }}),

        Timeline.createBandInfo({{
        width:          "94%",
        intervalUnit:   Timeline.DateTime.YEAR,
        intervalPixels: 80,
        eventSource:    eventSource,
        date:           data,
        position:       false,
        theme:          theme

        }})
        ];
        bandInfos[0].etherPainter = new Timeline.YearCountEtherPainter({{
        startDate:  "Jun 13 1888 ",
        multiple:   1,
        theme:      theme
        }});

        bandInfos[0].syncWith = 2;
        bandInfos[1].syncWith = 2;
        bandInfos[1].highlight = false;
        bandInfos[0].decorators = [
        new Timeline.SpanHighlightDecorator({{
        startDate:  "Jun 13 1888 ",
        endDate:    "Nov 30 1935 ",
        startLabel: "{helpers:singleElementInList_xQuery("timeline","birth")}",
        endLabel:   "{helpers:singleElementInList_xQuery("timeline","death")}",
        color:      "#B8B8E6",
        opacity:    50,
        theme:      theme
        }})
        ];

        tl = Timeline.create(document.getElementById("my-timeline"), bandInfos, Timeline.HORIZONTAL);
        tl.loadXML("../events.xml?lang={$helpers:web-language}", function(xml, url) {{
        eventSource.loadXML(xml, url);
        }});
        }}
    </script>
    return ($script1,$script2,$script3)
};

(: ########### Special timeline: Caeiro ##############:)
declare function page:createTimelineHeader_Caeiro($node as node(), $model as map(*)) as node()* {
    let $lists := doc('/db/apps/pessoa/data/lists.xml')

        let $script1:=
        <script>
        Timeline_ajax_url="{$helpers:app-root}/resources/timeline/timeline_ajax/simile-ajax-api.js";
        Timeline_urlPrefix='{$helpers:app-root}/resources/timeline/timeline_js/';
        Timeline_parameters='bundle=true';
        </script>
    let $script2 :=
        <script src="{concat($helpers:app-root,'/resources/timeline/timeline_js/timeline-api.js')}"
         type="text/javascript">
       </script>
    let $script3 := <script type="text/javascript">
        var tl;
        function onLoad() {{
        var eventSource = new Timeline.DefaultEventSource(0);
        var eventSource2 = new Timeline.DefaultEventSource(0);

        var theme = Timeline.ClassicTheme.create();
        theme.event.bubble.width = 300;
        theme.event.bubble.height = 50;
        theme.event.tape.height = 10;
        theme.event.track.gap = -7;

        var data = Timeline.DateTime.parseGregorianDateTime("Oct 02 1917")
        var bandInfos = [
        Timeline.createBandInfo({{
        width:          "5%",
        intervalUnit:   Timeline.DateTime.DECADE,
        intervalPixels: 2000,
        date:           data,
        showEventText:  false,
        theme:          theme
        }}),

        Timeline.createBandInfo({{
        width:          "5%",
        intervalUnit:   Timeline.DateTime.YEAR,
        intervalPixels: 200,
        date:           data,
        showEventText:  false,
        theme:          theme

        }}),

        Timeline.createBandInfo({{
        width:          "10%",
        intervalUnit:   Timeline.DateTime.YEAR,
        intervalPixels: 200,
        eventSource:   eventSource2,
        date:           data,
        position:       false,
        theme:          theme

        }}),
        
        Timeline.createBandInfo({{
        width:          "75%",
        intervalUnit:   Timeline.DateTime.YEAR,
        intervalPixels: 200,
        eventSource:    eventSource,
        date:           data,
        position:       false,
        theme:          theme

        }})
        
        
        ];
        bandInfos[0].etherPainter = new Timeline.YearCountEtherPainter({{
        startDate:  "Jun 13 1888",
        multiple:   1,
        theme:      theme
        }});

        bandInfos[0].syncWith = 3;
        bandInfos[1].syncWith = 3;
        bandInfos[2].syncWith = 3;
        bandInfos[1].highlight = false;
        bandInfos[0].decorators = [
        new Timeline.SpanHighlightDecorator({{
        startDate:  "Jun 13 1888",
        endDate:    "Nov 30 1935",
        startLabel: "{helpers:singleElementInList_xQuery("timeline","birth")}",
        endLabel:   "{helpers:singleElementInList_xQuery("timeline","death")}",
        color:      "#B8B8E6",
        opacity:    50,
        theme:      theme
        }})
        ];

        tl = Timeline.create(document.getElementById("my-timeline"), bandInfos, Timeline.HORIZONTAL);
        tl.loadXML("../events-caeiro.xml?lang={$helpers:web-language}", function(xml, url) {{
            eventSource.loadXML(xml, url);
        }});
        tl.loadXML("../events-collections.xml?lang={$helpers:web-language}", function(xml, url) {{
            eventSource2.loadXML(xml, url);
        }});
        }}
    </script>
    return ($script1,$script2,$script3)
};


(: ########### Zitation ##############:)
declare function page:cite($node as node(), $model as map(*), $source as xs:string?, $type as xs:string?, $author as xs:string?,$textType as xs:string?) {
    let $link := if($source eq '/project') then concat($helpers:app-root,'/',$helpers:web-language,$source)
        else concat($helpers:app-root,$source)
    let $link := if($type != "") then concat($link,'/',$type)
                else if($author != "") then
                    if($textType != 'all') then concat($link,'/',$author,'/',$textType)
                    else concat($link,'/',$author)
                else $link
        return
            <span id="p-cite"> {for $elem in helpers:singleElementNode_xquery("cite","cite-sd")/tei:span
    return
        switch($elem/@type)
            case "web" return <i>{helpers:singleElementInList_xQuery("cite","cite-web")}</i>
            case "url" return <a href="{$link}">{concat("<",$link,">")
            }</a>
            default return $elem
    }</span>
};


(:
       {replace(replace(helpers:singleElement_xquery("cite","cite-sd"),"#URL#",concat("<",$helpers:app-root,$source,">")),"#WEB#",$web)}:)