function hide(id) {
                        if (document.getElementById(id).style.display == 'none') {
                            document.getElementById(id).style.display ="block";
                            }
                        else {
                            document.getElementById(id).style.display ="none";
                            }
                        };
/*"autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto" */

function u_nav(navID) {
       
       var IDs = new Array ("nav_autores","nav_bibliografia","nav_documentos","nav_documentos_sub",
       "nav_documentos_sub_1","nav_documentos_sub_2","nav_documentos_sub_3","nav_documentos_sub_4","nav_documentos_sub_5","nav_documentos_sub_6","nav_documentos_sub_7","nav_documentos_sub_8","nav_documentos_sub_9",
      "nav_documentos_sub_10","nav_documentos_sub_20","nav_documentos_sub_30","nav_documentos_sub_40","nav_documentos_sub_50","nav_documentos_sub_60","nav_documentos_sub_70","nav_documentos_sub_80","nav_documentos_sub_90",
       "nav_publicacoes",
       "nav_publicacoes_sub",
       "nav_publicacoes_sub_FP","nav_publicacoes_sub_AC","nav_publicacoes_sub_AdC","nav_publicacoes_sub_RR",
       "nav_obras",
       "nav_obras_sub",       
       "nav_obras_sub_O1","nav_obras_sub_O2","nav_obras_sub_O3","nav_obras_sub_O4","nav_obras_sub_O5","nav_obras_sub_O6",
       "nav_genero","nav_cronologia","nav_cronologia_sub",
       "nav_cronologia_sub_0","nav_cronologia_sub_1","nav_cronologia_sub_2","nav_cronologia_sub_3",
       "nav_projeto",
       "nav_cronologia_sub_ext",
       "nav_cronologia_sub_ext_00","nav_cronologia_sub_ext_01","nav_cronologia_sub_ext_02","nav_cronologia_sub_ext_03","nav_cronologia_sub_ext_04","nav_cronologia_sub_ext_05","nav_cronologia_sub_ext_06","nav_cronologia_sub_ext_07","nav_cronologia_sub_ext_08","nav_cronologia_sub_ext_09",
       "nav_cronologia_sub_ext_10","nav_cronologia_sub_ext_11","nav_cronologia_sub_ext_12","nav_cronologia_sub_ext_13","nav_cronologia_sub_ext_14","nav_cronologia_sub_ext_15","nav_cronologia_sub_ext_16","nav_cronologia_sub_ext_17","nav_cronologia_sub_ext_18","nav_cronologia_sub_ext_19",
       "nav_cronologia_sub_ext_20","nav_cronologia_sub_ext_21","nav_cronologia_sub_ext_22","nav_cronologia_sub_ext_23","nav_cronologia_sub_ext_24","nav_cronologia_sub_ext_25","nav_cronologia_sub_ext_26","nav_cronologia_sub_ext_27","nav_cronologia_sub_ext_28","nav_cronologia_sub_ext_29",
       "nav_cronologia_sub_ext_30","nav_cronologia_sub_ext_31","nav_cronologia_sub_ext_32","nav_cronologia_sub_ext_33","nav_cronologia_sub_ext_34","nav_cronologia_sub_ext_35");
        
       for (var i = 0; i<IDs.length; i++) {

        if (document.getElementById(navID).style.display == "none" && IDs[i].indexOf(navID) != -1) {
            if (navID.indexOf("nav_documentos_sub_") != -1 || navID.indexOf("nav_cronologia_sub_") != -1 || navID.indexOf("nav_obras_sub_") != -1 || navID.indexOf("nav_publicacoes_sub_") != -1) {
                document.getElementById(navID).style.display = "inline-block";
            }
            else {
                document.getElementById(navID).style.display = "block"; 
             }
             if (navID.indexOf("nav_documentos") != -1) {
                        document.getElementById("nav_documentos").style.display = "block";
                    //   document.getElementById("nav_documentos").style.backgroundColor = "#4E4E4E";
                       
                        if(navID.indexOf("nav_documentos_sub") != -1) {
                            document.getElementById("nav_documentos_sub").style.display = "block";

                        }
                }
                else if (navID.indexOf("nav_cronologia") != -1) {
                    document.getElementById("nav_cronologia").style.display = "block";
                    if(navID.indexOf("nav_cronologia_sub") != -1) {
                        document.getElementById("nav_cronologia_sub").style.display = "block";
                        }                    
                     if(navID.indexOf("nav_cronologia_sub_ext") != -1) {
                     document.getElementById("nav_cronologia_sub_ext").style.display = "inline-block";
                     }
                }
              else if(navID.indexOf("nav_obras") != -1) {
                  document.getElementById("nav_obras").style.display = "block";
                   if(navID.indexOf("nav_obras_sub") != -1) {
                    document.getElementById("nav_obras_sub").style.display = "block"
                    }
              }
              
               else if(navID.indexOf("nav_publicacoes") != -1) {
                  document.getElementById("nav_publicacoes").style.display = "block";
                   if(navID.indexOf("nav_publicacoes_sub") != -1) {
                    document.getElementById("nav_publicacoes_sub").style.display = "block"
                    }
              }
                
                
        }
       
            
            else {
                if(navID.indexOf("nav_cronologia_sub_ext_") != -1 ) {
                 if( IDs[i].length <= 20 && IDs[i].indexOf("nav_cronologia_sub_") != -1 && IDs[i].substr(19,1) == navID.substr(23,1)) {
                      //  alert("ID "+IDs[i].substr(19,1)+" nav "+navID.substr(23,1));
                    document.getElementById(IDs[i]).style.display ="inline-block";
                    /*  if(IDs[i].indexOf("nav_cronologia_sub_ext_") != -1 && IDs[i] != navID && document.getElementById("nav_cronologia_sub_ext").style.display == "inline-block" ) {
                            
                       }
                       else {
                       }
                       */
                 }                    
                 else {
                    document.getElementById(IDs[i]).style.display = "none";
                 }
                }
                else {
                document.getElementById(IDs[i]).style.display = "none";
                }
            }
        }    
       
    };


 