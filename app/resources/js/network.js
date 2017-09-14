
$(document).ready(function() {

    $(window).scroll(function(){
        if ($(this).scrollTop() > 100) {
            $('#menue').show();
            if(!$("#options").hasClass("shown")) $('#options').hide();
        } else {
            $('#menue').hide();
            $('#options').show();
            $('#options').removeClass("shown");
        }
    });

    $("#menue").click(function() {
       $("#options").toggleClass("shown");
       if($("#options").hasClass("shown")) $("#options").show();
        else $("#options").hide();
    });

    var BNodes = true;
    var BNames = true;
    var select = false;

    $("#emptyNodes").click(function() {
        if(BNodes == true) { $(this).html("no");  BNodes = false; }
        else { $(this).html("yes"); BNodes = true; }
        shownElements();
    });

    $("#onName").click(function() {
        if(BNames == true) { $(this).html("no"); BNames = false; }
        else { $(this).html("yes"); BNames = true; }
        shownElements();
    });
function innerNet() {
    $(".node").dblclick(function() {
        var source = $(this).attr("source");

        if(select == false) {
            $(".link").hide();
            $("text").hide();
            $("circle").hide();
            connectionShown(source,true)
            select = true;
        }
        else {
            $(".link").css("stroke","#777");
            select = false;
            $(".link").show();
            $("text").show();
            $("circle").show();

            shownElements();
        }
    });
};

/*

    var voronoi = d3.geom.voronoi()
        .x(function(d) { return d.x; })
        .y(function(d) { return d.y; })
        .clipExtent([[0, 0], [width, height]]);
  */


    function shownElements() {
        if(select == false) {
            if(BNodes == true) {
                $(".emptyNode").show();
            }
            else {
                $(".emptyNode").hide();
            }

            if(BNames == true) {
                $("text.node").show();
                if(BNodes == true ) $("text.emptyNode").show();
            }
            else {
                $("text.node").hide();
                if (BNodes == true) $("text.emptyNode").hide();
            }
        }
    };

    function connectionShown(source,sta) {
        if(sta == true) {
            var tex = $("text.node[source='"+source+"']")
            tex.css("text-decoration","underline");
            tex.show();
            $(this).css("stroke-width",($(this).attr("r")+ "px"));

             if(select == false) {

                 var sou = $(".link[source='" + source + "']")
                 var tar = $(".link[target='" + source + "']")

                 sou.each(function () {
                     $(".node[source='" + $(this).attr("target") + "']").show();
                 });
                 tar.each(function () {
                     var parent = $(this).attr("source");
                     $(".node[source='" + parent + "']").show();
                     var inn = $(".link[target='" + source + "']");
                     inn.show();
                     inn.css("stroke", "#990000");
                 });

                 $(".node[source='" + source + "']").show();

                 sou.show();
                 sou.css("stroke", "#990000");
                 tar.show();
                 tar.css("stroke", "#990000");
             }
       }
        else {
            if(select == false) {
                $(".link").css("stroke", "#777");
                $(this).css("stroke-width","3.5px");
            }
            $("text.node[source='"+source+"']").css("text-decoration","none");
            shownElements();
        }
    }


    function makeLine() {
        $(".node").mouseover( function() {
            connectionShown($(this).attr('source'),true)
        }).mouseleave(
            function() {
                connectionShown($(this).attr('source'),false);
            });
    };

/*
    function innerNet() {
        var source = $(this).attr("source");

        if(select == false) {
            $(".link").hide();
            $("text").hide();
            $("circle").hide();
            connectionShown(source,true)
            select = true;
        }
        else {
            $(".link").css("stroke","#777");
            select = false;
            $(".link").show();
            $("text").show();
            $("circle").show();

            shownElements();
        }
    };
*/

    drawing();

    $("#zoomOfLayout").change( function() {
        $("svg").remove();
        drawing();
    });
    $("#year").change( function() {
        $("svg").remove();
        drawing();
    });

function myColor (chooseColor)
{ switch(chooseColor){
    case 1: return "#193a99";
    case 0: return "#4d94b2";
    default: return "#000";
}
}


function classes(size) {
    if(size == 0) return "emptyNode"
    else return "node";
}


function drawing() {
    var myZoom = $("#zoomOfLayout").children("option:selected").attr("value");
    var year = $("#year").children("option:selected").attr("value");
    var file = "network/"+year+".json";


    function sizing(size) {
        if (year != "network") {
            if (size == 0) return 2
            else if (size <= 10) return size + 2
            else if (10 < size < 20) return size + 1
            else if (size > 20) return size
            else return size + 2;
        }
        else {
            if(size < 10) return 2
            else return size/10*2;
        }
    }

    //d3
    var width = 3000,
        height = 2000;

    var svg = d3.select("#view").append("svg")
        .attr("width", width)
        .attr("height", height);

    var force = d3.layout.force()
        .gravity(0.1)
        .charge(-120)
        .linkDistance(myZoom)
        .size([width, height])
        .on("tick", tick);
    /**
     var drag = force.drag()
     .on("dragstart", test);
     **/

    var link = svg.selectAll(".link"),
        node = svg.selectAll(".node");

    d3.json(file, function (error, json) {
        if (error) throw error;
        force
            .nodes(json.nodes)
            .links(json.links)
            .start();

        link = link.data(json.links)
            .enter().append("line")
            .attr("class", "link")
            .attr("stroke-width", function (d) {
                return d.value;
            })
            .attr("source", (function (d) {
                return d.source.index;
            }))
            .attr("target", function (d) {
                return d.target.index;
            });

        circle = node.data(json.nodes)
            .enter().append("circle")
            .attr("class", function (d) {
                return classes(d.size)
            })
            .attr("fill", (function (d) {
                return myColor(d.group);
            }))
            .attr("stroke", (function (d) {
                return myColor(d.group);
            }))
            .attr("r", function(d) {return sizing(d.size)})
            .attr("source", function (d) {
                return d.index;
            })
            .call(force.drag);

        label = node.data(json.nodes)
            .enter().append("text")
            .attr("dy", ".95em")
            .attr("class", function (d) {
                return classes(d.size)
            })
            .attr("source", function (d) {
                return d.index;
            })
            .text(function (d) {
                return d.name;
            });
        /*
         cell = node.data(json.nodes)
         .enter().append("path")
         .attr("class", "cell");
         */
        makeLine();
        innerNet();
        shownElements();
    });


    function tick() {
        /*
         cell
         .data(voronoi(json.nodes))
         .attr("d", function(d) { return d.length ? "M" + d.join("L") : null; });
         */
        link
            .attr("x1", function(d) { return d.source.x; })
            .attr("y1", function(d) { return d.source.y; })
            .attr("x2", function(d) { return d.target.x; })
            .attr("y2", function(d) { return d.target.y; });

        circle
            .attr("cx", function(d) { return d.x; })
            .attr("cy", function(d) { return d.y; })
        ;

        label
            .attr("x", function(d) { return d.x + 8; })
            .attr("y", function(d) { return d.y; });

    };

}


});