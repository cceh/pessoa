
$(document).ready(function() {


    $("#myInput").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $("#lists ul li").filter(function() {
            $(this).toggle($(this).attr("name").toLowerCase().indexOf(value) > -1)
        });
    });
    $("#menue").click(function() {
       $("#options").toggle();
    });
    $("#menue").mouseover( function() {
        if($("#options").css("display") == "none")$(this).children("h3").show();
    }).mouseleave(
        function() {
            if($("#options").css("display") == "none") $(this).children("h3").hide();
        });

    $("#docu").click(function() {
        $("#docu-con").css("width","100%");
        $(".closebtn").css("display",'inline-block');
    });

    $(".closebtn").click(function() {
        $("#docu-con").css("width","0%");
        $(".closebtn").css("display",'none');
    });

    var BNodes = true,
        BNames = true,
        select = false,
        synopse = false,
        lists = false;

    if($("#emptyNodes").children().children().prop("checked"))  BNodes = true; else  BNodes = false;
    if($("#onName").children().children().prop("checked"))  BNames = true; else  BNames = false;
    if($("#showList").children().children().prop("checked"))  lists = true; else lists  = false;

    $("#showList").children("label").change(function() {
        if(lists == true) { lists = false; }
        else { lists = true; }
        shownElements();
    });
    $("#emptyNodes").children("label").change(function() {
        if(BNodes == true) { BNodes = false; }
        else { BNodes = true; }
        shownElements();
    });

    $("#onName").children("label").change(function() {
        if(BNames == true) {BNames = false; }
        else {BNames = true; }
        shownElements();
    });





    function synopsing() {

        $("svg").remove();
        /*
        var viewport = $("#viewport");

        var width = viewport.width(),
            height = screen.availHeight;
            */
        var width = 3000,
            height = 2000;
        if(synopse == false) {
            drawing(width,height,"view");
        }
        else {
            viewport.append("<div id='view2'/>");
            width = width/2 - 50;
            drawing(width,height,"view");
            drawing(width,height,"view2");
        }


    };

    $("#synopse").click(function() {
        if(synopse == true) {synopse = false; }
        else {synopse = true; }
        synopsing();
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
            shownElements();
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


    function shownElements() {
        if(select == false) {
            $("#emptyNodes").parent().show();
            $("#onName").parent().show();
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
        else {
            $("#emptyNodes").parent().hide();
            $("#onName").parent().hide();
        }
        if(lists === true) $("#lists").show();
            else $("#lists").hide();

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


    function createSliderYear(ele) {
        var select = $( "#"+ele );
        select.change( function() {
            yearSelection(select);

        });
        $(".yearSelectionButton").click(function() {
            $(".yearSelect").removeClass("yearSelect");
            $(this).parent().addClass("yearSelect");

        });
    }

    function createSlider(ele) {
        var select = $( "#"+ele );
        select.change( function() {
            synopsing();

        });
    }

    synopsing();

    createSlider("zoomOfLayout");
    createSliderYear("year");
    createSliderYear("year2");
    createSliderYear("year3");

    $(".slideBarEnter").click(function() {
        $(this).next().toggle();
    });


    function yearSelection(el) {
        synopsing();
    };

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



function drawing(width,height,ank) {
    var bForce = false;

    var myZoom = $("#zoomOfLayout").children("option:selected").attr("value");
    var year = $(".yearSelect").children("select").children("option:selected").attr("value");
    var file = "network/"+year+".json";

    function dynamicSort(property) {
        var sortOrder = 1;
        if(property[0] === "-") {
            sortOrder = -1;
            property = property.substr(1);
        }
        return function (a,b) {
            if(property === "size") var result = (parseInt(a[property]) < parseInt(b[property])) ? -1 : (parseInt(a[property]) > parseInt(b[property])) ? 1 : 0;
                    else var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
            return result * sortOrder;
        }
    };

    function stopForce(chang){
        if(chang) bForce = false;
        if(bForce) {force.stop(); bForce = false} else { force.start(); bForce = true;}
        var seti;
        if(bForce) seti = false; else seti = true;
        $("#stopForce").children("label").children("input").prop("checked",seti);

    };
    $("#stopForce").children("label").change(function() {
        stopForce(false);
    });
    function dynamicSortMultiple() {
        var props = arguments;
        return function (obj1, obj2) {
            var i = 0, result = 0, numberOfProperties = props.length;
            while(result === 0 && i < numberOfProperties) {
                result = dynamicSort(props[i])(obj1, obj2);
                i++;
            }
            return result;
        }
    }
    function sizing(size) {
            if(size == 0) return 2 ;
            else return  Math.round(Math.log2(size)) +2;

    }

    //d3

    var svg = d3.select("#"+ank).append("svg")
        .attr("width", width)
        .attr("height", height);

    var force = d3.layout.force()
        .gravity(0.1)
        .charge(-120)
        .linkDistance(myZoom)
        .size([width, height])
        .on("tick", tick);

    var link = svg.selectAll(".link"),
        node = svg.selectAll(".node");

    d3.json(file, function (error, json) {

        $(document).off("keypress");
        $(document).keypress(function(event) {
            if(event.which === 32 ) stopForce(false);
/*
            if(event.which === 100) {
                var lis = json.links,
                    lis_sum = 0,
                    nodes = json.nodes.length,
                    links = lis.length;
                $.each(lis, function (key, val) {
                    lis_sum = lis_sum + parseInt(val.value);
                });
                alert("Aktuell gibt es  \n"+nodes+" Nodes \n"+links+" Links\n"+lis_sum+" Summierte Links")
            }
            */
        });


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

        var drag = force.drag()
            .on("dragstart", dragstart);

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
            .call(drag);

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



        function dragstart(d) {
            d3.select(this).classed("fixed", d.fixed = true);
            stopForce(true);
        }

        var mX = $(document).width(),
            mY = $(document).height();
        var aX = $(window).width(),
            aY = $(window).height();
        $("#swapSort").off("change");
        $("#swapSort").change(function(){
            createLists($("#swapSort").children("input:checked").attr("id"));
        });
        function createLists(sort) {
            $("#lists").children("ul").children("li").remove();

            $.getJSON(file, function (data) {
                var newAr = new Object();
                $.each(data.nodes, function (key, val) {
                    if (key === 0) {
                        newAr = '{"name":"' + val.name + '","size":"' + val.size + '","source":"' + key + '"},';
                    }
                    else if (key <= data.nodes.length - 2) newAr = newAr + '{"name":"' + val.name + '","size":"' + val.size + '","source":"' + key + '"},';

                    else
                        newAr = newAr + '{"name":"' + val.name + '","size":"' + val.size + '","source":"' + key + '"}';

                });
                newAr = '{"nodes":[' + newAr + ']}';

                var valti = jQuery.parseJSON(newAr);
                var values;
                if(sort === "size") values = valti.nodes.sort(dynamicSortMultiple("-size" )); else values = valti.nodes.sort(dynamicSortMultiple("name"));

               /* $("#lists").append($("#swapSort").clone().css("display", "block").click(function () {
                    if(sort === "size") createLists("alpha"); else createLists("size");
                }));*/
                $.each(values, function (key, val) {
                    if (val.size > 0) $("#lists").children("ul").append('<li source="' + val.source + '"  size="' + val.size + '" name="' + val.name + '" class="listsli"><span>' + val.size + '</span><span>' + val.name + '</span></li>');
                });


                $("#lists ul").children().each(function() {
                    var source = $(this).attr("source");
                    var nod = $("circle.node[source='" + source + "']");

                    $(this).mouseover(function () {
                        $("text.node[source='" + source + "']").css("text-decoration", "underline").css("font-size","14px");
                        nod.css("stroke-width", (nod.attr("r") + "px"));
                    }).mouseleave(function () {
                        $("text.node[source='" + source + "']").css("text-decoration", "none").css("font-size","12px");
                        nod.css("stroke-width", "3.5px");
                    }).click(function () {
                        var vX = parseInt(nod.attr("cx"))+mX-width-aX/2;
                        var vY = parseInt(nod.attr("cy"))+mY-height-aY/2;
                        console.log("x:"+vX+" / y:"+vY);
                        $('html, body').animate({
                            scrollTop: vY,
                            scrollLeft: vX
                        });
                    }).dblclick(function () {
                        if (select === false) {
                            $(".link").hide();
                            $("text").hide();
                            $("circle").hide();
                            connectionShown(source, true);
                            select = true;
                        }
                        else {
                            $(".link").css("stroke", "#777").show();
                            select = false;
                            $("text").show();
                            $("circle").show();
                        }
                        shownElements();

                    });


                });
            });
        };
        createLists($("#swapSort").children("input:checked").attr("id"));
        stopForce(false);
    });


    function tick() {
        /*
         cell
         .data(voronoi(json.nodes))
         .attr("d", function(d) { return d.length ? "M" + d.join("L") : null; });
         */
        link
            .attr("x1", function (d) {
                return d.source.x;
            })
            .attr("y1", function (d) {
                return d.source.y;
            })
            .attr("x2", function (d) {
                return d.target.x;
            })
            .attr("y2", function (d) {
                return d.target.y;
            });

        circle
            .attr("cx", function (d) {
                return d.x;
            })
            .attr("cy", function (d) {
                return d.y;
            })
        ;

        label
            .attr("x", function (d) {
                return d.x + 8;
            })
            .attr("y", function (d) {
                return d.y;
            });
            bForce = true;
    };

    $("#fullscreen").click(function(){
        fullscreen();
    });



    function fullscreen() {
        $("#view").addClass("fullscreen");
        $("svg").remove();
        var zooom = 1;
         var viewport = $("#viewport");

         var width = viewport.width(),
            height = screen.availHeight;
         drawing(width,height,"view");

        $(".fullscreen").mousewheel(function() {
            zooom = zooom +0.1;
            zoomView(zooom)
        });
        $(".fullscreen").unmousewheel(function() {
            zooom = zooom - 0.1;
            zoomView(zooom)
        });
        function zoomView(zooom) {
            $(".fullscreen").children("svg").css("transform", "scale(" + zooom + ")");
        };
    };

}



});