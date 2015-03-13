xquery version "3.0";

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

declare %templates:wrap function page:construct($node as node(), $model as map(*)) as node()* {
    let $MainNav :=                
            <ul id="navi-elements" >
                {page:createMainNav()}
                <li>                    
                 <a href="#" class="glyphicon glyphicon-search" onclick="hide('searchbox')" role="tab" data-toggle="tab"></a>                     
                </li>
            </ul>
    let $SubNav := page:createSubNav()

    
    let $return := ($MainNav, $SubNav)
    return $return
};
declare %templates:wrap function page:construct_search($node as node(), $model as map(*)) as node()* {
let $search := <div class="container-4" id="searchbox" style="display:none">
                            <input type="search" id="search" placeholder="{concat(page:singleAttribute(doc("/db/apps/pessoa/data/lists.xml"),"search","search_verb"),"....")}" />
                            <button class="icon" id="button" onclick="search()"><i class="fa fa-search" ></i>
                                </button>
                        </div>      
    let $clear :=  <div class="clear"></div>
    let $switchlang := <script>
        function switchlang(value){{location.href="{concat($helpers:app-root,substring-after($helpers:request-path,"pessoa/"))}?plang="+value;}}
    </script>
    return ($search,$clear,$switchlang)
};


declare function page:createMainNav() as node()* {
let $type := ("autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto")
let $doc := doc("/db/apps/pessoa/data/lists.xml")
for $target in $type 
    let $name := if($helpers:web-language = "pt") then $doc//tei:term[@xml:lang = $helpers:web-language and @xml:id= $target]
                                  else $doc//tei:term[@xml:lang = $helpers:web-language and @corresp= concat("#",$target)]
    
  return <li><a href="#{$target}" role="tab" data-toggle="tab" onClick="u_nav({concat("'","nav_",$target,"'")})">{$name}</a></li>
};



declare function page:createSubNav() as node()* {
    let $lists := doc("/db/apps/pessoa/data/lists.xml")
    for $tab in  $lists//tei:list[@type="navigation"]/tei:item/tei:term[@xml:lang="pt"]/attribute()[2]
        return page:createSubNavTabs($tab)
};

declare function page:createSubNavTabs($tab as xs:string) as node()* {
    let $SubNav := 
        <div class="navbar" id="{concat("nav_",$tab)}"  style="display:none"> 
            <ul class="nav_tabs">
            {page:createContent($tab)}
            </ul>
        </div>
    let $ThirdNav := if($tab = "documentos" or $tab = "cronologia") then
            <div class="navbar" id="{concat("nav_",$tab,"_sub")}" style="display:none" > 
                {page:createThirdNavTab($tab)}
            </div>
            else ()
        return ($SubNav,$ThirdNav)
};
declare function page:createContent($type as xs:string) as node()* {
    if($type != "documentos" and $type != "cronologia") then
        for $item in page:createItem($type,"")
        return <li class="{concat("nav_",$type,"_tab")}" ><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
    else  let $result := page:createThirdNav($type)
    return $result
};


declare function page:createThirdNav($type as xs:string) as node()* {
    if($type ="documentos") then
        for $nr in (1 to 9)
        return <li  class="{concat("nav_",$type,"_tab")}">
            <a href="#"  
            onclick="u_nav({concat("'nav_",$type,"_sub_",$nr,"'")})">
            {concat($nr,"0")}
            </a></li>
    else if ($type = "cronologia") then for $date in ("1900 - 1909","1910 - 1919","1920 - 1929","1930 - 1935",(doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item[5]/tei:list/tei:item/tei:term[@xml:lang=$helpers:web-language]/attribute()[2]))
            return if ($date = "timeline" or $date = "#timeline") then
                <li class="{concat("nav_",$type,"_tab")}">
                <a href="{concat($helpers:app-root,"/timeline.html?plang=",$helpers:web-language)}">
                {doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item[5]/tei:list/tei:item/tei:term[@xml:lang=$helpers:web-language]/data(.)}
                </a></li>
            else if(substring-after($date,"19")!= "") then  <li class="{concat("nav_",$type,"_tab")}">
                <a href="#" 
                onclick="u_nav({concat("'nav_",$type,"_sub_",(index-of(("1900 - 1909","1910 - 1919","1920 - 1929","1930 - 1935"),$date)-1),"'")})">
                {$date}
                </a></li>
                else ()
        else ()
};

declare function page:createThirdNavTab($type as xs:string) as node()* {
   if ($type = "documentos") then for $indikator in (1 to 9) return
    <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
    <ul class="nav_sub_tabs">
    {page:createThirdNavContent($type,$indikator)}
         </ul>   </div>
    else if ($type = "cronologia") then for $indikator in (0 to 3) return 
         <div  id="{concat("nav_",$type,"_sub_",$indikator)}" style="display:none"> 
         <ul class="nav_sub_tabs">        
        {page:createThirdNavContent($type,$indikator)}
        </ul></div>
     else ()
};

declare function page:createThirdNavContent($type as xs:string, $indikator as xs:string) as node()* {
        if ($type = "documentos") then for $item in page:createItem($type, $indikator) 
            return <li class="{concat("nav_",$type,"_sub_tab")}"><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
        else if ($type = "cronologia") then for $item in page:createItem($type,$indikator)
            return <li class="{concat("nav_",$type,"_sub_tab")}"><a href="{$item/@ref/data(.)}">{$item/@label/data(.)}</a></li>
           else ()
};


declare function page:createItem($type as xs:string, $indikator as xs:string?) as item()* {
    if($type ="autores")
        then for $pers in doc("/db/apps/pessoa/data/lists.xml")//tei:listPerson[@type="authors"]/tei:person/tei:persName/data(.)
             order by $pers collation "?lang=pt"
             return <item label="{$pers}" ref="{$helpers:app-root}/author/{tokenize(lower-case($pers), '\s')[last()]}/all" /> 
   else if($type = "genero") 
        then for $genre in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="genres"][@xml:lang=$helpers:web-language]/tei:item   
            let $label :=$genre/data(.)
            let $ref := if($helpers:web-language = "pt") then $genre/attribute()
                        else substring-after($genre/attribute(), "#")
            order by $genre collation "?lang=pt" 
            return <item label="{$label}"  ref="{$helpers:app-root}/page/genre_{$ref}.html" /> 
   else if($type = "documentos") 
        then for $hit in xmldb:get-child-resources("/db/apps/pessoa/data/doc")
            let $label :=   if(substring-after($hit, "BNP_E3_") != "") then substring-after(replace(substring-before($hit, ".xml"), "_", " "), "BNP E3 ")
                            else if(substring-after($hit,"MN") != "") then substring-after(replace(substring-before($hit, ".xml"), "_", " "), "MN")
                            else ()
                let $ref := concat($helpers:app-root, "/doc/", substring-before($hit, ".xml"))         
                      order by $hit collation "?lang=pt" 
                      return if(substring-after(replace(substring-before($hit, ".xml"), "_", " "), concat("BNP E3 ",$indikator)) 
                      or 
                      substring-after(replace(substring-before($hit, ".xml"), "_", " "), concat("MN",$indikator))) then
                      <item label="{$label}" ref="{$ref}?plang={$helpers:web-language}"  />
                      else ()
   else if($type = "cronologia")
        then for $date in (xs:integer(concat("19",$indikator,"0")) to xs:integer(concat("19",$indikator,"9")))
        for $para in ("date","date_when","date_notBefore","date_notAfter","date_from","date_to")
                let $db := collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                let $result := search:result_union(search:date_search($db,$para,$date))
                for $hit in $result
                    let $label := if(substring-after(root($hit)/util:document-name(.), "BNP") != "") then 
                                    substring-after(replace(substring-before(root($hit)/util:document-name(.), ".xml"), "_", " "), "E3")
                                  else if(substring-after(root($hit)/util:document-name(.),"MN") != "") then 
                                    substring-after(replace(substring-before(root($hit)/util:document-name(.), ".xml"), "_", " "), "MN")
                                  else if(page:clearPublikation($hit) != "") then page:clearPublikation($hit) (:
                                  if(    substring-after(root($hit)/util:document-name(.),"Caeiro") != "" 
                                           or substring-after(root($hit)/util:document-name(.),"Pessoa") != "" 
                                           or substring-after(root($hit)/util:document-name(.),"Campos") != ""
                                           or substring-after(root($hit)/util:document-name(.),"Reis") != "")
                                           then substring-after(replace(substring-before(root($hit)/util:document-name(.),".xml"),"-", " "),"_"):)
                                  else ()
                    let $ref := if(substring-after(root($hit)/util:document-name(.),"BNP")!= "" or substring-after(root($hit)/util:document-name(.),"MN")!= "") 
                    then  concat($helpers:app-root, "/doc/", substring-before(root($hit)/util:document-name(.), ".xml"))
                    else concat($helpers:app-root, "/pub/", substring-before(root($hit)/util:document-name(.), ".xml"))
                return <item label="{$label}" ref="{$ref}"/>
   else if ($type ="bibliografia")
        then for $bibl in doc("/db/apps/pessoa/data/lists.xml")//tei:list[@type="navigation"]/tei:item[6]/tei:list/tei:item/tei:term[@xml:lang=$helpers:web-language]   
            let $label :=$bibl/data(.)
            let $ref := if($helpers:web-language = "pt") then $bibl/attribute()[2]
                        else substring-after($bibl/attribute()[2],"#")
            return <item label="{$label}"  ref="{$helpers:app-root}/page/bibliografia.html?type={$ref}" /> 
   else for $a in "10" return <item label="nothin" ref="#"/>
};

declare function page:clearPublikation($pub as node()) as xs:string {
    for $author in ("Caeiro","Pessoa","Campos","Reis")
     return   if(substring-after(root($pub)/util:document-name(.),$author) != "")
            then substring-after(replace(replace(substring-before(root($pub)/util:document-name(.),".xml"),"-", " "),"_"," "),$author)
            else ()
};


(:###### SEARCH PAGE ######:)

declare %templates:wrap function page:singleElement($node as node(), $model as map(*),$xmltype as xs:string,$xmlid as xs:string) as xs:string? {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')    
    return page:singleAttribute($doc,$xmltype,$xmlid)     
};

declare function page:singleAttribute($doc as node(),$type as xs:string,$id as xs:string) as xs:string? {
    let $entry := if($helpers:web-language = "pt") 
                  then $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
     return $entry/data(.)
};
(:
declare function page:page_singeAttribute_term($doc as node(),$type as xs:string,$id as xs:string, $lang as xs:string) as node()? {
    let $entry := if($lang = "pt") 
                  then $doc//tei:list[@type=$type]/tei:term[@xml:lang=$lang and @xml:id=$id]
                  else $doc//tei:list[@type=$type]/tei:term[@xml:lang=$lang and @corresp=concat("#",$id)]
     return $entry
};
:)
declare function page:createInput_item($xmltype as xs:string,$btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node()) as node()* {
    for $id in $value
        let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]
        let $input := <input type="{$btype}" name="{$name}" value="{$id}" id="{$id}"/>
        let $label := <label for="{$id}">{$entry}</label>
        return ($input,$label)
};

declare function page:createInput_term($xmltype as xs:string, $btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node(), $checked as xs:string?) as node()* {
    for $id in $value
        let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$helpers:web-language and @xml:id=$id]
                      else $doc//tei:list[@type=$xmltype]/tei:item/tei:term[@xml:lang=$helpers:web-language and @corresp=concat("#",$id)]
        let $input := if($checked = "checked") then <input type="{$btype}" name="{$name}" value="{$id}" id="{$id}" checked="checked"/>
                       else <input type="{$btype}" name="{$name}" value="{$id}" id="{$id}" />
        let $label := <label for="{$id}">{$entry}</label>
        return ($input,$label)
};

declare function page:createOption($xmltype as xs:string, $value as xs:string*,$doc as node()) as node()* {
    for $id in $value
         let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]
        return <option value="{$id}">{$entry}</option>

};

(:###### TIMELINE ######:)
declare %templates:wrap function page:createTimelineBody($node as node(), $model as map(*)) as node()* {
    let $lists := doc('/db/apps/pessoa/data/lists.xml')    
    let $headline := page:singleAttribute($lists,"timeline","timeline_title")
    
    
    let $body := <body onload="onLoad();" onresize="onResize();">
         
        <h2>{$headline}</h2>
        <div id="my-timeline" style="height: 1300px; border: 1px solid #aaa; border-radius: 10px;" ></div>
        </body>
    
    return  $body
};

declare %templates:wrap function page:createTimelineHeader($node as node(), $model as map(*)) as node()* {
let $lists := doc('/db/apps/pessoa/data/lists.xml') 
let $title := <title>{$lists//tei:list[@type="navigation"]/tei:item[5]/tei:list/tei:item/tei:term[@xml:lang=$helpers:web-language]/data(.)}</title>
let $meta := <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
let $style := <style type="text/css">
         body {{
         font-family: sans-serif;
         font-size: 8pt;
		 
         }}
 #my-timeline {{
 overflow: no;
 }}
.tape-special_event {{  margin-top: 12px; }}
.simile {{
width: 1800px;
}}
      </style>

let $script1 := 
      <script type="text/javascript">
      Timeline_ajax_url="{concat($helpers:app-root,"/resources/js/timeline_2.3.0/timeline_ajax/simile-ajax-api.js")}";
      Timeline_urlPrefix='{concat($helpers:app-root,"/resources/js/timeline_2.3.0/timeline_js/")}';       
      Timeline_parameters='bundle=true';
    </script>
  let $script2 :=  <script src="{concat($helpers:app-root,"/resources/js/timeline_2.3.0/timeline_js/timeline-api.js")}"    
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
			
            theme.ether.backgroundColors[1] = theme.ether.backgroundColors[0];
            var data = Timeline.DateTime.parseGregorianDateTime("Oct 02 1894")
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
                    width:          "97%", 
                    intervalUnit:   Timeline.DateTime.YEAR, 
                    intervalPixels: 80,
                    eventSource:    eventSource,
                    date:           data,
                    theme:          theme
				
               }})
            ];
            bandInfos[0].etherPainter = new Timeline.YearCountEtherPainter({{
                startDate:  "Jun 13 1888 ",
                multiple:   1,
                theme:      theme
            }});
			
			
			
			
            bandInfos[0].syncWith = 1;
            bandInfos[0].highlight = false;
            bandInfos[0].decorators = [
                new Timeline.SpanHighlightDecorator({{
                    startDate:  "Jun 13 1888 ",
                    endDate:    "Nov 30 1935 ",
                    startLabel: "{page:singleAttribute($lists,"timeline","birth")}",
                    endLabel:   "{page:singleAttribute($lists,"timeline","death")}",
                    color:      "#B8B8E6",
                    opacity:    50,
                    theme:      theme
               }})
            ];
            			
			
			
            tl = Timeline.create(document.getElementById("my-timeline"), bandInfos, Timeline.HORIZONTAL);
            tl.loadXML("{concat($helpers:app-root,"/events?lang=",$helpers:web-language)}", function(xml, url) {{
                eventSource.loadXML(xml, url);
            }});
        }}
				
		
        var resizeTimerID = null;
        function onResize() {{
            if (resizeTimerID == null) {{
                resizeTimerID = window.setTimeout(function() {{
                    resizeTimerID = null;
                    tl.layout();
              }}, 500);
           }}
       }}
    </script>		
    return ($title,$meta,$style,$script1, $script2, $script3)
};

declare %templates:wrap function page:docControll($node as node(), $model as map(*)) {
    let $db := collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
    let $doc := if(substring-after($helpers:request-path,"doc/")) 
                    then substring-after($helpers:request-path,"doc/")
                else substring-after($helpers:request-path,"pub")
    let $index := index-of($db,doc(concat("/db/apps/pessoa/data/doc/",$doc,".xml")))    
    let $libary :=  if(substring-after($helpers:request-path,"doc/")) 
                    then "doc"
                else "pub"
    let $arrows := <div>
                            <a href="{concat($helpers:app-root,'/',$libary,'/',substring-before(root($db[position() = (($index) -1)])/util:document-name(.),".xml"),"?plang=",$helpers:web-language)}">
                                <span id="back"> 
                                    Back 
                                </span>
                            </a>
                            <a href="{concat($helpers:app-root,'/',$libary,'/',substring-before(root($db[position() = (($index) +1)])/util:document-name(.),".xml"),"?plang=",$helpers:web-language)}">
                                <span id="forward">
                                    Forward
                                </span>
                            </a>
                            <div class="clear"></div>
                    </div>
    return $arrows
};