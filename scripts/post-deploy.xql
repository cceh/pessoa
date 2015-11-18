xquery version "1.0";

(: adapt config paths to remote system :)

let $conf-file := doc("/db/apps/pessoa/conf.xml")
return 
    (
    update replace $conf-file//webapp-root with <webapp-root>http://projects.cceh.uni-koeln.de:8080/apps/pessoa</webapp-root>,
    update replace $conf-file//request-path with <request-path>/apps/pessoa</request-path>,

    )
