xquery version "3.0";

module namespace search="http://localhost:8080/exist/apps/pessoa/search";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "author.xqm";

import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(:  Profi Suche :)
declare %templates:wrap function search:profisearch($node as node(), $model as map(*), $term as xs:string?) as map(*) {
        (: Erstellung der Kollektion, sortiert ob "Publiziert" oder "Nicht Publiziert" :)
        let $db := search:set_db()
        let $dbase :=  if($term != "" ) then collection($db)//tei:TEI[ft:query(.,$term)]
                       else if(search:get-parameters("lang_ao") = "or") 
                       then search:lang_or($db)
                       else search:lang_and($db)
        (: Unterscheidung nach den Sprachen, ob "Und" oder "ODER" :)
       let $r_lang := if($term != "" and search:get-parameters("search")!= "simple") then 
                      if (search:get-parameters("lang_ao") ="or")
                        then search:lang_or_term($dbase)
                        else (search:lang_and_term($dbase,"unpublished"),search:lang_and_term($dbase,"published"))
                      else $dbase
        let $dbase := $r_lang
        (: Sortierung nach Genre :)
        let $r_genre := if(search:get-parameters("genre")!="") then search:search_range("genre",$dbase)
                        else $dbase                   
        let $dbase := $r_genre
        (:Suche nach "Erwähnten" Rollen:)
        let $r_mention := if(search:get-parameters("person")!="") then search:author_build($dbase)
                        else $dbase
        let $dbase := $r_mention
      (:  let $r_real := if(search:get-parameters("notional") ="real" and search:get-parameters("person")!="") then search:search_range("person",$dbase)
                        else $dbase
        let $dbase := $r_real                
     :)
        (: Datumssuche :)
        let $r_date := if(search:get-parameters("to") != "" or search:get-parameters("from") != "") then search:date_build($dbase)
                        else $dbase
        let $dbase := $r_date
        (: Volltext Suche :)                
      (:  let $r_all := ($r_genre,$r_mention,$r_date) :)
       
        return map{
            "r_union"   := search:result_union($dbase),
            (:"r_dbase"   := $dbase,:)
            "query"     := $term
        }
        
};




declare function search:set_db() as xs:string+ {
        let $result :=       if(search:get-parameters("release") = "unpublished")    then "/db/apps/pessoa/data/doc"
                             else if(search:get-parameters("release") = "published" )  then "/db/apps/pessoa/data/pub"
                             else ("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                            
                   return $result
};

(: Funtkion um die Parameter rauszufiltern:)
declare function search:get-parameters($key as xs:string) as xs:string* {
    for $hit in request:get-parameter-names()
        return if($hit=$key) then request:get-parameter($hit,'')
                else ()
};

declare function search:mergeParameters ($type as xs:string) as xs:string {
    let $code := if($type = "html") then "&amp;" else "/"
    let $term := concat($code,"term=",search:get-parameters("term"))
    let $after := concat($code,"from=",search:get-parameters("from"))
    let $before := concat($code,"to=",search:get-parameters("to"))
    let $lang := for $slang in search:get-parameters("lang") return
                concat($code,"lang=", $slang)
    let $lang_ao := concat($code,"lang_ao=",search:get-parameters("lang_ao"))
    let $person := for $sperson in search:get-parameters("person") return
                concat($code,"person=",$sperson)
    let $genre := for $sgenre in search:get-parameters("genre") return
                concat($code,"genre=",$sgenre)
    let $role := for $srole in search:get-parameters("role") return
                concat($code,"role=",$srole)
    let $release := concat($code,"release=",search:get-parameters("release"))
    return string-join(($term,$after,$before,$lang,$lang_ao,$person,$genre,$role,$release),'')
};

declare function search:mergeParameters_xquery ($type as xs:string) as xs:string* {
    let $code := if($type = "html") then "&amp;" else "/"
    let $term := concat($code,"term=",search:get-parameters("term"))
    let $after := concat($code,"from=",search:get-parameters("from"))
    let $before := concat($code,"to=",search:get-parameters("to"))
    let $lang := for $slang in search:get-parameters("lang") return
                concat($code,"lang=", $slang)
    let $lang_ao := concat($code,"lang_ao=",search:get-parameters("lang_ao"))
    let $person := for $sperson in search:get-parameters("person") return
                concat($code,"person=",$sperson)
    let $genre := for $sgenre in search:get-parameters("genre") return
                concat($code,"genre=",$sgenre)
    let $role := for $srole in search:get-parameters("role") return
                concat($code,"role=",$srole)
    let $release := concat($code,"release=",search:get-parameters("release"))
    return ($term,$after,$before,$lang,$lang_ao,$person,$genre,$role,$release)
};
(: ODER FUNKTION : FIltert die Sprache, TERM :)
declare function search:lang_or_term($db as node()*) as node()* {
    for $hit in search:get-parameters("lang")
        let $para := ("mainLang","otherLang","Lang")
        for $match in $para
                let $search_terms := concat('("',$match,'"),"',$hit,'"')
                let $search_funk := concat("//range:field-contains(",$search_terms,")")
                let $search_build := concat("$db",$search_funk)
            return util:eval($search_build)
};

(: UND FUNKTION : Filtert die Sprache, TERM:)

declare function search:lang_and_term($db as node()*, $step as xs:string) as node()* {
        if(search:get-parameters("release")="unpublished" and $step = "unpublished") then
            for $match in search:lang_build_para_doc("lang")
                let $build_funk := concat("//range:field-contains(",$match,")")
                let $build_search := concat("$db",$build_funk) 
                return util:eval($build_search) 
        else if (search:get-parameters("release")="published" and $step = "published") then 
            for $match in search:get-parameters("lang")
            let $build_funk := concat("//range:field-contains('lang','",$match,"')")
            let $build_search := concat("$db",$build_funk)
            return util:eval($build_search)  
        else ()
};
(: ODER FUNTKION : Filtert die Sprache :) 
declare function search:lang_or ($db as xs:string+) as node()*{
    for $match in $db
        let $result := if(search:get-parameters("release") != "all") then  search:lang_filter_or($match,"")
                      else if(search:get-parameters("release") = "all") then 
                            if($match = "/db/apps/pessoa/data/doc") then search:lang_filter_or($match,"unpublished")
                            else if ($match = "/db/apps/pessoa/data/pub") then search:lang_filter_or($match, "published")
                            else()
                       else ()
        return $result
};

declare function search:lang_filter_or($db as xs:string, $step as xs:string?) as node()* {
    if(search:get-parameters("release")="unpublished" or $step = "unpublished") then
        for $hit in search:get-parameters("lang")
            let $para := ("mainLang","otherLang")
            for $match in $para
                let $search_terms := concat('("',$match,'"),"',$hit,'"')
                let $search_funk := concat("//range:field-contains(",$search_terms,")")
                let $search_build := concat("collection($db)",$search_funk)
            return util:eval($search_build) 
        else if (search:get-parameters("release")="published" or $step = "published") then 
            for $hit in search:get-parameters("lang")
                let $search_terms := concat('("lang"),"',$hit,'"')
                let $search_funk := concat("//range:field-contains(",$search_terms,")")
                let $search_build := concat("collection($db)",$search_funk)
            return util:eval($search_build) 
        else ()
};

(: START UND FUNKTION : Filtert die Sprache :)

declare function search:lang_and($db as xs:string+) as node()* {
    for $match in $db 
        let $result := if(search:get-parameters("release") != "all") then  search:lang_filter_and($match,"")
                      else if(search:get-parameters("release") = "all") then 
                            if($match = "/db/apps/pessoa/data/doc") then search:lang_filter_and($match,"unpublished")
                            else if ($match = "/db/apps/pessoa/data/pub") then search:lang_filter_and($match, "published")
                            else()
                       else ()
                       (:(search:lang_filter_and($match,"non_public"),search:lang_filter_and($match, "public")):)
        return $result
};

declare function search:lang_filter_and($db as xs:string, $step as xs:string?) as node()* {
        if(search:get-parameters("release")="unpublished" or $step = "unpublished") then
            for $match in search:lang_build_para_doc("lang")
                let $build_funk := concat("//range:field-contains(",$match,")")
                let $build_search := concat("collection($db)",$build_funk) 
                return util:eval($build_search) 
        else if (search:get-parameters("release")="published" or $step = "published") then 
            for $match in search:get-parameters("lang")
            let $build_funk := concat("//range:field-contains('lang','",$match,"')")
            let $build_search := concat("collection($db)",$build_funk)
            return util:eval($build_search)  
        else ()
};
declare function search:lang_build_para_doc ($para as xs:string) as xs:string* {
    for $hit in search:get-parameters($para)
     (: let $parameters :=  search:get-parameters($para):)
        let $result := concat('("',
        string-join(search:lang_build_para_doc_ex(search:get-parameters($para),$hit),
        '","'),'"),"',
        string-join(search:get-parameters("lang"),'","'),'"')
        return $result
};

declare function search:lang_build_para_doc_ex($para as xs:string+, $hit as xs:string) as xs:string* {
        for $other in $para
            let $result := if($other = $hit) then "mainLang" else "otherLang"
            return $result
};
(: Sprach Filter END:)

(: Query Suche :)
declare function search:search_query($para as xs:string, $db as node()*) as node()* {
    for $hit in search:get-parameters($para)
        let $hit := if($para = "genre") then replace($hit, "_", " ")
                    else $hit
        
            let $query := <query><bool><term occur="must">{$hit}</term></bool></query>
            let $search_funk := "[ft:query(.,$query)]"
            let $search_build := concat("collection($db)//tei:msItemStruct",$search_funk) 
            return util:eval($search_build)
};
(: Range Suche :)
declare function search:search_range($para as xs:string, $db as node()*) as node()* {
    for $hit in search:get-parameters($para)    
     (:   let $para := if($para = "person")then  "author" else () :)
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

declare function search:search_range_simple($para as xs:string,$hit as xs:string, $db as node()*) as node()* {
 
     (:   let $para := if($para = "person")then  "author" else () :)
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};
(: Suche nach den Autoren und der Rollen :)
declare function search:author_build($db as node()*) as node()* {
        let $roles :=  if(search:get-parameters("release") = "published" ) then "person"
                        else if (search:get-parameters("release") = "unpublished") then search:get-parameters("role")
                        else (search:get-parameters("role"),"person")
        for $person in search:get-parameters("person")
           for $role in $roles
                let $merge := concat('("person","role"),','"',$person,'","',$role,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
           return util:eval($build_search)
};

(: Suche nach Datumsbereich :)
declare function search:date_build($db as node()*) as node()* {
     let $start := if(search:get-parameters("from") ="") then xs:integer("1900") else xs:integer(search:get-parameters("from"))
     let $end := if( search:get-parameters("to") = "") then xs:integer("1935") else xs:integer(search:get-parameters("to"))
     let $paras := ("date","date_when","date_notBefore","date_notAfter","date_from","date_to")
     for $date in ($start to $end)
        for $para in $paras
         let $result := search:date_search($db,$para,$date)
         return $result
     
};

declare function search:date_search($db as node()*,$para as xs:string,$date as xs:string)as node()* {
        let $search_terms := concat('("',$para,'"),"',$date,'"')
        let $search_funk := concat("//range:field-contains(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};



(: Profi Result :)
declare function search:profiresult($node as node(), $model as map(*), $sel as xs:string, $orderBy as xs:string?) as node()+ {
if(exists($sel) and $sel = "union") 
    then
    if(exists($model(concat("r_",$sel))))
    
    then if ($model("query")!="") then 
        for $hit in $model(concat("r_",$sel))
       
            let $file_name := root($hit)/util:document-name(.)
            let $sort := if($orderBy!="alpha") then (author:getYearOrTitle($hit,"date"))
                        else $file_name
            let $expanded := kwic:expand($hit)
            let $title := 
                    if(doc(concat("/db/apps/pessoa/data/doc/",$file_name))//tei:sourceDesc/tei:msDesc) 
                        then doc(concat("/db/apps/pessoa/data/doc/",$file_name))//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.)
                        else doc(concat("/db/apps/pessoa/data/pub/",$file_name))//tei:biblStruct/tei:analytic/tei:title[1]/data(.)
            order by $sort
            return if(substring-after($file_name,"BNP") != "" or substring-after($file_name,"MN") != "")
                    then <li><a href="{$helpers:app-root}/{$helpers:web-language}/doc/{concat(substring-before($file_name, ".xml"),'?term=',$model("query"))}">{$title}</a>
                        {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}</li>
                    else <li><a href="{$helpers:app-root}/{$helpers:web-language}/pub/{concat(substring-before($file_name, ".xml"),'?term=',$model("query"))}">{$title}</a>
                        {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}</li>
        else 
        for $hit in $model(concat("r_",$sel))
            let $file_name := root($hit)/util:document-name(.)
            let $sort := if($orderBy!="alpha") then (author:getYearOrTitle($hit,"date"))
                        else $file_name
            let $title := 
                    if(doc(concat("/db/apps/pessoa/data/doc/",$file_name))//tei:sourceDesc/tei:msDesc) 
                        then doc(concat("/db/apps/pessoa/data/doc/",$file_name))//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.)
                        else doc(concat("/db/apps/pessoa/data/pub/",$file_name))//tei:biblStruct/tei:analytic/tei:title[1]/data(.)
                order by $sort
                return if(substring-after($file_name,"BNP") != "" or substring-after($file_name,"MN") != "")
                        then <li><a href="{$helpers:app-root}/{$helpers:web-language}/doc/{concat(substring-before($file_name, ".xml"),'?term=',$model("query"))}">{$title}</a></li>
                        else <li><a href="{$helpers:app-root}/{$helpers:web-language}/pub/{concat(substring-before($file_name, ".xml"),'?term=',$model("query"))}">{$title}</a></li>
    else <p>{page:singleAttribute(doc('/db/apps/pessoa/data/lists.xml'),"search","no_results")}</p>
    else <p>Error</p>
};

declare function search:result_union($model as node()*) as node()* {
 if (exists($model))
 then let $union := $model
  return   $union | $union
else ()
};
declare function search:highlight-matches($node as node(), $model as map(*), $term as xs:string?, $sel as xs:string, $file as xs:string?) as node() {
if($term and $file and $sel and $sel="text","head","lang") 
    then
        let $result := if ($sel = "text")
        then doc(concat("/db/apps/pessoa/data/doc/",$file))//tei:text[ft:query(.,$term)]
        else ()
        let $css := doc("/db/apps/pessoa/highlight-matches.xsl")
        let $exp := if (exists($result)) then kwic:expand($result[1]) else ()
        let $exptrans := if (exists($exp))
                         then transform:transform($exp, $css, ())
                         else ()
        return
            if (exists($exptrans))
            then $exptrans
            else $node
    else $node
};


declare %templates:wrap function search:your_search($node as node(), $model as map(*)) as node()* {
        let $head := <h4> {page:singleElement_xquery("search","search_was")}</h4>
     return   if (search:get-parameters("term") != "" or search:get-parameters("lang") != "")  then
      (   $head, 
       for $item in  search:mergeParameters_xquery("xquery")
       let $term := if (exists( page:singleElement_xquery("search",substring-before(substring-after($item,"/"),"=")))) then  page:singleElement_xquery("search",substring-before(substring-after($item,"/"),"="))
                             else if(contains($item,"lang")) then   page:singleElement_xquery("search","language") 
                             else if (contains($item,"role")) then page:singleElement_xquery("roles","mentioned-as") 
                             else if (contains($item, "person")) then page:singleElement_xquery("search","author") 
                             else if (contains($item,"release")) then page:singleElement_xquery("search","publicado") 
                            else $item
       let $param := if (exists( page:singleElement_xquery("search",substring-after($item,"=")) )) then page:singleElement_xquery("search",substring-after($item,"="))
                                else if (contains($item,"role")) then page:singleElement_xquery("roles",substring-after($item,"="))
                                else if (contains($item, "genre")) then page:singleElementList_xquery("genres",substring-after($item,"="))
                                else if (contains($item,"lang")) then (
                                   if(count(search:get-parameters("lang")) != 3) then page:singleElementList_xquery("language",substring-after($item,"="))else () )
                                else if (contains($item,"person")) then doc('/db/apps/pessoa/data/lists.xml')//tei:listPerson[@type="authors"]/tei:person[@xml:id=substring-after($item,"=")]/tei:persName/data(.)   
                            else substring-after($item,"=")
          let $result := if($param != "") then concat("<span class='search_your_list'>",$term," : ",$param,"</span>") else ()
       return  if($result != "") then util:eval($result)  else () )
       else ()
       
};

declare function search:search-function() as node() {
    let $search := <script>function search() {{var value = $("#search").val();
                location.href="{$helpers:app-root}/{$helpers:web-language}/search?search=simple&amp;term="+value;
                }};
                $('#search').keydown(function( event ) {{
                if(event.which == 13) {{
                search()
                }}
                }});</script>
    return $search
};

declare function search:recorder() as node() {
  let $search := if(request:get-parameter("search",'') != "") then request:get-parameter("search",'') else ""
  let $term := if(request:get-parameter("term",'') != "") then request:get-parameter("term",'') else ""
  let $parameters := search:mergeParameters("html") 
 (:let $sort := if(request:get-parameter("sort",'') != "") then request:get-parameter("term",'') else "alpha":)
  let $code := if($search != "" and $term != "") then 
    <script> function recorder(sort) {{
    $('#result').load('{$helpers:request-path}?term={$term}&amp;search={$search}&amp;orderBy='+sort);
  }}
  </script>
  else 
  <script> function recorder(sort) {{
        $('#result').load('{$helpers:request-path}?orderBy='+sort+'{$parameters}');
       
  }}</script>
  return $code
};
declare function search:search-page($node as node(), $model as map(*)) as node()* {
    let $doc := doc('/db/apps/pessoa/data/lists.xml')
    let $filter := 
     <div class="search_filter">
                       <form class="/helpers:app-root" action="search" method="post" id="search">
                            <!-- Nachher mit class="search:profisearch austauschen -->
                                  <br/>
            <div class="tab" id="ta_author"><h6>{page:singleAttribute($doc,"search","authors")}</h6>
            </div>
            <div class="selection" id="se_author">
             <!--
             {page:createInput_term("search","checkbox","notional",("real","mentioned"),$doc,"checked")}
                             <br/>
                -->
                <select name="person" class="selectsearch" size="5" multiple="multiple">
                    {search:page_createOption_authors("authors",("FP","AC","AdC","RR"),$doc)}
                </select>
                <p class="small_text">{page:singleAttribute($doc,"search","multiple_entries")}</p>
               
                <p class="small_text">{page:singleAttribute($doc,"search","mentioned_as")} :</p>
                {page:createInput_term("roles","checkbox","role",("author","editor","translator","topic"),$doc,"")}
                </div>
                <div class="tab" id="ta_release"><h6>{page:singleAttribute($doc,"search","published")} &amp; {page:singleAttribute($doc,"search","unpublished")}</h6>
                </div>
                <div class="selection" id="se_release">
                {page:createInput_term("search","radio","release",("published","unpublished"),$doc, "")}
                <input class="release_input-box" type="radio" name="release" value="all" id="either" checked="checked"/>
                <label class="release_input-label" for="either"> {page:singleAttribute($doc,"search","all")}</label>
                </div>
                <div class="tab" id="ta_genre"><h6>{page:singleAttribute($doc,"search","genre")}</h6>
                </div>
                    <div class="selection" id="se_genre">
                        <select class="selectsearch" name="genre" size="7" multiple="multiple">
                        {page:createOption("genres",("lista_editorial","nota_editorial","plano_editorial","poesia"),$doc)}
                        </select>
                        <p class="small_text">{page:singleAttribute($doc,"search","multiple_entries")}</p>
                    </div>
                  <div class="tab" id="ta_date"><h6>{page:singleAttribute($doc,"search","date")}</h6></div>
                            <div class="selection" id="se_date">    
                                <div id="datum">
                                    <input type="datum" class="date_field" name="from" placeholder="{page:singleAttribute($doc,"search","from")}"/>
                                    <input type="datum" class="date_field" name="to" placeholder="{page:singleAttribute($doc,"search","to")}"/>
                                </div>
                    </div>  
                    <div class="tab" id="ta_lang"><h6>{page:singleAttribute($doc,"search","language")}</h6></div>
                            <div class="selection" id="se_lang">
                                {search:page_createInput_item_lang("language","checkbox","lang",("pt","en","fr"),$doc)}
                                <br/>
                                <input class="lang_input-box" type="radio" name="lang_ao" value="and" id="and"/>
                                    <label class="lang_input-label" for="and">{page:singleAttribute($doc,"search","and")}</label>
                                <input class="lang_input-box" type="radio" name="lang_ao" value="or" id="or" checked="checked"/>
                                    <label class="lang_input-label" for="or">{page:singleAttribute($doc,"search","or")}</label>
                            </div>
                     <!--<h6>{page:singleAttribute($doc,"search","free_search")}</h6>
                     <input name="term" placeholder="{page:singleAttribute($doc,"search","search_term")}..." /> -->
             <br/>
            <h6>{page:singleAttribute($doc,"search","free_search")}</h6>
             <input id="spezsearch" name="term" placeholder="{page:singleAttribute($doc,"search","term")}..." />
             <br />
             <br />
           <button id="spezsearchbutton">{page:singleAttribute($doc,"search","search_verb")}</button>
      
</form>
</div>
    return (search:recorder(),$filter)
};



declare function search:page_createInput_item_lang($xmltype as xs:string,$btype as xs:string, $name as xs:string, $value as xs:string*,$doc as node()) as node()* {
    for $id in $value
        let $entry := if($helpers:web-language = "pt")
                      then $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@xml:id=$id]/data(.)
                      else $doc//tei:list[@type=$xmltype and @xml:lang=$helpers:web-language]/tei:item[@corresp=concat("#",$id)]/data(.)
        let $input := <input class="{concat($name,"_input-box")}" type="{$btype}" name="{$name}" value="{$id}" id="{$id}" checked="checked"/>
        let $label := <label class="{concat($name,"_input-label")}" for="{$id}">{$entry}</label>
        let $breaked := <br />
        return ($input,$label,$breaked)
};
declare function search:page_createOption_authors($xmltype as xs:string, $value as xs:string*, $doc as node()) as node()* {
    for $id in $value
        let $entry := $doc//tei:listPerson[@type=$xmltype]/tei:person[@xml:id=$id]/tei:persName/data(.)
        return <option value="{$id}">{$entry}</option>
};


declare function search:singleDocument($doc as xs:string) {
    let $db := collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
    let $term := concat($doc,".xml")
    let $result := search:search_range_simple("title",$term,$db)
    return if($result != "") then fn:true() else fn:false()
    
};