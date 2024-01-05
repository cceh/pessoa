xquery version "1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=text media-type=text/turtle";

let $doc := doc('xmldb:exist:///db/apps/pessoa/data/indices.xml')
let $ampersand := '&#38;' (: ampersand :)
let $tab := '&#9;' (: tab :)
let $header := concat(
    "@prefix pdperson: <http://www.pessoadigital.pt/index/names#> .&#xA;",
    "@prefix pdperiodical: <http://www.pessoadigital.pt/index/periodicals#> .&#xA;",
    "@prefix pdpublication: <http://www.pessoadigital.pt/pub/> .&#xA;",
    "@prefix crm: <http://www.cidoc-crm.org/cidoc-crm/> .&#xA;",
    "@prefix dbo: <http://dbpedia.org/ontology/> .&#xA;",
    "@prefix foaf: <http://xmlns.com/foaf/0.1/> .&#xA;",
    "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .&#xA;",
    "@prefix wd: <http://www.wikidata.org/entity/> .&#xA;",
    "@prefix viaf: <http://viaf.org/viaf/> .&#xA;",
    "@prefix gnd: <http://d-nb.info/gnd/> .&#xA;",
    "@prefix owl: <http://www.w3.org/2002/07/owl#> .&#xA;",
    "&#xA;"
)

return (
    $header,
    (for $person in $doc//tei:person
    let $person_id := $person/@xml:id
    let $main_name := $person/tei:persName[@type='main']/data(.)
    let $gender := $person/tei:sex/data(.)
    let $names := $person/tei:persName[not(@type='main')]/data(.)
    let $identifiers := $person/tei:idno
    let $has_identifiers := exists($identifiers)
    let $has_gender := exists($gender)
    let $has_names := exists($names)
    let $last_element := if ($has_names) then 'name' else if ($has_gender) then 'gender' else 'identifier'
    return (
        concat('pdperson:',$person_id, ' a crm:E21_Person ;', '&#xA;'),
        concat($tab,'rdfs:label "', $main_name,'"', if ($has_identifiers or $has_gender or $has_names) then ' ;' else '.', '&#xA;'),
        (for $id at $i in $identifiers
        let $type := $id/@type
        let $is_last := $i = count($identifiers) and not($has_gender) and not($has_names)
        return (
            if ($type = 'viaf') then 
                concat($tab,'owl:sameAs ', 'viaf:',$id/data(), if ($is_last) then '.' else ' ;','&#xA;') 
            else if ($type = 'gnd') then 
                concat($tab,'owl:sameAs ', 'gnd:',$id/data(), if ($is_last) then '.' else ' ;','&#xA;') 
            else if ($type = 'wikidata') then 
                concat($tab,'owl:sameAs ','wd:',$id/data(), if ($is_last) then '.' else ' ;','&#xA;')
            else ()
        )),
        if ($has_gender) then concat($tab, 'foaf:gender "', $gender, '"', if (not($has_names)) then '.' else ' ;','&#xA;') else (),
        if ($has_names) then (
            concat($tab, 'foaf:name ', 
                string-join(
                    for $name in $names return concat('"', $name, '"'), 
                    ", "
                ),
                '.&#xA;'
            )
        ) else (),
        '&#xA;' 
    )),
    (for $periodical in $doc//tei:list[@type='periodical']/tei:item
    let $periodical_id := $periodical/@xml:id/data(.)
    let $periodical_name := $periodical/tei:title/normalize-space(data(.))
    return(
        concat('pdperiodical:',$periodical_id, ' a dbo:Journal ;','&#xA;'),
        concat($tab,'rdfs:label "', $periodical_name,'".','&#xA;'),
        '&#xA;' 
    )),
    (for $publication in $doc//tei:list[@type='publications']/tei:item
    let $publication_id := $publication/@xml:id/data(.)
    let $publication_name := $publication/tei:title/normalize-space(data(.))
    return(
        concat('pdpublication:',$publication_id, ' a dbo:LiteraryWork ;','&#xA;'),
        concat($tab,'rdfs:label "', $publication_name,'".','&#xA;'),
        '&#xA;' 
    ))
)
