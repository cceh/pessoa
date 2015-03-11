xquery version "3.0";
module namespace charts="http://localhost:8080/exist/apps/pessoa/charts";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace app="http://localhost:8080/exist/apps/pessoa/templates" at "app.xql";
import module namespace search="http://localhost:8080/exist/apps/pessoa/search" at "search.xqm";


import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare %templates:wrap function charts:test($node as node(), $model as map(*)) as node()* {
    let $test := <p> Huhu</p>
    let $kuerzel := <p>{charts:getAuthors("key")}</p>
     for $hit in charts:getRoles() 
     let $author := <p>{root($hit)/util:document-name(.)}</p>
    
    return ($test,$author,$kuerzel)
};


declare %templates:wrape function charts:autores($node as node(), $model as map(*)) as node()* {
    let $canvas := <canvas id="autores" width="400" height="400"></canvas>
    let $autores := concat('"',string-join(charts:getAuthors("full"),'","'),'"')
    let $roles := charts:getLists("roles")
    (:concat('"',string-join(charts:getLists("roles"),'","'),'"'):)
   
   let $script :=  <script>
    Chart.defaults.global.responsive = true;
    var ctx = $("#autores").get(0).getContext("2d");
    var data = {{
    labels : [{$autores}],
    datasets: [
    {{ {string-join(charts:createBarChartDatasets($roles),'},{')} }}
    ]
    }};
    var options = {{
                    //Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
                    scaleBeginAtZero : true,
                    //Boolean - Whether grid lines are shown across the chart
                    scaleShowGridLines : true,
                    //String - Colour of the grid lines
                    scaleGridLineColor : "rgba(0,0,0,.05)",
                    //Number - Width of the grid lines
                    scaleGridLineWidth : 1,
                    //Boolean - Whether to show horizontal lines (except X axis)
                    scaleShowHorizontalLines: true,
                    //Boolean - Whether to show vertical lines (except Y axis)
                    scaleShowVerticalLines: true,
                    //Boolean - If there is a stroke on each bar
                    barShowStroke : true,
                    //Number - Pixel width of the bar stroke
                    barStrokeWidth : 2,
                    //Number - Spacing between each of the X value sets
                    barValueSpacing : 5,
                    //Number - Spacing between data sets within X values
                    barDatasetSpacing : 1,
                    //String - A legend template
                    // Deletet    
                    }};
        var myBarChart = new Chart(ctx).Bar(data, options);
    
    </script>
    
   return <p>{$canvas,$script}</p>
   
};

declare function charts:getLists($type as xs:string) as xs:string* {
        let $doc := doc('/db/apps/pessoa/data/lists.xml')    
        for $data in $doc//tei:list[@type = $type and @xml:lang=$helpers:web-language]/tei:item
        return $data/data(.)
};

declare function charts:getAuthors($type as xs:string) as xs:string* {
        let $doc := doc('/db/apps/pessoa/data/lists.xml')    
        for $data in $doc//tei:listPerson[@type="authors"]/tei:person
        return if($type = "full") then $data/tei:persName/data(.)
                else $data/attribute()

};

declare function charts:createBarChartDatasets($labels as xs:string+) as xs:string* {
        for $data in $labels 
        return  concat('label:"',$data,'",'
        ,
        'fillColor: "rgba(220,220,220,0.5)",
        strokeColor: "rgba(220,220,220,0.8)",
        highlightFill: "rgba(220,220,220,0.75)",
        highlightStroke: "rgba(220,220,220,1)",
        data: [65, 59, 80, 81, 56, 55, 40]'
        )
};


declare function charts:getRoles() as node()* {
    for $author in charts:getAuthors("key")
        return charts:createAuthorsRoles($author)
};

declare function charts:createAuthorsRoles($person as xs:string) as node()*{
    let $db := collection("/db/apps/pessoa/data/doc")
    for $role in charts:getLists("roles")
        let $merge := concat('("person","role"),','"',$person,'","',$role,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
           return util:eval($build_search)
           };
