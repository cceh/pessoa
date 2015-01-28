xquery version "3.0";

module namespace page="http://localhost:8080/exist/apps/pessoa/page";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare %templates:wrap function page:construct($node as node(), $model as map(*)) as node()* {
    let $lang := request:get-parameter("lang",'')
    let $doc := doc("/db/apps/pessoa/data/lists.xml")
    let $nav := page:createNav()
    let $lists :=            
    
            <ul id="navi" class="nav nav-tabs" role="tablist">
                {$nav}
                <li>                    
                  <div class="box">
                        <div class="container-4">
                            <input type="search" id="search" placeholder="Search..." />
                            <button class="icon" id="button" onclick="search()"><i class="fa fa-search" ></i>
                                </button>
                        </div>
                    </div>                  
                </li>
            </ul>
            
    let $switchlang := <script>function switchlang(value){{location.href="{$helpers:app-root}/?lang="+value;}}</script>
    let $return := ($lists, $switchlang)
    return $return
};


declare function page:createNav() as node()* {
let $type := ("autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto")
let $doc := doc("/db/apps/pessoa/data/lists.xml")
let $lang := if(request:get-parameter("lang",'')!="") then request:get-parameter("lang",'') else "pt"
for $target in $type 
    let $name := if($lang = "pt") then $doc//tei:term[@xml:lang = $lang and @xml:id= $target]
                                  else $doc//tei:term[@xml:lang = $lang and @corresp= concat("#",$target)]
   return <li><a href="{$target}" role="tab" data-toggle="tab">{$name}</a></li>
};