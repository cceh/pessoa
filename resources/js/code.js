function hide(id) {
                        if (document.getElementById(id).style.display == 'none') {
                            document.getElementById(id).style.display ="block";
                            }
                        else {
                            document.getElementById(id).style.display ="none";
                            }
                        };
/*"autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto" */
$(document).ready(function(){
            $("li.mainNavTab").click(function() {
                if(!$(this).hasClass("active")) {
                    $("li.active").removeClass("active");
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
 