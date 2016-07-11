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
        
        /*
        function jsBlockStrikeThrough(block) {
				var backgrWidth = document.getElementById(block).offsetWidth;
				var backgrHeight = document.getElementById(block).offsetHeight;
				var newSize = '';

				newSize = newSize.concat(backgrWidth, 'px' , ' ', backgrHeight, 'px');

				document.getElementById(block).style.backgroundImage = "url('../images/Kreuz.png')";
				document.getElementById(block).style.backgroundSize = newSize;
			}
        */
         
                   
                   
                   
                   
        });
        function fixDiv() {
        var $cache = $('#openseadragon1');
        
        
                 if ($(window).scrollTop() > 716)
                   $cache.css({
                   'position': 'fixed',
                   'top': '10px'
                   });
                   else
                   $cache.css({
                   'position': 'relative',
                   'top': 'auto'
                   });
                   
                   }
                   
        function calcImage() {
        var height = $(".header-image").width()  * 0.75;
            $(".header-image").each(function() {
                $(this).css( {"height" : height} );
                
            });     
            $("#page-header").css({"height" : height});
        };
        
        
/*
function  jsBlockStrikeThrough(uri) {
            $('.delSpan').each(function() {
                var backgrWidth = $(this).css("width");
                var backgrHeight = $(this).css("height");
                var newSize = '';
                var image = uri +'../../resources/images/Kreuz.png';
                
                newSize = newSize.concat(backgrWidth, 'px' , ' ', backgrHeight, 'px');
                $(this).css({"background-image" : "url("+image+")",
                                                                            "width" : backgrWidth,
                                                                            "height" : backgrHeight });
            })            
       };*/
/*
        function  jsBlockStrikeThrough() {
            $('.delSpan').each(function() {
                var backgrWidth = $(this).document.offsetWidth;
                var backgrHeight = $(this).offsetHeight;
                var newSize = '';
                newSize = newSize.concat(backgrWidth, 'px' , ' ', backgrHeight, 'px');
                $(this).css({"background-image" : "url('images/Kreuz.png')",
                                                                            "width": backgrWidth,
                                                                            "height":backgrHeight});
            })            
        };
        */
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
           });
           
           
            
 };
 
 function itabs() {
     $(".itabs").click(function() {
        calcFacsimilie();
     });
 };
 function calcFacsimilie() {
            var height = $("#img-div").height();
            $("#text-div").css({"height" : height});            
        };
 
 function draw(w, h) {
 
 /*
  if(is.firefox() == true) {
      var  ctx1= document.getElementsByClassName("delSpan");
        var canvas = ctx1.getContext("2d");
        var  ctx2= document.getElementsByClassName("verticalLine");
        var canvas2 = ctx2.getContext("2d");
        var  ctx3= document.getElementsByClassName("circled");
        var canvas3 = ctx3.getContext("2d");
  } 
  else {
      var canvas = document.getCSSCanvasContext("2d", "lines", w, h); 
      var canvas2 = document.getCSSCanvasContext("2d", "verticalLine", w, h);
      var canvas3 = document.getCSSCanvasContext("2d", "circle", w, h);
  }
 */
            var canvas = document.getCSSCanvasContext("2d", "lines", w, h); 
      var canvas2 = document.getCSSCanvasContext("2d", "verticalLine", w, h);
      var canvas3 = document.getCSSCanvasContext("2d", "circle", w, h);
            canvas.strokeStyle = "rgb(0,0,0)";
            canvas.beginPath();
            canvas.moveTo( 0,0);
            canvas.lineTo( w, h );
            canvas.stroke();
            
            
            canvas2.strokeStyle = "rgb(0,0,0)";
            canvas2.beginPath();
            canvas2.moveTo( 0,0);
            canvas2.lineTo( 10,60 );
            canvas2.stroke();
            
            
            canvas3.strokeStyle = "rgb(0,0,0)";
            canvas3.beginPath();
            canvas3.arc(12,12,12,0,2*Math.PI);
            canvas3.stroke();
            };
 

function printContent() {
            if( $("div#text-div").children("ul").children("li").hasClass("selected") ) { 
            var id = $("div#text-div").children("ul").children("li.selected").children("div").attr("id");  
            }
            else {
            var id = "text-div";
            }
            var headerContent = $("div#titleline").children("div").html();
            var zitatContent =  $("div#dialog").html();
            var htmlContents = document.getElementById(id).innerHTML;
            
            var printContents = zitatContent+headerContent+htmlContents;
                 var originalContents = document.body.innerHTML;
                 var newWindow = window.open("","newWindow");
                 newWindow.document.write (printContents);
                 newWindow.print();                 
                 newWindow.close();
                 
            /*
            document.body.innerHTML = printContents;
                window.print();
                document.body.innerHTML = originalContents;
              */
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

  
    
    
