(:~
 : With this script, all the titles of publications and titles mentioned in
 : documents and publications are collected and saved as an alphabetical list,
 : which is used as a basis for the title index.
 :)
xquery version "3.0";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare function local:get-titles(){
    (: get all the titles :)
    let $titles-doc-rs := collection('/db/apps/pessoa/data/doc')//tei:rs[@type="title"]
    let $titles-pub-rs := collection('/db/apps/pessoa/data/pub')//tei:rs[@type="title"]
    let $titles-pub := collection('/db/apps/pessoa/data/pub')//tei:title[@level="a"]
    (: create an XML file with a list of all the titles :)
    let $title-xsl := doc("/db/apps/pessoa/xslt/title.xsl")
    let $title-xml := <list>
        {for $t in $titles-doc-rs
        let $clean-t := transform:transform($t, $title-xsl, ())
        return <entry>
            <type>doc</type>
            <title>{$clean-t/normalize-space(.)}</title>
            <parentName>{$t/ancestor::tei:TEI//tei:titleStmt/tei:title/normalize-space(.)}</parentName>
            <parentLink>{$t/ancestor::tei:TEI//tei:idno[@type="filename"]/data(.)}</parentLink>
        </entry>}
        {for $t in $titles-pub-rs
        let $clean-t := transform:transform($t, $title-xsl, ())
        return <entry>
            <type>pub</type>
            <title>{$clean-t/normalize-space(.)}</title>
            <parentName>{$t/ancestor::tei:TEI//tei:titleStmt/tei:title/normalize-space(.)}</parentName>
            <parentLink>{$t/ancestor::tei:TEI//tei:idno[@type="filename"]/data(.)}</parentLink>
        </entry>}
        {for $t in $titles-pub
        let $clean-t := transform:transform($t, $title-xsl, ())
        return <entry>
            <type>pub</type>
            <title>{$clean-t/normalize-space(.)}</title>
            <parentName>{$t/ancestor::tei:TEI//tei:titleStmt/tei:title/normalize-space(.)}</parentName>
            <parentLink>{$t/ancestor::tei:TEI//tei:idno[@type="filename"]/data(.)}</parentLink>
        </entry>}
    </list>
    return xmldb:store("/db/apps/pessoa/data","titles-raw.xml",$title-xml)
};

declare function local:clean-titles(){
    (: group the titles and sort alphabetically :)
    let $titles-raw := doc("/db/apps/pessoa/data/titles-raw.xml")//entry
    let $title-xml := <list>
        {for $entry in $titles-raw
        let $title := $entry/title/data(.)
        group by $title
        return <entry>
            <letter>{translate(substring(replace(upper-case($title),'^[“”"(\.\s«‘]+',''),1,1),'ÁÀÓ','AAO')}</letter>
            <title>{$title}</title>
            <links>
                {for $e in $entry
                let $pl := $e/parentLink
                group by $pl
                order by $e[1]/parentName
                return
                    <link>
                        <type>{$e[1]/type/data(.)}</type>
                        <parentName>{$e[1]/parentName/data(.)}</parentName>
                        <parentLink>{$e[1]/parentLink/data(.)}</parentLink>
                    </link>}
            </links>
        </entry>}
    </list>
    return xmldb:store("/db/apps/pessoa/data","titles-raw-sorted.xml",$title-xml)
};

(
local:get-titles(),
local:clean-titles()
)