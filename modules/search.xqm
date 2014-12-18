xquery version "3.0";

module namespace search="http://localhost:8080/exist/apps/pessoa/search";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Standard Volltext Suche:)
declare %templates:wrap function search:search( $node as node(), $model as map(*), $term as xs:string?) as map(*) {
   
   (:
   for $m in collection("/db/apps/pessoa/data/doc")//tei:origDate[ft:query(.,$q)]
order by ft:score($m) descending
:)
    if(exists($term) and $term !=" ")
    then
        let $result-text := collection("/db/apps/pessoa/data/doc")//tei:text[ft:query(.,$term)]
        let $result-head := collection("/db/apps/pessoa/data/doc")//tei:msItemStruct[ft:query(.,$term)]
        let $result := ($result-text, $result-head)
        return map{
        "result" := $result,
        "result-text" := $result-text,
        "result-head" := $result-head,
        "query" := $term
        }
        else map{
        "resilt-text":=(),
        "result-head":=(),
        "query" := '"..."'
        }
};
(: Ergebniss Volltext Suche :)
declare function search:result-list ($node as node(), $model as map(*), $sel as xs:string) as node()+ {
    if (exists($sel) and $sel = ("text", "head"))
    then
        if (exists($model(concat("result-",$sel))))
        then
        let $term := $model("query") 
            for $hit in $model(concat("result-", $sel))
            let $file-name := root($hit)/util:document-name(.)
            let $title := 
            if(doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:sourceDesc/tei:msDesc) 
                then doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.)
                else doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:biblStruct/tei:analytic/tei:title[1]/data(.)
            let $expanded := kwic:expand($hit)
        return if($sel != "head")
            then 
            <li>
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}
            </li>
            else 
            <li> 
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="0" />)}</li>
        else <p> Keine Treffer </p>
        else $sel
};

(:Profi Suche -OLD:)
declare  %templates:wrap function search:search-profi( $node as node(), $model as map(*), $term as xs:string?) as map(*) {

   (:
   for $m in collection("/db/apps/pessoa/data/doc")//tei:origDate[ft:query(.,$q)]
order by ft:score($m) descending
:)
    if(exists($term) and $term !="")
    then
        (:
        let $lang := if($parameters ="lang") then app:search-value($parameters,"language") else ""
        let $date := if($parameters ="date") then app:search-value($parameters,"date") else ""
        :)
        let $collect := collection("/db/apps/pessoa/data/doc")
        (:
        let $filter-lang := if($lang !="") then $collect//range:field-eq(("mainLang"),$lang)  else if($collect//range:field-eq(("mainLang"),$lang)= "") then $collect//range:field-eq(("otherLang"),$lang)  else $collect
        let $filter-date := if($date != "") then $collect//range:field-eq(("date_when"),"1915") else $collect
        :)      
             
        let $query:= <query><bool><term occur="must">{$term}</term></bool></query>
        let $result-text := $collect//tei:text[ft:query(.,$query)] 
        let $result-head := $collect//tei:msItemStruct[ft:query(.,$query)] 
        
       
       
       (: let $result-lang := collection("/db/apps/pessoa/data/doc")//tei:msItemStruct/tei:textLang[ft:query(@mainLang,'pt')]/@mainLang/data(.) :)

        (:collection("/db/apps/pessoa/data/doc")//tei:msItemStruct/tei:textLang/range:field-eq(("mainLang"),$lang):)
        
        (: //range:field-eq( ( %para1%, %para2%),%search1%,%search2%) :)
     (:   let $db := "/db/apps/pessoa/data/doc"
        let $filter-att := app:filter-att_build()
        let $filter-para := app:filter-para_build()
        let $filter-connect := concat('("',$filter-para,'"),"',$filter-att,'"')
        let $filter-search := concat("//range:field-eq(",$filter-connect,")")
        let $filter-build := concat("collection($db)",$filter-search)
       
       let $result-filter := $filter-build  :) (:util:eval($filter-build):)
       
        (:       let $result-filter := ($filter-para ,$filter-att) :)

        let $result-filter := "Nothin"
        
        let $result := ($result-text, $result-head, $result-filter)
        return map{
        "result" := $result,
        "result-text" := $result-text,
        "result-head" := $result-head,    
        "result-filter" := $result-filter,
        "query" := $term
        
        }
        else map{
        "result-text":=(),
        "result-head":=(),
        "result-filter" := (),
        "query" := '"..."'
        }
        
};
(: Alten Funtkionen rausgelöscht, gespeichert im Drive :)

(: Neu Entstehung der Profi Suche :)

declare %templates:wrap function search:profisearch($node as node(), $model as map(*), $term as xs:string?) as map(*) {
    
        (: Erstellung der Kollektion, sortiert ob "Publiziert" oder "Nicht Publiziert" :)
        
            let $db := search:set_db()
        
        (: Unterscheidung nach den Sprachen, ob "Und" oder "ODER" :)
        let $r_lang := if(search:get-parameters("lang_ao") = "or") 
                       then search:get_lang($db)
                       else ()
        (: Sortierung nach Genre :)
        let $r_genre := if(search:get-parameters("genre")!="") then search:search_range("genre",$r_lang)
                        else()                        
                        
        (:Suche nach "Erwähnten" Rollen:)
        let $r_mention := if(search:get-parameters("notional")="mentioned") then search:author_build($r_lang)
                        else () (:
        let $r_mention := if(search:get-parameters("notional")="mentioned") then search:search_range("person",$r_lang)
                        else ():)
        
        (: Datumssuche :)
        let $r_date := if(search:get-parameters("before") != "" or search:get-parameters("after") != "") then search:date_build($r_lang)
                        else ()
        
        let $r_all := ($r_lang,$r_genre,$r_mention,$r_date)
        
        return map{
            "r_all"     := $r_all,
            "r_lang"    := $r_lang,
            "r_genre"   := $r_genre,
            "r_mention" := $r_mention,
            "r_date" := $r_date
        }
        

};




declare function search:set_db() as xs:string+ {
        let $result :=    if(search:get-parameters("release") = "non_public")  then "/db/apps/pessoa/data/doc"
                             else if(search:get-parameters("release") = "public" ) then "/db/apps/pessoa/data/pub"
                             else ("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                   return $result
};

(: Funtkion um die Parameter rauszufiltern:)
declare function search:get-parameters($key as xs:string) as xs:string* {
    for $hit in request:get-parameter-names()
        return if($hit=$key) then request:get-parameter($hit,'')
                else ()
};
(: ODER FUNTKION : Filtert die Sprache :) 
declare function search:get_lang($db as xs:string+) as node()*{
    for $match in $db
        let $result := if(search:get-parameters("release") != "either") then  search:lang_filter($match,"")
                       else (search:lang_filter($match,"non_public"),search:lang_filter($match, "public"))
        return $result
};

declare function search:lang_filter($db as xs:string, $step as xs:string?) as node()* {
    if(search:get-parameters("release")="non_public" or $step = "non_public") then
        for $hit in search:get-parameters("lang")
            let $para := ("mainLang","otherLang")
            for $match in $para
                let $search_terms := concat('("',$match,'"),"',$hit,'"')
                let $search_funk := concat("//range:field-eq(",$search_terms,")")
                let $search_build := concat("collection($db)",$search_funk)
                let $result :=  util:eval($search_build)
            return $result
        else if (search:get-parameters("release")="public" or $step = "public") then 
            for $hit in search:get-parameters("lang")
                let $search_terms := concat('("lang"),"',$hit,'"')
                let $search_funk := concat("//range:field-eq(",$search_terms,")")
                let $search_build := concat("collection($db)",$search_funk)
                let $result :=  util:eval($search_build)
            return $result
        else ()
};



(: Query Suche :)
declare function search:search_query($para as xs:string, $db as node()*) as node()* {
    for $hit in search:get-parameters($para)
        let $hit := if($para = "genre") then replace($hit, "_", " ")
                    else $hit
        
            let $query := <query><bool><term occur="must">{$hit}</term></bool></query>
            let $search_funk := "[ft:query(.,$query)]"
            let $search_build := concat("collection($db)//tei:msItemStruct",$search_funk) 
            let $result := util:eval($search_build)
            return $result
};
(: Range Suche :)
declare function search:search_range($para as xs:string, $db as node()*) as node()* {
    for $hit in search:get-parameters($para)    
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        let $result := util:eval($search_build)
        return $result
};

(: Suche nach den Autoren und der Rollen :)
declare function search:author_build($db as node()*) as node()* {
        for $person in search:get-parameters("person")
           for $role in search:get-parameters("role")
                let $merge := concat('("person","role"),','"',$person,'","',$role,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
                let $result := util:eval($build_search)
           return $result
};

(: Suche nach Datumsbereich :)
declare function search:date_build($db as node()*) as node()* {
     let $start := xs:integer(search:get-parameters("after"))
     let $end := xs:integer(search:get-parameters("before"))
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
        let $result := util:eval($search_build)
        return $result
};

(: Profi Result :)
declare function search:profiresult($node as node(), $model as map(*), $sel as xs:string) as node()+ {
   if(exists($sel) and $sel=("lang","genre","mention","date","all"))
   then
   if(exists($model(concat("r_",$sel)))) 
    then 
        for $hit in $model(concat("r_",$sel))
        (:
        return <p> Exist, {$model(concat("r_",$sel))}</p>
        else <p>Dos Not Exist </p>
        :)
        let $file-name := root($hit)/util:document-name(.)            
        return <p>Exist,{$file-name}</p>            
        else <p> Dos Not exist,{$model(concat("r_",$sel))}</p>
        
        (:
        return <p>Exist,{$model("profi_result"),$file-name}</p>            
        else <p> Dos Not exist,{$model("profi_result")}</p>
        :)
        else <p>Error</p>
};      

(: Ende der Neuen Funktionen :)

declare  function search:result-filter ($node as node(), $model as map(*), $sel as xs:string) as node()+ {
    if(exists($sel) and $sel = ("filter"))
    then
        if(exists($model(concat("r_",$sel))))  
        then 
        
            for $hit in $model("result-filter")
            return <p>Exist, {$model("result-filter")}</p>
            else <p>Dos Not exist</p>
            
            (:
        for $hit in $model("result-filter")
            let $file-name := root($hit)/util:document-name(.)            
            return <p>Exist,{$sel,$model("result-filter"),$file-name}</p>            
        else <p> Dos Not exist,{$sel,$model("result-filter")}</p>
        :)
    else $sel
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
