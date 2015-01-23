xquery version "3.0";

module namespace page="http://localhost:8080/exist/apps/pessoa/page";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";

declare %templates:wrap function page:construct($node as node(), $model as map(*)) as node() {
    let $lists :=<ul id="navi" class="nav nav-tabs" role="tablist">
                <li>
                    <a href="#author" role="tab" data-toggle="tab">Autor</a>
                </li>
                <li>
                    <a href="#document" role="tab" data-toggle="tab">Documentos</a>
                </li>
                <li>
                    <a href="#publicationen" role="tab" data-toggle="tab">Publicações</a>
                </li>
                <li>
                    <a href="#genre" role="tab" data-toggle="tab">Género</a>
                </li>
                <li>
                    <a href="#chronologie" role="tab" data-toggle="tab">Cronologia</a>
                </li>
                <li>
                    <a href="#bibliografie" role="tab" data-toggle="tab">Bibliografia</a>
                </li>
                <li>
                    <a href="#project" role="tab" data-toggle="tab">Projeto</a>
                </li>
                <li>                    
                  <div class="box">
                        <div class="container-4">
                            <input type="search" id="search" placeholder="Search..." />
                            <button class="icon" id="button" onclick="search()"><i class="fa fa-search" ></i>
                                </button>
                        </div>
                    </div>                  
                </li>
            </ul>
    return $lists
};
