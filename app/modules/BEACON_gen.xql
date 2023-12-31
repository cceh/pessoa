xquery version "1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=text media-type=text/plain";


let $doc := doc('xmldb:exist:///db/apps/pessoa/data/indices.xml')

let $currentDateTime := fn:current-dateTime()
let $formattedDateTime := fn:format-dateTime($currentDateTime, "[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]")
let $ampersand := '&#38;' (: ampersand :)

let $header := 
  concat(
      "#FORMAT: BEACON&#xA;",
      "#NAME: Digital Edition of Fernando Pessoa&#xA;",
      "#TARGET: http://www.pessoadigital.pt/de/index/&#xA;",
      "#FEED: http://www.pessoadigital.pt/de/index/names/lod/PD_BEACON.txt&#xA;",
      "#CONTACT: Ulrike Henny-Krahmer  &lt;ulrike.henny-krahmer@uni-rostock.de&gt; &#xA;",
      "#MESSAGE: Mentions in the digital edition of Fernando Pessoa&#xA;",
      "#RELATION: http://www.w3.org/2002/07/owl#sameAs&#xA;",
      "#TIMESTAMP: " , $formattedDateTime, "&#xA;",
      "&#xA;"
  )

let $message := 'periodicals here'


return (
  $header,
  (
    for $person in $doc//tei:person
    let $person_id := $person/@xml:id
    return (
        for $viaf_id in $person/tei:idno[@type='viaf']
        return if ($viaf_id) then concat('http://viaf.org/viaf/',$viaf_id, '||', 'names#',$person_id, '&#xA;') else (),
        for $gnd_id in $person/tei:idno[@type='gnd']
        return if ($gnd_id) then concat('http://d-nb.info/gnd/',$gnd_id, '||', 'names#',$person_id, '&#xA;') else (),
        for $wikidata_id in $person/tei:idno[@type='wikidata']
        return if ($wikidata_id) then concat('https://www.wikidata.org/wiki/',$wikidata_id, '||', 'names#',$person_id, '&#xA;') else ()
      )
  ),
  (
    for $periodical in $doc//tei:list[@type='periodical']/tei:item
    let $periodical_id := $periodical/@xml:id/data(.)
    return (
        for $viaf_id in $periodical/tei:idno[@type='viaf']
        return if ($viaf_id) then concat('http://viaf.org/viaf/',$viaf_id, '||', 'periodicals#',$periodical_id, '&#xA;') else (),
        for $gnd_id in $periodical/tei:idno[@type='gnd']
        return if ($gnd_id) then concat('http://d-nb.info/gnd/',$gnd_id, '||', 'periodicals#',$periodical_id, '&#xA;') else (),
        for $wikidata_id in $periodical/tei:idno[@type='wikidata']
        return if ($wikidata_id) then concat('https://www.wikidata.org/wiki/',$wikidata_id, '||', 'periodicals#',$periodical_id, '&#xA;') else ()
      )
   ),
     (
    for $publication in $doc//tei:list[@type='publications']/tei:item
    let $publication_id := $publication/@xml:id/data(.)
    return (
        for $viaf_id in $publication/tei:idno[@type='viaf']
        return if ($viaf_id) then concat('http://viaf.org/viaf/',$viaf_id, '||', 'publications#',$publication_id, '&#xA;') else (),
        for $gnd_id in $publication/tei:idno[@type='gnd']
        return if ($gnd_id) then concat('http://d-nb.info/gnd/',$gnd_id, '||', 'publications#',$publication_id, '&#xA;') else (),
        for $wikidata_id in $publication/tei:idno[@type='wikidata']
        return if ($wikidata_id) then concat('https://www.wikidata.org/wiki/',$wikidata_id, '||', 'publications#',$publication_id, '&#xA;') else ()
      )
   )
)

