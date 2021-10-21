xquery version "3.1";
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


(: Import the Collector :)
(:
import module namespace collector="http://localhost:8080/exist/apps/magicaldraw/modules/collector" at "xmldb:exist://db/apps/magicaldraw/modules/collector.xqm";


declare function charts:magicaldraw($node as node(), $model as map(*)) {
    let $data-path : "/db/apps/pessoa/data"
    let $db : "doc"
    let $name : "genre"
    let $term : ( "lista_editorial", "nota_editorial","plano_editorial" )
    
    return collector:printResults($data-path,$db,$name,$term)


};
:)
declare %templates:wrap function charts:test($node as node(), $model as map(*)) as node()* {
    let $test := <p> Huhu</p>
  
    return $test
};

declare %templates:wrape function charts:autores($node as node(), $model as map(*)) as node()* {
    let $canvas := <canvas id="chart_autores" width="200" height="200"></canvas>
    let $autores := concat('"',string-join(charts:getAuthors("full"),'","'),'"')
    let $roles := charts:getLists_attribute("roles")
   
   let $script :=  <script>
    Chart.defaults.global.responsive = true;
    var ctx = $("#chart_autores").get(0).getContext("2d");
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
    let $canvas := <canvas id="chartsgenre" width="400" height="400"></canvas>
    let $label := charts:getLists_attribute("genres") 
    
    let $script := <script>
    Chart.defaults.global.responsive = true;
    var ctx = $("#chartsgenre").get(0).getContext("2d");
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
    let $return := concat(charts:Color_Bar($label),',',$optacity)
    return $return
};

declare function charts:Color_Bar($label as xs:string) as xs:string {
    let $color := if($label = "author") then "64,0,255"
                    else if($label = "topic" ) then "106,255,0"
                    else if($label = "translator") then "255,0,0"
                    else if($label = "editor") then "217,255,0"
                    else "220,220,220,0.5"
                return $color
};

declare function charts:Color_Pie ($label as xs:string, $data as xs:string?) as xs:string {
        let $color := if ($data = "" or $data ="doc") then (
                                 if($label = "lista_editorial") then "#FF530D"
                                else if($label = "plano_editorial") then "#40FF2B"
                                else if ($label = "nota_editorial") then "#33C2FF"
                                else if ($label = "poesia") then "#E040FF"
                                else "#000000")
                                else (
                                if($label = "lista_editorial") then "#E82C0C"
                                else if($label = "plano_editorial") then "#1BE845"
                                else if ($label = "nota_editorial") then "#274CFF"
                                else if ($label = "poesia") then "#FF3370"
                                else "#000000")
                                return $color
};


declare function charts:PieData_build($label as xs:string*) as xs:string* {
        for $hit in charts:PieData($label)
            return concat('{value:',$hit/@value/data(.),',color:','"',charts:Color_Pie($hit/@label/data(.),$hit/@data/data(.)),'"',",highlight:", '"#FF5A5E"',',label:"',$hit/@label/data(.),'"}')
        
};


declare function charts:PieData($label as xs:string*) as item()* {
            for $hit in $label
                for $data in ("pub","doc")
                let $value := xs:string(count(charts:searchRange("genre",$hit,$data)))
                return <item value="{$value}" label="{$hit}" data="{$data}"/>
};

declare function charts:searchRange($type as xs:string, $searchname as xs:string, $speci as xs:string?) as node()* {
        let $db := if($speci = "pub") then  collection("/db/apps/pessoa/data/pub")
                        else if ($speci = "doc") then collection("/db/apps/pessoa/data/doc")
                        else collection("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
        let $search_terms := concat('("',$type,'"),"',$searchname,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};


declare function charts:PieChartTable($node as node(), $model as map(*)) as node()* {
        let $authors := charts:getAuthors("key")
        let $dates := ("1900-1909","1910-1919","1920-1929","1930-1935")
        let $labels := charts:getLists_attribute("genres") 
       for $date in $dates 
        return (
        <div style="display:block;float:left">{$date}{
            for $author in $authors return
             <div style='width:150px;heigth:150px' id="div_{concat($date,$author)}">{charts:PieChartCreate(concat($date,$author),$date,$author,$labels)}</div>}</div>)
};

declare function charts:PieChart_build_ex($date as xs:string, $author  as xs:string,$labels as xs:string*) as xs:string* {
    for $hit in charts:PieCharts_data($date,$author,$labels)
            return concat('{value:',$hit/@value/data(.),',color:" ',charts:Color_Pie($hit/@label/data(.), $hit/@data/data(.)),'",highlight: ', '"#FF5A5E"',',label:"',concat($hit/@data/data(.),"-",$hit/@label/data(.)),'"}')
};

declare function charts:PieCharts_data($date as xs:string, $author  as xs:string,$labels as xs:string*) as item()* {
        for $label in $labels
            for $data in ("pub","doc")
               let $db_name := concat("collection('/db/apps/pessoa/data/",$data," ') ")
               let $db :=util:eval($db_name)
                let $v_date := charts:date_build($db,$date)
                let $v_label := charts:searchRange_ex("genre",$label,$v_date) 
             let $v_author := charts:author_build($v_label,$data,$author)
              let $value:= xs:string(count($v_author))
              return <item value="{$value}" label="{$label}" data="{$data}"/>
};

declare function charts:date_build($db as node()*,$dates as xs:string) as node()* {
     let $start := xs:integer(substring-before($dates,"-")) 
     let $end :=   xs:integer(substring-after($dates,"-"))
     let $paras := ("date","date_when","date_notBefore","date_notAfter","date_from","date_to")
     for $date in ($start to $end)
        for $para in $paras
         return  charts:date_search($db,$para,$date)
};

declare function charts:date_search($db as node()*,$para as xs:string,$date as xs:string)as node()* {
        let $search_terms := concat('("',$para,'"),"',$date,'"')
        let $search_funk := concat("//range:field-contains(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

declare function charts:searchRange_ex($type as xs:string, $searchname as xs:string, $db as node()*) as node()* {
        let $search_terms := concat('("',$type,'"),"',$searchname,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

declare function charts:searchRange_ex_two($db as node()*,$para1 as xs:string, $para2 as xs:string, $term1 as xs:string, $term2 as xs:string) as node()*{
        let $merge := concat('("',$para1,",",$para2,'"),','"',$term1,'","',$term2,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
           return util:eval($build_search)
           };

declare function charts:author_build($db as node()*, $data as xs:string, $person as xs:string) as node()* {
        let $roles :=  if($data = "pub") then "person"
                        else if ($data = "doc") then "author"
                        else (search:get-parameters("role"),"person")
           for $role in $roles
                let $merge := concat('("person","role"),','"',$person,'","',$role,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
           return util:eval($build_search)
};


declare function charts:PieChartCreate($id as xs:string, $date as xs:string, $author as xs:string,$labels as xs:string*) as node()* {
    let $canvas := <canvas id="{$id}" width="150" height="150"></canvas>
    
    let $script := <script>
    Chart.defaults.global.responsive = true;
    var ctx = $("#{$id}").get(0).getContext("2d");
    var data = [{string-join(charts:PieChart_build_ex($date,$author,$labels),",")}];
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