/*"autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto" */

function searching(data, state) {
    $(document).ready(function() {
        if (state === "insert") {
            $("#spezsearch").val(data.term);
            $.each(data.person, function (i, item) {
                $(".selectsearch[name='person']").children("option[value='" + item + "']").attr("selected", "selected");
            });
            $.each(data.genre, function (i, item) {
                $(".selectsearch[name='genre']").children("option[value='" + item + "']").attr("selected", "selected");
            });

            $.each(data.role, function (i, item) {
                $("#" + item).attr("checked", "checked");
            });
            $.each(data.lang, function (i, item) {
                $("#" + item).attr("checked", "checked");
            });

            $(".date_field[name='SE_from']").val(data.from);
            $(".date_field[name='SE_to']").val(data.to);
            $(".release_input-box[value='" + data.release + "']").attr("checked", "checked");
            $(".lang_input-box[value='" + data.lang_ao + "']").attr("checked", "checked");

            if(data.person.length > 0 ||data.role.length > 0 ) {$("#se_author").show(); $("#ta_author").addClass("active");};
            if(data.genre.length > 0) {$("#se_genre").show(); $("#ta_genre").addClass("active");};
            if(data.lang.length > 0 || data.lang_ao != "or") {$("#se_lang").show(); $("#ta_lang").addClass("active");};
            if(data.from != "" || data.to != ""){$("#se_date").show(); $("#ta_date").addClass("active");};
            if(data.release != "all"){$("#se_release").show(); $("#ta_release").addClass("active");};

        }
        else {
            $("#spezsearch").val("");
            $(".date_field[name='SE_from']").val(data.from);
            $(".date_field[name='SE_to']").val(data.to);
            $("option:selected").prop("selected", false);
            $("input:checked").prop("checked", false);

            $(".release_input-box[value='all']").prop("checked", true);
            $(".lang_input-box[value='or']").prop("checked", true);
        }
        $("#clearing").click(function() {searching("","clear");});

    });

}
$(document).ready(function(){


    if(GetURLParameter('l') == "f") $('#login-modal').modal('show');

    $(".button").children("span").click(function() {
        var par = $(this).parent();
        var acN = par.attr("active");
        var active = "active"+acN;
        var chil = par.children("div").attr('active','true');

        if(!par.hasClass(active)) {
            for(var i = acN; i <= 3; i++) {
                var actC = "active"+i;
                var act = $("."+actC);
                act.children("div").attr('active','false').hide();
                act.removeClass(actC);
            }
            par.addClass(active);
            chil.show();
           // alert(par.parent("ul").height());
            if(chil.children("ul").hasClass("NAVI_quadNav")) chil.css("top",par.parent("ul").height() +20);
        }
        else {
            $("."+active).children("div").attr('active','false').hide();
            $("."+active).removeClass(active);
        }
        if(!($("#searchbox").css("display") == "none")) $("#searchbox").hide();
        var h = 42;
        $('#navi').find('div[active="true"]').each(function() {
            h = h + $(this).height();
        });
        console.log(h);
        $('#content.container').css('margin-top',h);
    });
        });
        function fixDiv() {
            var $cache = $('#openseadragon1');
            var pos = $("#indextab").position().top +100;
                     if ($(window).scrollTop() > pos )
                       $cache.css({
                       'position': 'fixed',
                       'top': '10px'
                       });
                       else
                       $cache.css({
                       'position': 'relative',
                       'top': 'auto'
                       });
                   
                   };
                   
        function calcImage() {
        var height = $(".header-image").width()  * 0.75;
            $(".header-image").each(function() {
                $(this).css( {"height" : height} );
                
            });     
            $("#page-header").css({"height" : height});
        };
        

$(document).ready(function(){
	//Check to see if the window is top if not then display button
	$(window).scroll(function(){
		if ($(this).scrollTop() > 100) {
			$('.ScrollToTop').fadeIn();
		} else {
			$('.ScrollToTop').fadeOut();
		}
	});
	//Click event to scroll to top
	$('.ScrollToTop').click(function(){
		$('html, body').animate({scrollTop : 0},800);
		return false;
	});
    $("a#search_button").click(function() {

        if(!$(this).hasClass("active")) {
            $(this).addClass("active");
            $("div#searchbox").show();
        }
        else {
            $(this).removeClass("active");
            $("div#searchbox").hide();
        }
    });
});



 
 
 function DocHide(name) {
        $("div.editorial-note").before("<span class='nota' id='nota_top'>"+name+"</span>");
        $("div.editorial-note").after("<span class='nota' id='nota_bottom'>"+name+"</span>");

         $("span.nota").click(function() {
           
           if(!$(this).hasClass("selected")) {
               $("#nota_bottom").addClass("selected");
               $("#nota_top").addClass("selected");
               $(".editorial-note").show("slow");
               $("#nota_bottom").show();
            }
           else {
               $("#nota_bottom").removeClass("selected");
               $("#nota_top").removeClass("selected");
                $(".editorial-note").hide("slow");
                $("#nota_bottom").hide();
             }
             calcFacsimilie();
           });
           
           
            
 };
 
 function itabs() {
     $(".itabs").click(function() {
        calcFacsimilie();
     });
 };
 function calcFacsimilie() {
            var height_img = $("#img-div").height();
            var height_text = $("#text-div").height();
             var height = height_img > height_text ? height_img : height_text;
            $("#text-div").css({"height" : height}).ready( function() {
                drawArrowsEach();
            });
        };
function printContent() {
            if( $("div#text-div").children("ul").children("li").hasClass("selected") ) { 
            var id = $("div#text-div").children("ul").children("li.selected").children("div").attr("id");  
            }
            else {
            var id = "text-div";
            }
            var headerContent = $("div#titleline").children("div").html();
            var zitatContent =  $("div#cite").html();
            var htmlContents = document.getElementById(id).innerHTML;
            
            var printContents = zitatContent+headerContent+htmlContents;
                 var originalContents = document.body.innerHTML;
                 var newWindow = window.open("","newWindow");
                 newWindow.document.write (printContents);
                 newWindow.print();                 
                 newWindow.close();
            };

function printPub() {

    if( $("div#text-div").children("ul").children("li").hasClass("selected") ) {
        var id = $("div#text-div").children("ul").children("li.selected").children("div").attr("id");
    }
    else {
        var id = "text-div";
    }
    var headerContent = $("div#titleline").children().html();
    var pubDate = $("div#titleline").children("#t_add_1").html()+" " + $("div#titleline").children("#t_add_2").html() + " <b>"+$("div#titleline").children("#t_add_3").html()+"</b>" ;
    var zitatContent =  $("div#cite").html();
    var htmlContents = document.getElementById(id).innerHTML;

    var printContents = zitatContent+pubDate+htmlContents;
    var originalContents = document.body.innerHTML;
    var newWindow = window.open("","newWindow");
    newWindow.document.write (printContents);
    newWindow.print();
    newWindow.close();
};

function SearchHide() {
    $("div.tab").click(function() {
       var id1 = $(this).attr("id");
           var id2 = id1.substring(3);
           
           if(!$(this).hasClass("active")) {
               $(this).addClass("active");
               $("div#se_"+id2).show();
            }
           else {
               $(this).removeClass("active");
                $("div#se_"+id2).hide();
             }
           });
     
 };
 
 
 
 /*############## Obras Control ############*/


function drawArrowsEach() {
    $('#svg1').remove();
    var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    var svgNS = svg.namespaceURI;

    var a = $('#text-div').children('.text');
    var anker = a.offset();
    var w = a.width();
    var h = a.height();

    var defs = document.createElementNS(svgNS, 'defs');
    var marker = document.createElementNS(svgNS, 'marker');
        marker.setAttribute('id', 'arr1');
        marker.setAttribute('viewBox', '0 0 10 10');
        marker.setAttribute('refX', '0');
        marker.setAttribute('refY', '5');
        marker.setAttribute('markerUnits', 'strokeWidth');
        marker.setAttribute('markerWidth', '10');
        marker.setAttribute('markerHeight', '10');
        marker.setAttribute('orient', 'auto');

    var markerpath = document.createElementNS(svgNS, 'path');
        markerpath.setAttribute('d', 'M 0,0 l 10,5 l -10,5 z');

        marker.appendChild(markerpath);
        defs.appendChild(marker);
        svg.appendChild(defs);


        svg.setAttribute('style', 'position:absolute; top:0px; left:0px; width:'+w+'px; height:'+h+'px; display:block; z-index:-5;');
        svg.setAttribute('id','svg1');

    jsBlockStrikeThrough(svg,anker.top,anker.left,w,h);
    for(var i = 1; $('#M'+i).index() != -1;i++) drawArrows(svg,("M"+i),("A"+i),anker.top,anker.left);

    a.append(svg);



};

function jsBlockStrikeThrough(svg,t,l,w,h) {
    var svgNS = svg.namespaceURI;
    var span = $(".delSpan");

     span.each( function() {
         var el = $(this).offset();
         var x1 = el.left - l +5;
         var y1 = el.top - t;
         var x2 = w;
         var y2 = h;
         var line1 = document.createElementNS(svgNS,'line');
                 line1.setAttribute("x1",x1);
                 line1.setAttribute("y1",y1);
                 line1.setAttribute("x2",x2);
                 line1.setAttribute("y2",y2);
                line1.setAttribute("class","delLine");

             svg.appendChild(line1);

         var line2 = document.createElementNS(svgNS,'line');
                 line2.setAttribute("x1",x2);
                 line2.setAttribute("y1",y1);
                 line2.setAttribute("x2",x1);
                 line2.setAttribute("y2",y2);
                 line2.setAttribute("class","delLine");
                 svg.appendChild(line2);
     })


}


    function drawArrows(svg,el1,el2,t,l) {
        var svgNS = svg.namespaceURI;

        el1 = $("#"+el1);
        el2 = $("#"+el2);
        var direction = el1.attr("class");
        var a = pathMove(direction.substring(17,direction.length));
        
        var off = getOffset(direction.substring(17,direction.length));

        el1 = el1.offset();
        var x1 = el1.left - l + parseInt(off[0]);
        var y1 = el1.top - t + parseInt(off[2]);

        el2 = el2.offset();
        var x2 = el2.left - l + parseInt(off[1]);
        var y2 = el2.top - t + parseInt(off[3]);
        var path = document.createElementNS(svgNS,'path');
                    path.setAttribute('d', 'M ' + x1 + ' ' + y1 + ' A '+ a + x2 + ' ' + y2);
                    path.setAttribute('stroke', '#000000');
                    path.setAttribute('fill', 'transparent');
                    path.setAttribute('marker-end', 'url(#arr1)');

        svg.appendChild(path);
    

        
        };
    
    function getOffset(direction){
      var off = new Array();
      var ox1,ox2,oy1,oy2;
      switch(direction) {
            case "arrow-right-curved-up": ox1 = 0; ox2 = 10; oy1 = 10; oy2 = 20; break; //  geht von unten nach oben, nach rechts gekrümmt)
            case "arrow-right-curved-down":  ox1 = 0; ox2 = 0; oy1 = 0; oy2 = 0; break; // (= geht von oben nach unten, nach rechts gekrümmt)
            case "arrow-left-curved-up":  ox1 = 0; ox2 = 0; oy1 = 0; oy2 = 0; break; // (=geht von unten nach oben, nach links gekrümmt)
            case "arrow-left-curved-down":  ox1 = 0; ox2 = 0; oy1 = 10; oy2 = 10; break;// (=geht von oben nach unten, nach links gekrümmt)
            case "arrow-left-down":  ox1 = 10; ox2 = 10; oy1 = 10; oy2 = 0; break; //(=nach links ausgerichteter Pfeil, der gerade, nicht gekrümmt, nach unten geht)
            case "arrow-left-up":   //(=nach links ausgerichteter Pfeil, der gerade nach oben geht)
            case "arrow-right-down": ox1 = 0; ox2 = 0; oy1 = 10; oy2 = 0; break; // (=nach rechts ausgerichteter Pfeil, der gerade nach unten geht)
            case "arrow-right-up":   //(=nach rechts ausgerichteter Pfeil, der gerade nach oben geht)
            case "arrow-up":  //(=Pfeil, der gerade nach oben geht, ohne links oder rechts; vermutlich sind die gerade Pfeile technisch alle gleich zu behandeln, halt von A nach B ohne Krümmung, im TEI macht die Unterscheidung aber noch inhaltlich Sinn)
            case "arrow-down":  ox1 = 0; ox2 = 0; oy1 = 0; oy2 = 0; break; //(=Pfeil, der gerade nach unten geht)
            default: return ox1 = 0; ox2 = 0; oy1 = 0; oy2 = 0; break;

        }
      return off = [ox1,ox2,oy1,oy2];
    };

    function pathMove(direction) {
        var a = "";
        switch(direction) {
            case "arrow-right-curved-up": a = "10 15 0 1 0"; break; //  geht von unten nach oben, nach rechts gekrümmt)
            case "arrow-right-curved-down":  a = "10 15 0 1 1"; break; // (= geht von oben nach unten, nach rechts gekrümmt)
            case "arrow-left-curved-up":  a = "10 15 0 1 1"; break; // (=geht von unten nach oben, nach links gekrümmt)
            case "arrow-left-curved-down":  a = "10 15 0 1 0"; break;// (=geht von oben nach unten, nach links gekrümmt)
            case "arrow-left-down":    //(=nach links ausgerichteter Pfeil, der gerade, nicht gekrümmt, nach unten geht)
            case "arrow-left-up":   //(=nach links ausgerichteter Pfeil, der gerade nach oben geht)
            case "arrow-right-down":   // (=nach rechts ausgerichteter Pfeil, der gerade nach unten geht)
            case "arrow-right-up":   //(=nach rechts ausgerichteter Pfeil, der gerade nach oben geht)
            case "arrow-up":  //(=Pfeil, der gerade nach oben geht, ohne links oder rechts; vermutlich sind die gerade Pfeile technisch alle gleich zu behandeln, halt von A nach B ohne Krümmung, im TEI macht die Unterscheidung aber noch inhaltlich Sinn)
            case "arrow-down":  a = "0 0 0 1 1"; break; //(=Pfeil, der gerade nach unten geht)
            default: return a = "10 10 0 1 1"; break;

        }
        return a;
    };
    
    function GetURLParameter(sParam){
        var sPageURL = window.location.search.substring(1);
        var sURLVariables = sPageURL.split('&');
        for (var i = 0; i < sURLVariables.length; i++) {
            var sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] == sParam) {
                return sParameterName[1];
            }
        }
            }

function mail(part1,part4) {
    var part2= Math.pow(2,6);
    var part3 = String.fromCharCode(part2);
    var part5 = part1+ String.fromCharCode(part2) + part4;
    document.write('<a class="pLink" href="'+"mai"+"lto"+":"+part5+'">'+part1+part3+part4+'</a>')
};