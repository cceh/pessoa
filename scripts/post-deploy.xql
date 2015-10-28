xquery version "1.0";

(: adapt config paths to remote system :)

let $conf-file := doc("/db/apps/papyri/conf.xml")
return 
    (
    update replace $conf-file//webapp-root with <webapp-root>http://papyri.uni-koeln.de:8080/apps/papyri</webapp-root>,
    update replace $conf-file//file-path with <file-path>/var/local/papyri/z_images</file-path>,
    update replace $conf-file//request-path with <request-path>/apps/papyri</request-path>,
    update replace $conf-file//webfile-path with <webfile-path>http://papyri.uni-koeln.de/z_images</webfile-path>
    )
