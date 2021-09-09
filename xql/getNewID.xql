xquery version "3.1";

(:  MRI, get new ID from ID-Server
    Dennis Ried, 2021-02-15 :)

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace uuid = "java:java.util.UUID";

declare variable $homeDir as xs:string external;

let $homeDirLabel := substring-after($homeDir, 'Users/')

let $docRootNode := ./root()/node()
let $docID := $docRootNode/@xml:id/string()
let $docType := subsequence(tokenize($docID, '_'), 2, 1)
let $token := uuid:randomUUID()

let $url := concat('https://idgen-intern.max-reger-institut.de/createID?type=', $docType, '&amp;who=', $homeDirLabel, '&amp;token=',$token)
let $newID := unparsed-text($url)
               => normalize-space()

let $idnoTarget := $docRootNode//tei:idno[@type="MRI_Personalia"]

return
    (
     replace value of node $docRootNode/@xml:id with $newID,
     replace value of node $idnoTarget with $newID
    )
    
