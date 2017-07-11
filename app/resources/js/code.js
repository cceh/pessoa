/*"autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto" */
$(document).ready(function(){
            $("ul#navi_elements li.mainNavTab").click(function() {
                if(!$(this).hasClass("active")) {
                    $("ul#navi_elements li.active").removeClass("active");
                    $(this).addClass("active");
                    var id1 = $(this).attr('id');
                    $("div.active").css("display","none");
                    $("div.active").removeClass("active");             
                    $("div#nav_"+id1.substring(8)).addClass("active");
                    $("div#nav_"+id1.substring(8)).css("display","block");
                    $("div#nav_"+id1.substring(8)+" li").click(function() {
                        if(!$(this).hasClass("active")) {
                            $("div#nav_"+id1.substring(8)+" li.active").removeClass("active");
                            $(this).addClass("active");
                            var id2 = $(this).attr('id');
                            var clas = $(this).attr('class');
                            var clas2 = clas.substring(0,clas.search("tab"));
                            if(id2.search("navtab") != -1) {
                                    $("div#"+clas2+"sub div.active").css("display","none");
                                    $("div#"+clas2+"sub div.active").removeClass("active");   
                                    $("div#nav"+id2.substring(6)).addClass("active");
                                    $("div#nav"+id2.substring(6)).css("display","block");
                                    $("div#"+clas2+"sub").addClass("active");
                                    $("div#"+clas2+"sub").css("display","block");             
                                    $("div#nav"+id2.substring(6)+" li.nav_cronologia_sub_tab").click(function() { 
                                        if(!$(this).hasClass("active")) {
                                            $("div#nav"+id2.substring(6)+" li.nav_cronologia_sub_tab.active").removeClass("active");
                                            $(this).addClass("active");
                                            var id = $(this).attr('id');
                                            var clase = $(this).attr('class');
                                            var clase2 = clase.substring(0,clase.search("tab"));
                                            $("div#"+clase2+"ext div.active").css("display","none");
                                            $("div#"+clase2+"ext div.active").removeClass("active");
                                            $("div#"+clase2+"ext").css("display","block");
                                            $("div#"+clase2+"ext").addClass("active");
                                            $("div#"+clase2+"ext_"+id.substring(11)).addClass("active");
                                            $("div#"+clase2+"ext_"+id.substring(11)).css("display","block");
                                        }
                                    });
                            }
                          }
                    });
                }
                else if ($(this).hasClass("active")) {
                    $("div#navi").children("div.navbar").css("display","none");
                    $("div#navi").children("div.navbar").children("div").css("display","none");
                    $("div#navi .active").removeClass("active");
                }
                
                
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
});

$(document).ready(function(){ 
    /*$("div#searchbox").hide();*/
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


 
 
 function DocHide() {
            
           var path = $(location).attr('href');
           
           if(path.search("/en/") != -1) {
            var name =   "Note";
           }
           else if (path.search("/pt/") != -1)  {
               var name ="Nota";
           }
           else {
               var name ="Nota";
           }
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
            $("#text-div").css({"height" : height});            
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
    var pubDate = $("div#titleline").children("#t_add_1").html() + $("div#titleline").children("#t_add_2").html() + $("div#titleline").children("#t_add_3").html() ;
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
           var id2 = id1.substring(3)
           
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
 
 function ObrasHide() {
           $("span.ObLink").click(function() {
           var id1 = $(this).attr("id");
           var id2 = id1.substring(5)
           if(!$(this).hasClass("active")) {
               $(this).addClass("active");
               $("#"+id2).show("slow");
            }
           else {
               $(this).removeClass("active");
                $("#"+id2).hide("slow");
             }
           });
};


function ObrasControl() {
        $("div#Obras-DocLinkList").click(function() {
            $(this).next("ul").toggle("blind","slow"); 
            $(this).toggleClass("selected");
        });
        
        $("span.Obras-WorkName").click(function() {
            $(this).next("div").toggle();
             $(this).toggleClass("selected");
        });
        
        $("div.Obras-SubNav-Publicacao").click(function() {
            $(this).next("span").toggle();
            $(this).toggleClass("selected");
        });
        
        
        $("div.Obras-SubNav-Publication").click(function() {
            $(this).next("ul").toggle();
            $(this).toggleClass("selected");
        });
/*
        $("div.Obras-SubNav").next("div").css("display","block");
        
        $("div.Obras-WorkName").click(function() {
            $(this).nextAll("div").toggle("blind","slow");
            
            if(!$(this).hasClass("selected")) {
                $(this).addClass("selected");
            }
            else {
                $(this).removeClass("selected");
            }
        });
        
        $("div.Obras-SubNav").click(function() {
            $(this).next("div").children("div").toggle("blind","slow");
            
            if(!$(this).hasClass("selected")) {
                $(this).addClass("selected");
            }
            else {
                $(this).removeClass("selected");
            }
           
        });
*/
        
        /*
        $("a.down").click(function(){
            $(this).toggleClass("LinkSelected");
         //   $(this).next("a").toggleClass("clink-show");
            $(this).next("span").toggle("blind","slow");
        });
        */
    };

function drawArrowsEach() {
    
    /*
    for(var i = 1; $('#M'+i).index() != -1;i++) drawArrows(("M"+i),("A"+i))
    };
  
    function drawArrows(el1,el2) {
        var el1 = document.getElementById(el1);
        var el2 = document.getElementById(el2);
        
        var scrollX = window.pageXOffset;
        var scrollY = window.pageYOffset;
        
        var rect1 = el1.getBoundingClientRect();
        var rect2 = el2.getBoundingClientRect();
        
        var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        var svgNS = svg.namespaceURI;
        
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
        
        var path = document.createElementNS(svgNS,'path');
        path.setAttribute('d', 'M ' + (rect1.right + 5 + scrollX) + ' ' + (rect1.bottom + scrollY) + ' A 10 55 0 1 1 ' + (rect2.right + 10 + scrollX) + ' ' + (rect2.top + scrollY));
        path.setAttribute('stroke', '#000000');
        path.setAttribute('fill', 'transparent');
        path.setAttribute('marker-end', 'url(#arr1)');
        
        svg.appendChild(defs);
        svg.appendChild(path);
        
        svg.setAttribute('style', 'position:absolute; top:0; left:0; width:100%; height:100%;')
        document.body.appendChild(svg);
        
    };
    
    */
    var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    var svgNS = svg.namespaceURI;
    var x = $("#M1").position().top;
    var y = $("#M1").position().left;
    var path = document.createElementNS(svgNS,'rect');
    path.setAttribute('fill', 'green');
    path.setAttribute('x', x);
    path.setAttribute('y', y);
    path.setAttribute('width', '20');
    path.setAttribute('height', '20');
    
    svg.appendChild(path);
    
    svg.setAttribute('style', 'position:absolute; top:0; left:0; width:100%; height:100%;')
    document.body.appendChild(svg);
        
        };
    
