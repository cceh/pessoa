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
    "@prefix gnd: <http://d-nb.info/gnd/>;",
    "&#xA;"
)

return (
    $header,
    (for $person in $doc//tei:person
    let $person_id := $person/@xml:id
    let $main_name := $person/tei:persName[@type='main']/data(.)
    let $gender := $person/tei:sex/data(.)
    let $labels := $person/tei:persName[not(@type='main')]/data(.)
    return (
    concat('pdperson:',$person_id, ' a crm:E21_Person ;', '&#xA;'),
    concat($tab,'rdfs:label "', $main_name,'" ;','&#xA;'),    
    for $viaf_id in $person/tei:idno[@type='viaf']
    return if ($viaf_id) then concat($tab,'= ', 'viaf:',$viaf_id, ' ;','&#xA;') else (),
    for $gnd_id in $person/tei:idno[@type='gnd']
    return if ($gnd_id) then concat($tab,'= ', 'gnd:',$gnd_id,' ;','&#xA;') else (),
    for $wikidata_id in $person/tei:idno[@type='wikidata']
    return if ($wikidata_id) then concat($tab,'= ','wd:',$wikidata_id, ' ;','&#xA;') else (),
    concat($tab, 'foaf:gender "', $gender, '" ;','&#xA;'),
    if (exists($labels)) then concat($tab, 'foaf:name ') else (),
    (
      for $label at $i in $labels
      return if ($label) then 
        if ($i = count($labels)) 
        then concat('"',$label,'";&#xA;') 
        else concat('"',$label,'", ')
      else ()
    ),
    '&#xA;')
    ),
   (for $periodical in $doc//tei:list[@type='periodical']/tei:item
    let $periodical_id := $periodical/@xml:id/data(.)
    let $periodical_name := $periodical/tei:title/normalize-space(data(.))
    return(
    concat('pdperiodical:',$periodical_id, ' a dbo:Journal ;','&#xA;'),
    concat($tab,'rdfs:label "', $periodical_name,'" ;','&#xA;'), 
    for $viaf_id in $periodical/tei:idno[@type='viaf']
    return if ($viaf_id) then concat($tab,'= ', 'viaf:',$viaf_id, ' ;','&#xA;') else (),
    for $gnd_id in $periodical/tei:idno[@type='gnd']
    return if ($gnd_id) then concat($tab,'= ','gnd:',$gnd_id, ' ;','&#xA;') else (),
    for $wikidata_id in $periodical/tei:idno[@type='wikidata']
    return if ($wikidata_id) then concat($tab,'= ','wd:',$wikidata_id, ' ;','&#xA;') else (),
    '&#xA;')),
    (for $publication in $doc//tei:list[@type='publications']/tei:item
    let $publication_id := $publication/@xml:id/data(.)
    let $publication_name := $publication/tei:title/normalize-space(data(.))
    return(
    concat('pdpublication:',$publication_id, ' a dbo:LiteraryWork ;','&#xA;'),
    concat($tab,'rdfs:label "', $publication_name,'" ;','&#xA;'), 
    for $viaf_id in $publication/tei:idno[@type='viaf']
    return if ($viaf_id) then concat($tab,'= ', 'viaf:',$viaf_id, ' ;','&#xA;') else (),
    for $gnd_id in $publication/tei:idno[@type='gnd']
    return if ($gnd_id) then concat($tab,'= ', 'gnd:',$gnd_id, ' ;','&#xA;') else (),
    for $wikidata_id in $publication/tei:idno[@type='wikidata']
    return if ($wikidata_id) then concat($tab,'= ','wd:',$wikidata_id, ' ;','&#xA;') else (),
    '&#xA;'))
)

