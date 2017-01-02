xquery version "3.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.tei-c.org/ns/1.0";


declare variable $src := '/db/apps/cbdb-data/src/xml/';
declare variable $target := '/db/apps/cbdb-data/target/';

declare variable $OFFICE_CATEGORIES:= doc(concat($src, 'OFFICE_CATEGORIES.xml')); 
declare variable $OFFICE_CODES:= doc(concat($src, 'OFFICE_CODES.xml')); 
declare variable $OFFICE_CODES_CONVERSION:= doc(concat($src, 'OFFICE_CODES_CONVERSION.xml')); 
declare variable $OFFICE_CODE_TYPE_REL:= doc(concat($src, 'OFFICE_CODE_TYPE_REL.xml')); 
declare variable $OFFICE_TYPE_TREE:= doc(concat($src, 'OFFICE_TYPE_TREE.xml')); 

declare variable $POSTED_TO_OFFICE_DATA:= doc(concat($src, 'POSTED_TO_OFFICE_DATA.xml')); 


declare variable $GANZHI_CODES:= doc(concat($src, 'GANZHI_CODES.xml')); 
declare variable $NIAN_HAO:= doc(concat($src, 'NIAN_HAO.xml')); 
declare variable $DYNASTIES:= doc(concat($src, 'DYNASTIES.xml')); 

declare function local:isodate ($string as xs:string?)  as xs:string* {

(:This function returns proper xs:gYear type values, "0000", 4 digits, with leading "-" for BCE dates
   <a>-1234</a>    ----------> <gYear>-1234</gYear>
   <b/>    ------------------> <gYear/>
   <c>1911</c> --------------> <gYear>1911</gYear>
   <d>786</d>  --------------> <gYear>0786</gYear>
   
   according to <ref target="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.datable.w3c.html"/>
   "0000" should be "-0001" in TEI.
   
:)
        
    if (empty($string)) then ()
    else if (number($string) eq 0) then ('-0001')
    else if (starts-with($string, "-")) then (concat('-',(concat (string-join((for $i in (string-length(substring($string,2)) to 3) return '0'),'') , substring($string,2)))))
    else (concat (string-join((for $i in (string-length($string) to 3) return '0'),'') , $string))
};

declare function local:sqldate ($timestamp as xs:string?)  as xs:string* {
concat(substring($timestamp, 1, 4), '-', substring($timestamp, 5, 2), '-', substring($timestamp, 7, 2)) 
};


declare function local:office ($offices as node()*) as node()* {

(:This function transforms OFFICE_CODE data into a *nested* tei:taxonomy via  c_office_id. :)

(:Wow this is a mess. TODO
- OFFICE_CATEGORIES is linked with POSTED_TO_OFFICE_DATA so either it becomes tei:event/@type, 
or if gets its own taxonomy.
- $OFFICE_CODES//c_category_1, _2, _3, _4 no clue what these are supposed to be, not office type, or office category
- $OFFICE_CODE_TYPE_REl//c_office_type_type_code ... WTF?
- get $OFFICE_CODES to nest according to $OFFICE_TYPE_TREE
- Q: WTF are $OFFICE_CODE_TYPE_REL//c_office_l1, _l2, _l3, _l4, _l5 
    A: the same as */../c_office_tree_id could be usefull for the nesting
:)

(:
[tts_sysno] INTEGER,                        d
 [c_office_id] INTEGER PRIMARY KEY,       x
 [c_dy] INTEGER,                             x
 [c_office_pinyin] CHAR(255),              x
 [c_office_chn] CHAR(255),                  x
 [c_office_pinyin_alt] CHAR(255),           x
 [c_office_chn_alt] CHAR(255),              x
 [c_office_trans] CHAR(255),                x
 [c_office_trans_alt] CHAR(255),            x
 [c_source] INTEGER,                         x
 [c_pages] CHAR(255),                        d
 [c_notes] CHAR,                              x
 [c_category_1] CHAR(50),                   !
 [c_category_2] CHAR(50),                   !
 [c_category_3] CHAR(50),                   !
 [c_category_4] CHAR(50),                   !
 [c_office_id_old] INTEGER)                 d
:)

for $office in $offices[. > 0] 

let $type-rel := $OFFICE_CODE_TYPE_REL//c_office_id[. = $office]
let $type := $OFFICE_TYPE_TREE//c_office_type_node_id[. = $type-rel/../c_office_tree_id]
(:let $cat := $OFFICE_CATEGORIES//c_office_category_id[. = ?]:)


return
    element category{ attribute xml:id {concat('OFF', $office/text())},
    if (empty($office/../c_source) or $office/../c_source[. < 1])
    then ()
    else (attribute source {concat('#BIB', $office/../c_source/text())}),
        element catDesc {
            element date{ attribute sameAs {concat('#D', $office/../c_dy/text())}},
            element roleName { attribute type {'main'},
                element roleName { attribute xml:lang {'zh-Hant'},
                    $office/../c_office_chn/text()},
                element roleName { attribute xml:lang {'zh-alalc97'},
                    $office/../c_office_pinyin/text()},
                if (empty($office/../c_office_trans) or $office/../c_office_trans/text() = '[Not Yet Translated]')
                then ()
                else if (contains($office/../c_office_trans/text(), '(Hucker)'))
                    then (element roleName {attribute xml:lang {'en'},
                                attribute resp {'Hucker'},
                            substring-before($office/../c_office_trans/text(), ' (Hucker)')})
                    else (element roleName { attribute xml:lang {'en'}, 
                $office/../c_office_trans/text()}), 
            if ($office/../c_notes)
            then (element note {$office/../c_notes/text()})
            else ()
            },
            if (empty($office/../c_office_chn_alt) and empty($office/../c_office_trans_alt))
            then ()
            else (element roleName { attribute type {'alt'},
                    if ($office/../c_office_chn_alt)
                    then (element roleName { attribute xml:lang {'zh-Hant'},
                            $office/../c_office_chn_alt/text()},
                        element roleName { attribute xml:lang {'zh-alalc97'},
                            $office/../c_office_pinyin_alt/text()})
                    else(),
                    if ($office/../c_office_trans_alt)
                    then (element roleName { attribute xml:lang {'en'}, 
                        $office/../c_office_trans_alt/text()})
                    else ()}
                  )
        }
    }
};

(:for $n in $OFFICE_CODES//c_office_chn_alt
where empty($n/../c_office_trans_alt)
return
$n/../c_office_id:)
(:
for $n in $OFFICE_CODES//c_office_id
return
    local:office($n[. = 679]):)

xmldb:store($target, 'office.xml', 
    <taxonomy xml:id="office">                
        {local:office( $OFFICE_CODES//c_office_id)}        
    </taxonomy>
)
