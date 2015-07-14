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
 
 
 function DocHide() {
        $("div.editorial-note").before("<span>Note</span>");
         $("span.note").click(function() {
           
           if(!$(this).hasClass("active")) {
               $(this).addClass("active");
               $(".editorial-note").show();
            }
           else {
               $(this).removeClass("active");
                $(".editorial-note").hide();
             }
           });
 }
 
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
 