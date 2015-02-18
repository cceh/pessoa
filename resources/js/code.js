function hide(id) {
                        if(document.getElementById(id).style.display == 'none') {
                            document.getElementById(id).style.display ="block";
                            }
                        else {
                            document.getElementById(id).style.display ="none";
                            }
                        }
/*"autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto" */

function u_nav(navID) {
        var IDs = [
        "nav_autores",
        "nav_bibliografia",
        "nav_documentos",
        "nav_documentos_sub",
        "nav_documentos_sub_1",
        "nav_documentos_sub_2",
        "nav_documentos_sub_3",
        "nav_documentos_sub_4",
        "nav_documentos_sub_5",
        "nav_documentos_sub_6",
        "nav_documentos_sub_7",
        "nav_documentos_sub_8",
        "nav_documentos_sub_9",
        "nav_publicacoes",
        "nav_genero",
        "nav_cronologia",
        "nav_cronologia_sub",
        "nav_cronologia_sub_0",
        "nav_cronologia_sub_1",
        "nav_cronologia_sub_2",
        "nav_cronologia_sub_3",        
        "nav_projeto"]
       
       for (i = 0; i<=IDs.length; i++) {
        if(document.getElementById(navID).style.display = "none" && IDs[i].contains(navID)) {
            document.getElementById(navID).style.display = "inline-block"; 
             if(navID.contains("nav_documentos")) {
                        document.getElementById("nav_documentos").style.display = "inline-block";
                        document.getElementById("nav_documentos_sub").style.display = "inline-block";
                }
                else if(navID.contains("nav_cronologia")) {
                    document.getElementById("nav_cronologia").style.display = "inline-block";
                        document.getElementById("nav_cronologia_sub").style.display = "inline-block";
                }
                
        }
        else {
            document.getElementById(IDs[i]).style.display = "none";
           /* if(navID == "nav_documentos_sub" || navID == "nav_cronologia_sub") {
                document.getElementById(IDs.indexOf(IDs[i]-1)).style.display = "block";
            }*/
            }
       }
    };

 