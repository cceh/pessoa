declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace saxon = "http://saxon.sf.net/";
declare option saxon:output "method=text";


let $doc := doc('xmldb:exist:///db/apps/pessoa/data/indices.xml')

let $currentDateTime := fn:current-dateTime()
let $formattedDateTime := fn:format-dateTime($currentDateTime, "[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]")
let $ampersand := '&#38;' (: ampersand :)

let $header := 
  "#FORMAT: BEACON&#xA;" ||
  "#NAME: Digital Edition of Fernando Pessoa&#xA;" ||
  "#TARGET: http://www.pessoadigital.pt/de/index/names/#&#xA;" ||
  "#FEED: http://www.pessoadigital.pt/de/index/names/lod/PD_BEACON.txt&#xA;" ||
  "#CONTACT: Ulrike Henny-Krahmer  &lt;ulrike.henny-krahmer@uni-rostock.de&gt; &#xA;" ||
  "#MESSAGE: Mentions in the digital edition of Fernando Pessoa&#xA;" ||
  "#RELATION: http://www.w3.org/2002/07/owl#sameAs&#xA;" ||
  "#TIMESTAMP: " || $formattedDateTime || "&#xA;" ||
  "&#xA;"

for $person in $doc//tei:person
let $xml_id := $person/@xml:id
return (
  $header,
  
  for $person in $doc//tei:person
  let $xml_id := $person/@xml:id
  return (
      for $viaf_id in $person/tei:idno[@type='viaf']
      return if ($viaf_id) then concat('http://viaf.org/viaf/',$viaf_id, '||', $xml_id, '&#xA;') else (),
      for $gnd_id in $person/tei:idno[@type='gnd']
      return if ($gnd_id) then concat('http://d-nb.info/gnd/',$gnd_id, '||', $xml_id, '&#xA;') else (),
      for $wikidata_id in $person/tei:idno[@type='wikidata']
      return if ($wikidata_id) then concat('https://www.wikidata.org/wiki/',$wikidata_id, '||', $xml_id, '&#xA;') else ()
    )
)

