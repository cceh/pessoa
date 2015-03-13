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
 
     (:let $author := <p> {charts:getRoles()}</p>
    :)
    return ($test,$kuerzel)
};


declare %templates:wrape function charts:autores($node as node(), $model as map(*)) as node()* {
    let $canvas := <canvas id="autores" width="200" height="200"></canvas>
    let $autores := concat('"',string-join(charts:getAuthors("full"),'","'),'"')
    let $roles := charts:getLists_attribute("roles")
   
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
                    //multiTooltipTemplate - Template of the Tooltip Legend
                    multiTooltipTemplate: {concat('"<%= datasetLabel %>',' - <%= value %>"')},
                    //String - A legend template
                    legendTemplate :{concat("'<ul>'","+'<% for (var i=0; i<datasets.length; i++) {{ %>'+'<li>'+'<span style=\",'"',"background-color:<%=datasets[i].lineColor%>\",'"',"></span>'","+'<% if (datasets[i].label) {{ %><%= datasets[i].label %><% }} %>'+'</li>'+'<% }} %>'+'</ul>'")}
                    }};
        var myBarChart = new Chart(ctx).Bar(data, options);
    </script>
    
   return <p>{$canvas,$script}</p>
   
};
declare function charts:genre($node as node(), $model as map(*)) as node()* {
    let $canvas := <canvas id="genre" width="400" height="400"></canvas>
    let $label := charts:getLists_attribute("genres") 
    
    let $script := <script>
    Chart.defaults.global.responsive = true;
    var ctx = $("#genre").get(0).getContext("2d");
    var data = [{string-join(charts:PieData_build($label),",")}];
    var options = {{
                //Boolean - Whether we should show a stroke on each segment
               segmentShowStroke : true,
               //String - The colour of each segment stroke
               segmentStrokeColor : "#fff",
               //Number - The width of each segment stroke
               segmentStrokeWidth : 2,
               //Number - The percentage of the chart that we cut out of the middle
               percentageInnerCutout : 0, // This is 0 for Pie charts
               //Number - Amount of animation steps
               animationSteps : 100,
               //String - Animation easing effect
               animationEasing : "easeOutBounce",
               //Boolean - Whether we animate the rotation of the Doughnut
               animateRotate : true,
               //Boolean - Whether we animate scaling the Doughnut from the centre
               animateScale : true,
     }}
    var myPieChart = new Chart(ctx).Pie(data, options);

    </script>
    
    return <p>{$canvas,$script}</p>
    
};
declare function charts:getLists_data($type as xs:string) as xs:string* {
        let $doc := doc('/db/apps/pessoa/data/lists.xml')    
        for $data in $doc//tei:list[@type = $type and @xml:lang=$helpers:web-language]/tei:item
        return $data/data(.)
};

declare function charts:getLists_attribute($type as xs:string) as xs:string* {
        let $doc := doc('/db/apps/pessoa/data/lists.xml')    
        for $data in $doc//tei:list[@type = $type and @xml:lang=$helpers:web-language]/tei:item
        return if(substring-after($data/attribute(),"#") != "") then substring-after($data/attribute(),"#")
             else $data/attribute()
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
        'fillColor: "rgba(',charts:getColor("0.5",$data),')",
        strokeColor: "rgba(',charts:getColor("0.8",$data),')",
        highlightFill: "rgba(',charts:getColor("0.75",$data),')",
        highlightStroke: "rgba(',charts:getColor("1",$data),')",
        data: [',string-join(charts:getRoles($data),','),']'
        )
};

declare function charts:getRoles($role as xs:string) as xs:string* {
    for $author in charts:getAuthors("key")
        return xs:string(charts:createAuthorsRoles($author, $role))
};

declare function charts:createAuthorsRoles($person as xs:string, $role as xs:string) as xs:integer*{
    let $db := collection("/db/apps/pessoa/data/doc")
  (:  for $role in charts:getLists_attribute("roles"):)
        let $merge := concat('("person","role"),','"',$person,'","',$role,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
           return count(util:eval($build_search))
           };

declare function charts:getColor($optacity as xs:string, $label as xs:string) as xs:string {
    let $return := concat(charts:Color($label),',',$optacity)
    return $return
};

declare function charts:Color($label as xs:string) as xs:string {
    let $color := if($label = "author") then "64,0,255"
                    else if($label = "topic") then "106,255,0"
                    else if($label = "translator") then "255,0,0"
                    else if($label = "editor") then "217,255,0"
                else "220,220,220,0.5"
                return $color
};

declare function charts:PieData_build($label as xs:string*) as xs:string* {
        for $hit in charts:PieData($label)
            return concat('{value:"',$hit/@value/data(.),'",color:','"#F7464A"',",highlight:", '"#FF5A5E"',',label:"',$hit/@label/data(.),'"}')
        
};


declare function charts:PieData($label as xs:string*) as item()* {
            for $hit in $label
                let $value := xs:string(count(charts:searchRange("genre",$hit)))
                return <item value="{$value}" label="{$hit}"/>
};

declare function charts:searchRange($type as xs:string, $searchname as xs:string) as node()* {
        let $db := collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
        let $search_terms := concat('("',$type,'"),"',$searchname,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

