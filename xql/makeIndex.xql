xquery version "3.1";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "indent=yes";

declare function local:getNameOfPerson($person as node()?, $param as xs:string){

    let $nameForename := $person//tei:forename[matches(@type,"used")]
                          => string-join(' ')
    let $nameNameLink := $person//tei:nameLink[1]/text()[1]
    let $nameSurname := $person//tei:surname[matches(@type,"^used")]
                         => string-join(' ')
    let $nameSurnameBirth := $person//tei:surname[matches(@type,"^birth")]
                         => string-join(' ')
    let $nameSurnameMarried := $person//tei:surname[matches(@type,"^married")]
                         => string-join(' ')
    let $nameGenName := $person//tei:genName/text()
    let $nameAddNameTitle := $person//tei:addName[matches(@type,"title")][1]/text()[1]
    let $nameAddNameEpitet := $person//tei:addName[matches(@type,"^epithet")][1]/text()[1]
    let $pseudonym := ($person//tei:forename[matches(@type,'^pseudonym')], $person//tei:surname[matches(@type,'^pseudonym')])
                        => string-join(' ')
    let $nameRoleName := $person//tei:roleName[1]/text()[1]
    let $nameAddNameNick := $person//tei:addName[matches(@type,"^nick")]
                             => string-join(' ')
    let $affiliation := $person//tei:affiliation[1]/text()
    let $nameUnspecified := $person//tei:name[matches(@type,'^unspecified')][1]/text()[1]
    let $nameUnspec := if($affiliation and $nameUnspecified)
                       then(concat($nameUnspecified, ' (',$affiliation,')'))
                       else($nameUnspecified)

    let $name := if ($person)
                 then(
                      if($param = 'full')
                      then(
                            if($nameAddNameTitle or $nameForename or $nameAddNameEpitet or $nameNameLink or $nameSurname or $nameGenName or $nameUnspec)
                            then(string-join(($nameAddNameTitle, $nameForename, $nameAddNameEpitet, $nameNameLink, $nameSurname, $nameUnspec, if($nameGenName) then(concat(' (',$nameGenName,')')) else()), ' '))
                            else if($pseudonym)
                            then($pseudonym)
                            else if($nameRoleName)
                            then($nameRoleName)
                            else if($nameAddNameNick)
                            then($nameAddNameNick)
                            else('N.N.')
                          )
                          
                      else if($param = 'short')
                      then(
                           string-join(($nameForename, $nameNameLink, $nameSurname, if($nameGenName) then(concat(' (',$nameGenName,')')) else()), ' ')
                          )
                          
                      else if($param = 'reversed')
                      then(
                            if($nameSurname)
                            then(
                                concat(
                                       $nameSurname,
                                       if($nameGenName) then(concat(' (',$nameGenName,')')) else(),
                                       if($nameAddNameTitle or $nameForename or $nameNameLink)
                                       then(concat(', ', string-join(($nameAddNameTitle, $nameForename, $nameNameLink), ' ')))
                                       else()
                                       )
                                )
                            else if($nameForename)
                            then(
                                   string-join(($nameForename, $nameNameLink, $nameUnspec), ' '),
                                   if($nameGenName) then(concat(' (',$nameGenName,')')) else()
                                )
                            else if($nameRoleName)
                            then($nameRoleName)
                            else if($pseudonym)
                            then($pseudonym)
                            else if($nameAddNameNick)
                            then($nameAddNameNick)
                            else('[N.N.]')
                                 )
                      else if($param = 'birth-rev')
                      then(
                            if($nameSurnameBirth)
                            then(
                                concat(
                                       $nameSurnameBirth,
                                       if($nameGenName) then(concat(' (',$nameGenName,')')) else(),
                                       if($nameAddNameTitle or $nameForename or $nameNameLink)
                                       then(concat(', ', string-join(($nameAddNameTitle, $nameForename, $nameNameLink), ' ')))
                                       else()
                                       )
                                )
                            else (
                                    if(not($nameForename) and not($nameNameLink) and not($nameUnspec))
                                    then($nameRoleName)
                                    else(
                                           string-join(($nameForename, $nameNameLink, $nameUnspec), ' '),
                                           if($nameGenName) then(concat(' (',$nameGenName,')')) else()
                                        )
                                 )
                           )
                      else if($param = 'married-rev')
                      then(
                            if($nameSurnameMarried)
                            then(
                                concat(
                                       $nameSurnameMarried,
                                       if($nameGenName) then(concat(' (',$nameGenName,')')) else(),
                                       if($nameAddNameTitle or $nameForename or $nameNameLink)
                                       then(concat(', ', string-join(($nameAddNameTitle, $nameForename, $nameNameLink), ' ')))
                                       else()
                                       )
                                )
                            else (
                                    if(not($nameForename) and not($nameNameLink) and not($nameUnspec))
                                    then($nameRoleName)
                                    else(
                                           string-join(($nameForename, $nameNameLink, $nameUnspec), ' '),
                                           if($nameGenName) then(concat(' (',$nameGenName,')')) else()
                                        )
                                 )
                           )
                      else ('[No person found]')
                     )
                 else('[Not found]')
    return
       $name
};

let $collPersons := collection('../../jraPersons/data/?select=C*.xml;recurse=yes')
let $collInstitutions := collection('../../jraInstitutions/data?select=D*.xml;recurse=yes')
let $collWorks := collection('../../jraWorks/data?select=B*.xml;recurse=yes')
let $collEvents := collection('../../jraEvents/data?select=F*.xml;recurse=yes')
let $collSources := collection('../../jraSources/data?select=A*.xml;recurse=yes')
let $collWritings := collection('../../jraWritings/data?select=E*.xml;recurse=yes')
let $collBibl := collection('../../jraBibl/data?select=G*.xml;recurse=yes')

let $entriesPersons := for $doc in $collPersons
                              let $docUri := document-uri($doc)
                              let $entryID := $doc/tei:TEI/@xml:id/string()
                              let $person := $doc//tei:person
                              let $entryName := local:getNameOfPerson($person, 'reversed')
                              let $entryNamePlain := normalize-space(replace($entryName, ',', '\${comma}'))
                              
                              order by $entryNamePlain
                              return
                                <entry xmlns="http://www.tei-c.org/ns/1.0" key="{$entryID}" name="{$entryNamePlain}" file="{$docUri}"/>

let $entriesInstitutions := for $doc in $collInstitutions
                              let $docUri := document-uri($doc)
                              let $entryID := $doc/tei:TEI/@xml:id/string()
                              let $org := $doc//tei:org
                              let $entryName := $org//tei:orgName[1]//text() => string-join(' ')
                              let $entryNamePlain := normalize-space(replace($entryName, ',', '\${comma}'))
                              
                              order by $entryNamePlain
                              return
                                <entry xmlns="http://www.tei-c.org/ns/1.0" key="{$entryID}" name="{$entryNamePlain}" file="{$docUri}"/>

let $entriesWorks := for $doc in $collWorks
                              let $docUri := document-uri($doc)
                              let $entryID := $doc/mei:mei/@xml:id/string()
                              let $work := $doc/mei:work
                              let $entryName := $work/mei:title[@type="uniform"]//text() => string-join(' ')
                              let $entryNamePlain := normalize-space(replace($entryName, ',', '\${comma}'))
                              
                              order by $entryNamePlain
                              return
                                <entry xmlns="http://www.tei-c.org/ns/1.0" key="{$entryID}" name="{$entryNamePlain}" file="{$docUri}"/>


let $entriesBibl := for $doc in $collBibl
                              let $docUri := document-uri($doc)
                              let $monogr := $doc//tei:monogr[not(@corresp)]
                              let $monogrFileID := $monogr/root()/node()/@xml:id/string()
                              let $series := $doc//tei:series[not(@corresp)]
                              let $seriesFileID := $series/root()/node()/@xml:id/string()
                              let $biblMonogrLabel := concat($monogr/tei:title/text(), ' (', string-join($monogr//tei:persName/text(), '|'),')', $monogr/tei:imprint/tei:pubPlace/text(), ' ', $monogr/tei:imprint/tei:date/text())
                              let $biblSeriesLabel := concat($series/tei:title/text(), ' Bd. ', $series/tei:biblScope/text()) 
                             
                              let $entryID := if($monogr) then($monogrFileID) 
                                              else if ($series) then($seriesFileID)
                                              else("Error")
                              let $entryType := if ($series) then('series') 
                                                else if($monogr) then('monogr')
                                                else("Error")
                              let $entryName := if($series) then($biblSeriesLabel)
                                                else if($monogr) then ($biblMonogrLabel)
                                                else('Error')
                              let $entryNamePlain := normalize-space(replace($entryName, ',', '*'))
                             
                              order by $entryNamePlain
                              return
                                  <entry xmlns="http://www.tei-c.org/ns/1.0" key="{$entryID}" type="{$entryType}" name="{$entryNamePlain}" file="{$docUri}"/>

return
    (
        put(<index xmlns="http://www.tei-c.org/ns/1.0">{$entriesPersons}</index>,'../temp/jraPersonsIndex.xml'),
        put(<index xmlns="http://www.tei-c.org/ns/1.0">{$entriesInstitutions}</index>,'../temp/jraInstitutionsIndex.xml'),
        put(<index xmlns="http://www.tei-c.org/ns/1.0">{$entriesBibl}</index>,'../temp/jraBiblIndex.xml')
    )
