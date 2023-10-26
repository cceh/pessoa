xquery version "3.1";

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


declare function search:test($node as node(), $model as map(*),$pathi) {
   $pathi
};
(:  Profi Suche :)
declare %templates:wrap function search:profisearch($node as node(), $model as map(*), $term as xs:string?) as map(*) {
        (: Erstellung der Kollektion, sortiert ob "Publiziert" oder "Nicht Publiziert" :)
        let $db := search:set_db()
        let $dbase :=  if($term != "" ) then collection($db)//tei:TEI[ft:query(.,$term,<options>
            <default-operator>and</default-operator>
                                                             </options>)]
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
        let $r_date := if(search:get-parameters("SE_to") != "" or search:get-parameters("SE_from") != "") then search:date_build($dbase)
                        else $dbase
        let $dbase := $r_date
        (: Volltext Suche :)                
      (:  let $r_all := ($r_genre,$r_mention,$r_date) :)
       
        return map{
            "r_union"   : search:result_union($dbase),
            "r_count" : count(search:result_union($dbase)),
            (:"r_dbase"   : $dbase,:)
            "query"     : $term
        }
        
};



declare function search:set_db() as xs:string+ {
        let $result :=       if(search:get-parameters("release") = "unpublished")    then "/db/apps/pessoa/data/doc"
                             else if(search:get-parameters("release") = "published" )  then "/db/apps/pessoa/data/pub"
                             else ("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                            
                   return $result
};

(:~ Funktion um die Parameter rauszufiltern:)
declare function search:get-parameters($key as xs:string) as xs:string* {
    for $hit in request:get-parameter-names()
        return if($hit=$key) then request:get-parameter($hit,'')
                else ()
};

declare function search:mergeParameters ($type as xs:string) as xs:string {
    let $code := if($type = "html") then "&amp;" else "/"
    let $term := concat($code,"term=",search:get-parameters("term"))
    let $after := concat($code,"from=",search:get-parameters("SE_from"))
    let $before := concat($code,"to=",search:get-parameters("SE_to"))
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
    return string-join((for $item in ($term,$after,$before,$lang,$lang_ao,$person,$genre,$role,$release) where substring-after($item,"=") != "" return $item),'')
};

declare function search:mergeParametersJSON($node as node(), $model as map(*)) {
    let $code := ""
    let $term := concat($code,'"term":"',search:get-parameters("term"),'"')
    let $after := concat($code,"'from':'",search:get-parameters("SE_from"),"'")
    let $before := concat($code,"'to':'",search:get-parameters("SE_to"),"'")
    let $lang := concat($code,"'lang':['",string-join(search:get-parameters("lang"),"','"),"']")
    let $lang_ao := concat($code,"'lang_ao':'",search:get-parameters("lang_ao"),"'")
    let $person := concat($code,"'person':['",string-join(search:get-parameters("person"),"','"),"']")
    let $genre :=  concat($code,"'genre':['",string-join(search:get-parameters("genre"),"','"),"']")
    let $role := concat($code,"'role':['",string-join(search:get-parameters("role"),"','"),"']")
    let $release := concat($code,"'release':'",search:get-parameters("release"),"'")
    let $string := string-join(($term,$after,$before,$lang,$lang_ao,$person,$genre,$role,$release),",")
    return
        <script type="text/javascript">
            searching({concat("{",$string,"}")},"insert");
        </script>

};

declare function search:mergeParameters_xquery ($type as xs:string) as xs:string* {
    let $code := if($type = "html") then "&amp;" else "/"
    let $term := concat($code,"term=",search:get-parameters("term"))
    let $after := concat($code,"from=",search:get-parameters("SE_from"))
    let $before := concat($code,"to=",search:get-parameters("SE_to"))
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
(: ODER FUNKTION : Filtert die Sprache, TERM :)
declare function search:lang_or_term($db as node()*) as node()* {
    for $hit in search:get-parameters("lang")
        let $para := ("doc_mainLang","doc_otherLangs","pub_mainLang","pub_otherLangs")
        for $match in $para
                let $search_terms := concat('("',$match,'"),"',$hit,'"')
                let $search_funk := concat("//range:field-contains(",$search_terms,")")
                let $search_build := concat("$db",$search_funk)
            return util:eval($search_build)
};

(: UND FUNKTION : Filtert die Sprache, TERM :)

declare variable $search:lang_terms := if(search:get-parameters("lang") != "") then search:get-parameters("lang") else ("pt","en","fr");


declare function search:lang_and_term($db as node()*, $step as xs:string) as node()* {
        if(search:get-parameters("release")="unpublished" and $step = "unpublished") then
            for $match in search:lang_build_para_doc("lang")
                let $build_funk := concat("//range:field-contains(",$match,")")
                let $build_search := concat("$db",$build_funk) 
                return util:eval($build_search) 
        else if (search:get-parameters("release")="published" and $step = "published") then 
            for $match in search:lang_build_para_pub("lang")
                let $build_funk := concat("//range:field-contains(",$match,")")
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
        for $hit in $search:lang_terms
            let $para := ("doc_mainLang","doc_otherLangs")
            for $match in $para
                let $search_terms := concat('("',$match,'"),"',$hit,'"')
                let $search_funk := concat("//range:field-contains(",$search_terms,")")
                let $search_build := concat("collection($db)",$search_funk)
            return util:eval($search_build) 
    else if (search:get-parameters("release")="published" or $step = "published") then 
        for $hit in $search:lang_terms
            let $para := ("pub_mainLang","pub_otherLangs")
            for $match in $para
                let $search_terms := concat('("',$match,'"),"',$hit,'"')
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
        return $result
};

declare function search:lang_filter_and($db as xs:string, $step as xs:string?) as node()* {
        if(search:get-parameters("release")="unpublished" or $step = "unpublished") then
            for $match in search:lang_build_para_doc("lang")
                let $build_funk := concat("//range:field-contains(",$match,")")
                let $build_search := concat("collection($db)",$build_funk) 
                return util:eval($build_search) 
        else if (search:get-parameters("release")="published" or $step = "published") then 
            for $match in search:lang_build_para_pub("lang")
                let $build_funk := concat("//range:field-contains(",$match,")")
                let $build_search := concat("$db",$build_funk) 
                return util:eval($build_search) 
        else ()
};
declare function search:lang_build_para_doc ($para as xs:string) as xs:string* {
    for $hit in search:get-parameters($para)
        let $result := concat('("',
        string-join(search:lang_build_para_doc_ex(search:get-parameters($para),$hit),
        '","'),'"),"',
        string-join($search:lang_terms,'","'),'"')
        return $result
};
declare function search:lang_build_para_pub ($para as xs:string) as xs:string* {
    for $hit in search:get-parameters($para)
        let $result := concat('("',
        string-join(search:lang_build_para_pub_ex(search:get-parameters($para),$hit),
        '","'),'"),"',
        string-join($search:lang_terms,'","'),'"')
        return $result
};

declare function search:lang_build_para_doc_ex($para as xs:string+, $hit as xs:string) as xs:string* {
        for $other in $para
            let $result := if($other = $hit) then "doc_mainLang" else "doc_otherLangs"
            return $result
};
declare function search:lang_build_para_pub_ex($para as xs:string+, $hit as xs:string) as xs:string* {
        for $other in $para
            let $result := if($other = $hit) then "pub_mainLang" else "pub_otherLangs"
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

           
(: Suche nach den Autoren und der Rollen  "author","editor","translator", :)
declare function search:author_build($db as node()*) as node()* {

         
        let $roles :=  if(search:get-parameters("release") = "published" ) then "name"
                        else if (search:get-parameters("release") = "unpublished" and search:get-parameters("role") != "") then search:get-parameters("role")
                       else if(search:get-parameters("role") != "" and search:get-parameters("release") = "all") then  (search:get-parameters("role"),"name")
                       else  ("author","editor","translator","topic","name") 
                        
        for $person in search:get-parameters("person")
           for $role in $roles
                let $merge := concat('("rs_key","rs_role"),','"',$person,'","',$role,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
           return util:eval($build_search)
};

(: Suche nach Datumsbereich :)
declare function search:date_build($db as node()*) as node()* {
     let $start := if(search:get-parameters("SE_from") ="") then xs:integer("1900") else xs:integer(search:get-parameters("SE_from"))
     let $end := if( search:get-parameters("SE_to") = "") then xs:integer("1935") else xs:integer(search:get-parameters("SE_to"))
     let $paras := ("doc_date_when","doc_date_notBefore","doc_date_notAfter","doc_date_from","doc_date_to", "pub_date_when", "pub_date_from", "pub_date_to")
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
declare function search:profiresult($node as node(), $model as map(*), $sel as xs:string, $orderBy) as node()+ {
if(exists($sel) and $sel = "union") 
    then
    if(exists($model(concat("r_",$sel))))    
    then 
        let $data := for $hit in $model(concat("r_",$sel))
                                return   search:ResultToitem($hit,$model("query"))
         let $data := if($orderBy eq "date") then for $item in $data order by $item/@date/data(.) return $item
                                else for $item in $data order by $item/@title/data(.) return $item
        return
            if($model("query") != "") then                        
             for $item in $data 
                        (:let $query := $model("query")
                        let $kwic:= string-join($item/@kwic/data(.),"")
                        let $kwic := <p>{substring-before($kwic,$query)}<span class="hi">{$query}</span>{substring-after($kwic,$query)}</p>:)
                        return <li><a href="{$helpers:app-root}/{$helpers:web-language}/{$item/@dir/data(.)}/{concat($item/@file/data(.),'?term=',$model("query"))}">{$item/@title/data(.)}</a>
                            <p>{$item/@kwic/data(.)}</p>
                        </li>                        
            else for $item in $data 
                        return <li><a href="{$helpers:app-root}/{$helpers:web-language}/{$item/@dir/data(.)}/{$item/@file/data(.)}">{$item/@title/data(.)}</a></li>                        
    else <p>{helpers:singleElementInList_xQuery("search","no_results")}</p>
    else <p>Error</p>
};

declare function search:ResultToitem($hit,$query) {
    if( contains(root($hit)/util:document-name(.),"BNP") or contains(root($hit)/util:document-name(.),"CP") ) then search:ResutlToItemDoc($hit,$query)
    else search:ResultToItemPub($hit,$query)
};

declare function search:ResultToItemPub($hit,$query) {
<item
    dir="pub"
    file = "{substring-before(root($hit)/util:document-name(.),".xml")}"
    title="{$hit//tei:biblStruct/tei:analytic/tei:title[1]/data(.)}"
    date="{search:datePub($hit)}"
    kwic="{if($query!="") then search:kwic($hit)else ""}"
/>
};

declare function search:datePub($pub) {
    let $when := ($pub//tei:imprint/tei:date)[1]/@when/data(.)
    let $from := ($pub//tei:imprint/tei:date)[1]/@from/data(.)
    let $notBefore := ($pub//tei:imprint/tei:date)[1]/@notBefore/data(.)
    let $notAfter := ($pub//tei:imprint/tei:date)[1]/@notAfter/data(.)
   return if($when) then $when
            else if($from) then $from
            else if($notBefore) then $notBefore
            else if($notAfter) then $notAfter
            else "?"
};

declare function search:ResutlToItemDoc($hit,$query) {
<item
    dir="doc"
    file = "{substring-before(root($hit)/util:document-name(.),".xml")}"
    title="{replace($hit//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.),"/E3","")}"
    date="{search:dateDoc($hit)}"
    kwic="{if($query!="") then search:kwic($hit)else ""}"
/>
};

declare function search:kwic($hit) {
let $expanded := kwic:expand($hit)
return <p>{kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}</p>
};

declare function search:dateDoc($doc) {
    let $when := $doc//tei:origDate/@when/data(.)
    let $from := $doc//tei:origDate/@from/data(.)
    let $notBefore := $doc//tei:origDate/@notBefore/data(.)
    let $notAfter := $doc//tei:origDate/@notAfter/data(.)
   return if($when) then $when
        else if($from) then $from
        else if($notBefore) then $notBefore
        else if($notAfter) then $notAfter
        else "?"
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
        let $xsl := doc("/db/apps/pessoa/xslt/highlight-matches.xsl")
        let $exp := if (exists($result)) then kwic:expand($result[1]) else ()
        let $exptrans := if (exists($exp))
                         then transform:transform($exp, $xsl, ())
                         else ()
        return
            if (exists($exptrans))
            then $exptrans
            else $node
    else $node
};

declare function search:mergeParameters_xquery_map () as map(*) {
    map {
    "term":    search:get-parameters("term"),
    "from":    search:get-parameters("SE_from"),
    "to"  :    search:get-parameters("SE_to"),
    "lang":    search:get-parameters("lang"),
    "lang_ao": search:get-parameters("lang_ao"),
    "person" : search:get-parameters("person"),
    "genre" :  search:get-parameters("genre"),
    "role" :   search:get-parameters("role"),
    "release": search:get-parameters("release")
    }
};

declare %templates:wrap function search:your_search($node as node(), $model as map(*)) as node()* {
        let $head := <h4> {helpers:singleElementInList_xQuery("search","search_was")}</h4>
        let $seas := search:mergeParameters_xquery_map()
     return   if ($seas("term") != "" or $seas("lang") != "" or ($seas("from") != "" and $seas("to") != ""))  then
      (   $head,
      for $item in map:keys($seas)
     let $param := $seas($item)
      let $build := if($param != "") then (
      switch($item)
          case("lang") return  if(count($param) != 3) then (helpers:singleElementInList_xQuery("search","language"),  string-join((for $i in $param return helpers:singleElementInList_xQuery("language",$i)),concat(" ",helpers:singleElementInList_xQuery("search",$seas("lang_ao"))," "))) else()
          case("lang_ao") return () (:if($param != "") then if(count(search:get-parameters("lang")) != 3) then (helpers:singleElementInList_xQuery("search","language"), helpers:singleElementInList_xQuery("search",$param)) else () else () :)
          case("role") return (helpers:singleElementInList_xQuery("roles","mentioned-as"),string-join(for $i in $param return helpers:singleElementInList_xQuery("roles",$i),", "))
          case("genre") return (helpers:singleElementInList_xQuery("search","genero") , string-join(for $i in $param return helpers:singleElementInList_xQuery("genres",search:encryptGenre($i)),", "))
          case("person") return (helpers:singleElementInList_xQuery("search","autores") , string-join(for $i in $param return doc('/db/apps/pessoa/resources/lists.xml')//tei:listPerson[@type="authors"]/tei:person[@xml:id=$i]/tei:persName/data(.),", "))
          case("term") return (helpers:singleElementInList_xQuery("search","term"),$param)
          case("release") return if($param != "all") then (helpers:singleElementInList_xQuery("search","publicado"),  (if($param="all") then  helpers:singleElementInList_xQuery("search",$param)
          else if ($param="published")  then helpers:singleElementInList_xQuery("search","pub_yes")
              else helpers:singleElementInList_xQuery("search","pub_no"))) else ()

          case("from") return  (helpers:singleElementInList_xQuery("search",$item),$param)
          case("to") return  (helpers:singleElementInList_xQuery("search",$item),$param)
          default return (helpers:singleElementInList_xQuery("search",$item), helpers:singleElementInList_xQuery("search",$param))

      ) else ()
      let $result := if($build != "") then concat("<span class='search_your_list'>",$build[1], ": ", string-join(for $i in (2 to count($build)) return $build[$i]," ") ,"</span>") else ()


      (:
       let $build := switch($item)
                            case("lang") return if($param != "" ) then  if(count(search:get-parameters("lang")) != 3) then (helpers:singleElementInList_xQuery("search","language"), helpers:singleElementInList_xQuery("language",$param)) else () else ()
                            (:) case("lang_ao") return if($param != "") then if(count(search:get-parameters("lang")) != 3) then (helpers:singleElementInList_xQuery("search","language"), helpers:singleElementInList_xQuery("search",$param)) else () else () :)
                            case("role") return (helpers:singleElementInList_xQuery("roles","mentioned-as"),helpers:singleElementInList_xQuery("roles",$param))
                            case("genre") return (helpers:singleElementInList_xQuery("search","genero") , helpers:singleElementInList_xQuery("genres",search:encryptGenre($param)))
                            case("person") return (helpers:singleElementInList_xQuery("search","autores") ,doc('/db/apps/pessoa/resources/lists.xml')//tei:listPerson[@type="authors"]/tei:person[@xml:id=$param]/tei:persName/data(.))
                            case("term") return if($param != "") then (helpers:singleElementInList_xQuery("search","term"),$param) else ()
                            case("release") return if($param != "") then (helpers:singleElementInList_xQuery("search","publicado"),  (if($param="all") then  helpers:singleElementInList_xQuery("search",$param)
                                                                                                                                                    else if ($param="published")  then helpers:singleElementInList_xQuery("search","pub_yes")
                                                                                                                                                    else helpers:singleElementInList_xQuery("search","pub_no")))
                                                                                                                                                        else ()
                            case("from") return if($param != "") then (helpers:singleElementInList_xQuery("search",$term),$param) else ()
                            case("to") return if($param != "") then (helpers:singleElementInList_xQuery("search",$term),$param) else ()
                            default return (helpers:singleElementInList_xQuery("search",$term), helpers:singleElementInList_xQuery("search",$param))
          let $result := if($build != "") then concat("<span class='search_your_list'>",$build[1], ": ",$build[2] ,"</span>") else ()
          :)
       return  if($result != "") then util:eval($result) else ()
      )

       else ()

};

declare function search:encryptGenre($val) {
    $helpers:lists//tei:item[./tei:note[@type="range"]/data(.) = $val]/@xml:id/data(.)
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
    let $doc := doc('/db/apps/pessoa/resources/lists.xml')
    let $filter :=
     <div class="search_filter">
                       <form class="" action="{$helpers:app-root}/{$helpers:web-language}/search" method="post" id="search">

            <div class="tab" id="ta_author"><h6>{helpers:singleElementInList_xQuery("search","autores")}</h6>
            </div>

            <div class="selection" id="se_author">
                <select name="person" class="selectsearch" size="5" multiple="multiple">
                    {search:page_createOption_authors("authors",("FP","AC","AdC","RR","BS"),$doc)}
                </select>
                <p class="small_text">{helpers:singleElementInList_xQuery("search","multiple_entries")}</p>

                <p class="small_text">{helpers:singleElementInList_xQuery("search","mentioned_as")}:</p>
                {helpers:createInput_term("roles","checkbox","role",("author","editor","translator","topic"),"")}
                </div>

                <div class="tab" id="ta_release"><h6>{helpers:singleElementInList_xQuery("search","published")} &amp; {helpers:singleElementInList_xQuery("search","unpublished")}</h6>
                </div>
                <div class="selection" id="se_release">
                {helpers:createInput_term("search","radio","release",("published","unpublished"),"")}
                <input class="release_input-box" type="radio" name="release" value="all" id="either" checked="checked"/>
                <label class="release_input-label" for="either"> {helpers:singleElementInList_xQuery("search","all")}</label>
                </div>


                <div class="tab" id="ta_genre"><h6>{helpers:singleElementInList_xQuery("search","genero")}</h6>
                </div>

                    <div class="selection" id="se_genre">
                        <select class="selectsearch" name="genre" size="7" multiple="multiple">
                        {helpers:createOption_new("genres",("editorial_list","editorial_note","editorial_plan","poetry","prose"))}
                        </select>
                        <p class="small_text">{helpers:singleElementInList_xQuery("search","multiple_entries")}</p>
                    </div>

                  <div class="tab" id="ta_date"><h6>{helpers:singleElementInList_xQuery("search","date")}</h6></div>
                            <div class="selection" id="se_date">
                                <div id="datum">
                                    <input type="datum" class="date_field" name="SE_from" placeholder="{helpers:singleElementInList_xQuery("search","from")}"/>
                                    <input type="datum" class="date_field" name="SE_to" placeholder="{helpers:singleElementInList_xQuery("search","to")}"/>
                                </div>
                    </div>

                    <div class="tab" id="ta_lang"><h6>{helpers:singleElementInList_xQuery("search","language")}</h6></div>
                            <div class="selection" id="se_lang">
                                {helpers:createInput_term("language","checkbox","lang",("pt","en","fr"),'')}
                                <br/>
                                <input class="lang_input-box" type="radio" name="lang_ao" value="and" id="and"/>
                                    <label class="lang_input-label" for="and">{helpers:singleElementInList_xQuery("search","and")}</label>
                                <input class="lang_input-box" type="radio" name="lang_ao" value="or" id="or" checked="checked"/>
                                    <label class="lang_input-label" for="or">{helpers:singleElementInList_xQuery("search","or")}</label>
                            </div>
             <br/>

            <h6>{helpers:singleElementInList_xQuery("search","free_search")}</h6>
             <input id="spezsearch" name="term" placeholder="{helpers:singleElementInList_xQuery("search","term")}..." />

             <br />
             <br />

           <button id="spezsearchbutton">{helpers:singleElementInList_xQuery("search","search_verb")}</button>
                           <span id="clearing" class="tab">{helpers:singleElementInList_xQuery("search","search_clear")}</span>

                       </form>
</div>
    return (search:recorder(),$filter)
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


(: Range Suche :)
declare function search:search_range($para as xs:string, $db as node()*) as node()* {
    for $hit in search:get-parameters($para)
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

declare function search:search_range_simple($para as xs:string,$hit as xs:string, $db as node()*) as node()* {
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

declare function search:searchRange_ex_two($db as node()*,$para1 as xs:string, $para2 as xs:string, $term1 as xs:string, $term2 as xs:string) as node()*{
        let $merge := concat('("',$para1,'","',$para2,'"),','"',$term1,'","',$term2,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
           return util:eval($build_search)
           };
    

declare function search:Search_FieldStartsWith($type as xs:string, $letter as xs:string, $db as node()*) {
        let $range := concat("//range:field-starts-with(('",$type,"'),'",$letter,"')")
         let $build := concat("$db",$range)
        return util:eval($build)
};

declare function search:Search_MultiStats($db as node()*, $name as xs:string*, $case as xs:string*,$content as xs:string*) as node()* {
    let $name := concat('("',string-join($name,'","'),'")')
    let $case := concat('("',string-join($case,'","'),'")')
    let $content := concat('"',string-join($content,'","'),'"')
 
    let $search-funk := concat('//range:field(',$name,',',$case,',',$content,')')
    let $search-build := concat("$db",$search-funk)
    return util:eval($search-build)

};


declare function search:printDateAlpha($node as node(), $model as map(*)) {
 if(request:get-parameter("order","") eq  "alphab") then
       <span>
    <input id="date" name="order" type="radio" value="no" onchange="recorder('date');setOrderBy('date');"></input><label for="date" class="" >{helpers:singleElementInList_xQuery("order","chronological")}</label>   
    <input id="alphab" checked="checked" name="order" type="radio" value="yes" onchange="recorder('alphab');setOrderBy('alphab');"></input><label for="alphab" class="" >{helpers:singleElementInList_xQuery("order","alphabetical")}</label>   
</span>            
else 
<span>
    <input id="date" checked="checked" name="order" type="radio" value="no" onchange="recorder('date');setOrderBy('date');"></input><label for="date" class="" >{helpers:singleElementInList_xQuery("order","chronological")}</label>   
    <input id="alphab"  name="order" type="radio" value="yes" onchange="recorder('alphab');setOrderBy('alphab');"></input><label for="alphab" class="" >{helpers:singleElementInList_xQuery("order","alphabetical")}</label>   
</span>  

};

declare function search:printTipps($node as node(), $model as map(*)) {
    <ul> {
        for $item in helpers:singleElementNode_xquery("search", "search_tips")/tei:span
        return if ($item/@type = "head") then <li id="tips_head">{$item}</li> else <li>{$item}</li>
    }
    </ul>
};