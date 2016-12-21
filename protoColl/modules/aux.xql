xquery version "3.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $src := '/db/apps/cbdb-data/src/xml/';

declare variable $ADDRESSES:= doc(concat($src, 'ADDRESSES.xml')); 
declare variable $ADDR_BELONGS_DATA:= doc(concat($src, 'ADDR_BELONGS_DATA.xml')); 
declare variable $ADDR_CODES:= doc(concat($src, 'ADDR_CODES.xml')); 

let $types := 
    distinct-values(($ADDR_CODES//c_admin_type, $ADDRESSES//c_admin_type, $ADDR_CODES//c_admin_type)) 

let $lower := 
    for $n in $types
    return 
        lower-case($n)
        
        
let $norm := 
    for $n in distinct-values($lower)
    order by $n
    return 
        switch($n)
            case 'duhu fu' return 'duhufu'
            case 'manyichangguansi' return 'manyi changguansi'
            case 'xianm' return 'xian' 
            case 'zhou(jun)' return 'zhou (jun)'
        default return $n
        
for $n in distinct-values($norm)
order by $n
return $n



(:DUPES
Anfusi
anfusi

Daoxuanweisi
daoxuanweisi

Difang
difang

Dudufu
dudufu
Duhu fu
Duhufu
duhufu

independent state
independent state

manyi changguansi
manyichangguansi

zhou (jun)
zhou(jun):)





    
    
   
                
        
