(:~
 : Disclaimer: Code adapted from eXistdb 2.2 - GNU-LGPL (the specific version of the 
 : license is not available anymore, possibily 'Only'). A new version of this project 
 : with an updated eXist implementation (along with specific licensing) will be 
 : published soon.
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.1";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

(: 
 : The following modules provide functions which will be called by the 
 : templating.
 :)
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace app="http://localhost:8080/exist/apps/pessoa/templates" at "app.xql";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace pub="http://localhost:8080/exist/apps/pessoa/pub" at "pub.xqm";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";
import module namespace author="http://localhost:8080/exist/apps/pessoa/author" at "author.xqm";
import module namespace page="http://localhost:8080/exist/apps/pessoa/page" at "page.xqm";
import module namespace charts="http://localhost:8080/exist/apps/pessoa/charts" at "charts.xqm";
import module namespace index="http://localhost:8080/exist/apps/pessoa/index" at "index.xqm";

(:~import MagicalDraw :)
(:
import module namespace collector="http://localhost:8080/exist/apps/magicaldraw/modules/collector" at "xmldb:exist://db/apps/magicaldraw/modules/collector.xqm";
:)
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers";

declare option exist:serialize "method=html5 media-type=text/html enforce-xhtml=yes";

let $config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return
    templates:apply($content, $lookup, (), $config)