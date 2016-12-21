xquery version "3.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.tei-c.org/ns/1.0";


declare variable $src := '/db/apps/cbdb-data/src/xml/';
declare variable $target := '/db/apps/cbdb-data/target/';

declare variable $BIOG_MAIN:= doc(concat($src, 'BIOG_MAIN.xml')); 
declare variable $ALTNAME_CODES:= doc(concat($src, 'ALTNAME_CODES.xml')); 
declare variable $ALTNAME_DATA:= doc(concat($src, 'ALTNAME_DATA.xml'));
declare variable $ASSOC_CODES:= doc(concat($src, 'ASSOC_CODES.xml')); 
declare variable $ASSOC_CODE_TYPE_REL:= doc(concat($src, 'ASSOC_CODE_TYPE_REL.xml')); 
declare variable $ASSOC_DATA:= doc(concat($src, 'ASSOC_DATA.xml')); 
declare variable $ASSOC_TYPES:= doc(concat($src, 'ASSOC_TYPES.xml')); 

declare variable $ASSUME_OFFICE_CODES:= doc(concat($src, 'ASSUME_OFFICE_CODES.xml')); 
declare variable $APPOINTMENT_TYPE_CODES:= doc(concat($src, 'APPOINTMENT_TYPE_CODES.xml')); 

declare variable $ADDR_CODES:= doc(concat($src, 'ADDR_CODES.xml')); 
declare variable $BIOG_ADDR_CODES:= doc(concat($src, 'BIOG_ADDR_CODES.xml')); 
declare variable $BIOG_ADDR_DATA:= doc(concat($src, 'BIOG_ADDR_DATA.xml')); 
declare variable $BIOG_INST_CODES:= doc(concat($src, 'BIOG_INST_CODES.xml')); 
declare variable $BIOG_INST_DATA:= doc(concat($src, 'BIOG_INST_DATA.xml')); 

declare variable $CHORONYM_CODES:= doc(concat($src, 'CHORONYM_CODES.xml'));

declare variable $EVENTS_ADDR:= doc(concat($src, 'EVENTS_ADDR.xml')); 
declare variable $EVENTS_DATA:= doc(concat($src, 'EVENTS_DATA.xml')); 
declare variable $EVENT_CODES:= doc(concat($src, 'EVENT_CODES.xml')); 

declare variable $ETHNICITY_TRIBE_CODES:= doc(concat($src, 'ETHNICITY_TRIBE_CODES.xml')); 

declare variable $HOUSEHOLD_STATUS_CODES:= doc(concat($src, 'HOUSEHOLD_STATUS_CODES.xml')); 

declare variable $KINSHIP_CODES:= doc(concat($src, 'KINSHIP_CODES.xml')); 
declare variable $KIN_DATA:= doc(concat($src, 'KIN_DATA.xml')); 
declare variable $KIN_MOURNING_STEPS:= doc(concat($src, 'KIN_MOURNING_STEPS.xml')); 
declare variable $KIN_Mourning:= doc(concat($src, 'KIN_Mourning.xml'));

declare variable $OFFICE_CATEGORIES:= doc(concat($src, 'OFFICE_CATEGORIES.xml')); 
declare variable $OFFICE_CODES:= doc(concat($src, 'OFFICE_CODES.xml')); 
declare variable $OFFICE_CODES_CONVERSION:= doc(concat($src, 'OFFICE_CODES_CONVERSION.xml')); 
declare variable $OFFICE_CODE_TYPE_REL:= doc(concat($src, 'OFFICE_CODE_TYPE_REL.xml')); 
declare variable $OFFICE_TYPE_TREE:= doc(concat($src, 'OFFICE_TYPE_TREE.xml'));

declare variable $POSSESSION_ACT_CODES:= doc(concat($src, 'POSSESSION_ACT_CODES.xml')); 
declare variable $POSSESSION_ADDR:= doc(concat($src, 'POSSESSION_ADDR.xml')); 
declare variable $POSSESSION_DATA:= doc(concat($src, 'POSSESSION_DATA.xml')); 
declare variable $POSTED_TO_ADDR_DATA:= doc(concat($src, 'POSTED_TO_ADDR_DATA.xml')); 
declare variable $POSTED_TO_OFFICE_DATA:= doc(concat($src, 'POSTED_TO_OFFICE_DATA.xml')); 
declare variable $POSTING_DATA:= doc(concat($src, 'POSTING_DATA.xml')); 

declare variable $STATUS_CODES:= doc(concat($src, 'STATUS_CODES.xml')); 
declare variable $STATUS_CODE_TYPE_REL:= doc(concat($src, 'STATUS_CODE_TYPE_REL.xml')); 
declare variable $STATUS_DATA:= doc(concat($src, 'STATUS_DATA.xml')); 
declare variable $STATUS_TYPES:= doc(concat($src, 'STATUS_TYPES.xml')); 

declare variable $SOCIAL_INSTITUTION_ADDR:= doc(concat($src, 'SOCIAL_INSTITUTION_ADDR.xml')); 
declare variable $SOCIAL_INSTITUTION_ADDR_TYPES:= doc(concat($src, 'SOCIAL_INSTITUTION_ADDR_TYPES.xml')); 
declare variable $SOCIAL_INSTITUTION_ALTNAME_CODES:= doc(concat($src, 'SOCIAL_INSTITUTION_ALTNAME_CODES.xml')); 
declare variable $SOCIAL_INSTITUTION_ALTNAME_DATA:= doc(concat($src, 'SOCIAL_INSTITUTION_ALTNAME_DATA.xml')); 
declare variable $SOCIAL_INSTITUTION_CODES:= doc(concat($src, 'SOCIAL_INSTITUTION_CODES.xml')); 
declare variable $SOCIAL_INSTITUTION_CODES_CONVERSION:= doc(concat($src, 'SOCIAL_INSTITUTION_CODES_CONVERSION.xml')); 
declare variable $SOCIAL_INSTITUTION_NAME_CODES:= doc(concat($src, 'SOCIAL_INSTITUTION_NAME_CODES.xml')); 
declare variable $SOCIAL_INSTITUTION_TYPES:= doc(concat($src, 'SOCIAL_INSTITUTION_TYPES.xml')); 

(:This is the main Transformation of Biographical data from CBDB.
There local:biog transforms persons from the BIOG_MAIN table.
:)

(:TODO:
- find out how to properly unenocde '&amp;#22;' in _proper and _rm names
- split the biogmain transformation into two files one for biog main and aliases on fore event n stuff?
- find an external ontology to for kinship ties, or make the cbdb syntax xml-attributable

:)

declare function local:isodate ($string as xs:string?)  as xs:string* {
(:see calendar.xql:)
     
    if (empty($string)) then ()
    else if (number($string) eq 0) then ('-0001')
    else if (starts-with($string, "-")) then (concat('-',(concat (string-join((for $i in (string-length(substring($string,2)) to 3) return '0'),'') , substring($string,2)))))
    else (concat (string-join((for $i in (string-length($string) to 3) return '0'),'') , $string))
};

declare function local:sqldate ($timestamp as xs:string?)  as xs:string* {
concat(substring($timestamp, 1, 4), '-', substring($timestamp, 5, 2), '-', substring($timestamp, 7, 2)) 
};

declare function local:name ($names as node()*, $lang as xs:string?) as node()* {
(:This function checks the different name components and languages to retun persNames.
It expects valid c_name, or c_cname_chn nodes, and 'py' or'hz' as arguments.
:)


let $py :=
    for $name in $names/../c_name
    let $choro := $CHORONYM_CODES//c_choronym_code[. = $name/../c_choronym_code]
    
    return
        if ($name/text() eq concat($name/../c_surname/text(), ' ', $name/../c_mingzi/text()))
        then (<persName xml:lang="zh-alalc97">
                    <surname>{$name/../c_surname/text()}</surname>
                    <forename>{$name/../c_mingzi/text()}</forename>
                    {if (empty($choro) or $choro[. < 1])
                    then ()
                    else (<addName type="choronym">{$choro/../c_choronym_desc/text()}</addName>)
                    }
                </persName>)
        else (<persName xml:lang="zh-alalc97">
                {$name/text()}
                {if (empty($choro) or $choro[. < 1])
                    then ()
                    else (<addName type="choronym">{$choro/../c_choronym_desc/text()}</addName>)
                    }
                </persName>)

let $hz := 
    for $name in $names/../c_name_chn
    let $choro := $CHORONYM_CODES//c_choronym_code[. = $name/../c_choronym_code]
    
    return
        if ($name/text() eq concat($name/../c_surname_chn/text(), $name/../c_mingzi_chn/text()))
        then (<persName xml:lang="zh-Hant">
                    <surname>{$name/../c_surname_chn/text()}</surname>
                    <forename>{$name/../c_mingzi_chn/text()}</forename>
                    {if (empty($choro) or $choro[. < 1])
                    then ()
                    else (<addName type="choronym">{$choro/../c_choronym_chn/text()}</addName>)
                    }
                </persName>
                )
        else (<persName xml:lang="zh-Hant">
                {$name/text()}
                {if (empty($choro) or $choro[. < 1])
                    then ()
                    else (<addName type="choronym">{$choro/../c_choronym_chn/text()}</addName>)
                    }
                </persName>
                )

let $proper :=
    for $name in $names/../c_name_proper
    return
        if ($name/text() eq concat($name/../c_surname_proper/text(), ' ', $name/../c_mingzi_proper/text()))
        then (<persName type="original">
                    <surname>{xmldb:decode($name/../c_surname_proper/string())}</surname>
                    <forename>{xmldb:decode($name/../c_mingzi_proper/string())}</forename>
               </persName>)
        else(<persName type="original">{xmldb:decode($name/string())}</persName>)
        
let $rm :=
    for $name in $names/../c_name_rm
    return
        if ($name/text() eq concat($name/../c_surname_rm/text(), ' ', $name/../c_mingzi_rm/text()))
        then (<persName type="original">
                    <surname>{xmldb:decode($name/../c_surname_rm/string())}</surname>
                    <forename>{xmldb:decode($name/../c_mingzi_rm/string())}</forename>
               </persName>)
        else(<persName type="original">{xmldb:decode($name/string())}</persName>)
        
                

return
    switch($lang)
        case 'py' return $py 
        case 'hz' return $hz
        case 'proper' return $proper
        case 'rm' return $rm
        default return ()
}; 

declare function local:alias ($person as node()*) as node()* {
(:This function resolves aliases in zh and py.
It checks ALTNAME_DATA for the c_personid and returns persName elements.
:)

(: d= drop                                  
[tts_sysno] INTEGER,                    d
 [c_personid] INTEGER,                  x
 [c_alt_name] CHAR(255),               x
 [c_alt_name_chn] CHAR(255),           x
 [c_alt_name_type_code] INTEGER,        x
 [c_source] INTEGER,                    x
 [c_pages] CHAR(255),                   d
 [c_notes] CHAR,                        x
 [c_created_by] CHAR(255),              x
 [c_created_date] CHAR(255),            x
 [c_modified_by] CHAR(255),             x
 [c_modified_date] CHAR(255),           x
:)

for $person in $ALTNAME_DATA//c_personid[. =$person]
let $code := $ALTNAME_CODES//c_name_type_code[. = $person/../c_alt_name_type_code]

return 
    if (empty($person)) then ()
    else if (empty($person/../c_source)) 
        then (<persName type = "alias" 
                  key="{concat('AKA', $code/text())}">
                    <addName>{$person/../c_alt_name_chn/text()}</addName>
                    {if ($code[. > 1]) 
                     then (<term>{$code/../c_name_type_desc_chn/text()}</term>)
                     else()
                     }                
                    <addName xml:lang="zh-alalc97">{$person/../c_alt_name/text()}</addName>
                    {if ($code[. > 1]) 
                     then (<term>{$code/../c_name_type_desc/text()}</term>)
                     else()
                    }                
                {if (empty($person/../c_notes)) 
                then ()
                else (<note>{$person/../c_notes/text()}</note>)                
                }                
            </persName>)
    else (<persName type = "alias" 
            key="{concat('AKA', $code/text())}"
            source="{concat('#BIB', $person/../c_source/text())}">
                <addName xml:lang="zh-Hant">{$person/../c_alt_name_chn/text()}</addName>
                {if ($code[. > 1]) 
                 then (<term>{$code/../c_name_type_desc_chn/text()}</term>)
                 else()
                 }                
                <addName xml:lang="zh-alalc97">{$person/../c_alt_name/text()}</addName>
                {if ($code[. > 1]) 
                 then (<term>{$code/../c_name_type_desc/text()}</term>)
                 else()
                }                
                {if (empty($person/../c_notes)) 
                then ()
                else (<note>{$person/../c_notes/text()}</note>)                
                }      
            </persName>)            
};

declare function local:kin ($family as node()*) as node()* {

(:This function takes persons via c_personid and returns a list kin group memebers and relations:)

(:
[tts_sysno] INTEGER,                    x                [c_kincode] INTEGER PRIMARY KEY, 
 [c_personid] INTEGER,                  x                [c_kin_pair1] INTEGER,
 [c_kin_id] INTEGER,                    x                [c_kin_pair2] INTEGER, 
 [c_kin_code] INTEGER,                  x                [c_kin_pair_notes] CHAR(50),
 [c_source] INTEGER,                                     [c_kinrel_chn] CHAR(255), 
 [c_pages] CHAR(255),                                    [c_kinrel] CHAR(255), 
 [c_notes] CHAR,                        x                 [c_kinrel_alt] CHAR(255), 
 [c_autogen_notes] CHAR,                                 [c_pick_sorting] INTEGER, 
 [c_created_by] CHAR(255),              d               [c_upstep] INTEGER, 
 [c_created_date] CHAR(255),            d               [c_dwnstep] INTEGER, 
 [c_modified_by] CHAR(255),             d               [c_marstep] INTEGER, 
 [c_modified_date] CHAR(255),           d               [c_colstep] INTEGER)
 :)

(:it would be nice to find valid xml expressions for kinrel so they can be added to tei:relation as @name:)

for $kin in $KIN_DATA//c_personid[. = $family]
let $tie := $KINSHIP_CODES//c_kincode[.= $kin/../c_kin_code]

(:let basic :=
 for $:)
    
return
        <note>
        <listPerson type="kinship">            
            {for $n in $kin
             return
                <person sameAs="{concat('#BIO', $n/../c_kin_id/text())}">                    
                    {if(empty($n/../c_notes)) 
                    then() 
                    else(<note>{$n/../c_notes/text()}</note>)
                    }
                </person>    
            } 
            {for $n in $tie
            return
                <listRelation type="personal">
                    {if (empty($n/../c_pick_sorting)) 
                    then (<relation name="kin">
                            <desc>
                                <desc type="short">{$n/../c_kinrel/text()}</desc>
                                <desc xml:lang="en">{$n/../c_kinrel_alt/text()}</desc>
                                <desc xml:lang="zh-Hant">{$n/../c_kinrel_chn/text()}</desc>
                            </desc>
                    </relation>)
                    else(<relation name="kin" sortKey="{$n/../c_pick_sorting/text()}">
                            <desc>
                                <desc type="short">{$n/../c_kinrel/text()}</desc>
                                <desc xml:lang="en">{$n/../c_kinrel_alt/text()}</desc>
                                <desc xml:lang="zh-Hant">{$n/../c_kinrel_chn/text()}</desc>   
                            </desc>                        
                    </relation>)
                    }
                </listRelation>
            }    
            </listPerson>
        </note>
};

declare function local:asso ($friends as node()*) as node()* {   

for $friend in $ASSOC_DATA//c_personid[. = $friends]
let $tie := $friend/../c_assoc_code
let $code := $ASSOC_CODE_TYPE_REL//c_assoc_code[. =$tie]
let $type := $ASSOC_TYPES//c_assoc_type_id[ .= $code/../c_assoc_type_id]

return <note>
        <listPerson type="social">
                {for $n in $friend
                return
                <person sameAs="{concat('#BIO', $n/../c_kin_id/text())}">
                    { if ($n/../c_notes) 
                    then (<note>{$n/../c_notes/text()}</note>)
                    else()
                    }
                </person>    
                }    
            <listRelation type="social">
            {for $n in $tie
                return 
                if ($ASSOC_CODES//c_assoc_code[.= $n] = $ASSOC_CODES//c_assoc_code[.= $n]/../c_assoc_pair) 
                then (<relation type="mutual" key="{$code/../c_assoc_type_id/text()}" sortKey="{$type/../c_assoc_type_sortorder/text()}">
                        <desc>
                            <desc xml:lang="en">{$type/../c_assoc_type_desc/text()}
                                <label>{$ASSOC_CODES//c_assoc_code[. =$n]/../c_assoc_desc/text()}</label>
                            </desc>
                            <desc xml:lang="zh-Hant">{$type/../c_assoc_type_desc_chn/text()}
                                <label>{$ASSOC_CODES//c_assoc_code[. =$n]/../c_assoc_desc_chn/text()}</label>
                            </desc>
                        </desc>
                    </relation>)
                else (<relation key="{$ASSOC_CODE_TYPE_REL//c_assoc_code[. =$n]/../c_assoc_type_id/text()}" sortKey="{$type/../c_assoc_type_sortorder/text()}">
                        <desc>
                            <desc xml:lang="en">{$type/../c_assoc_type_desc/text()}
                                <label>{$ASSOC_CODES//c_assoc_code[. =$n]/../c_assoc_desc/text()}</label>
                            </desc>
                            <desc xml:lang="zh-Hant">{$type/../c_assoc_type_desc_chn/text()}
                                <label>{$ASSOC_CODES//c_assoc_code[. =$n]/../c_assoc_desc_chn/text()}</label>
                            </desc>
                        </desc>
                    </relation>)
            }
            </listRelation>
        </listPerson>
    </note>
};       

declare function local:status ($accolades as node()*) as node()* {
(:the following lines can be added ones status types are linked to status codes to add a label child element to the language specific desc elements
 : 
 : let $statt := doc("/db/apps/cbdb/source/CBDB/code/STATUS_TYPES.xml")
 : let $statctr := doc("/db/apps/cbdb/source/CBDB/relations/STATUS_CODE_TYPE_REL.xml")
 : 
 : if ($statt//c_status_type_code[. = $statctr//c_status_type_code[. = $code]]) 
 : then (<label>$statt//c_status_type_code[. = $statctr//c_status_type_code[. = $code]]/../c_status_type_desc/text()</label>) else()    
 : if ($statt//c_status_type_code[. = $statctr//c_status_type_code[. = $code]]) 
 : then (<label>$statt//c_status_type_code[. = $statctr//c_status_type_code[. = $code]]/../c_status_type_desc_chn/text()</label>) else()
 :)

for $status in $STATUS_DATA//c_personid[. = $accolades]

let $code := $STATUS_CODES//c_status_code[. = $status/../c_status_code]
let $first := $status/../c_firstyear
let $last := $status/../c_lastyear
return 
    if ($status/../c_status_code[. < 1]) 
    then ()
    else ( element state { if ($first/text() and $last/text() != 0)
          then ( attribute from {local:isodate($first/text())}, 
                attribute to {local:isodate($last/text())})
          else if ($first/text() != 0)
               then (attribute from {local:isodate($first/text())})
               else if ($last/text() != 0)
                    then ( attribute to {local:isodate($last/text())})
                    else (' '),
          element desc { attribute xml:lang {'en'}, $code/../c_status_desc/text()},
          element desc { attribute xml:lang {'zh-Hant'}, $code/../c_status_desc_chn/text()}
          }
          )
};
(:so far so good:)
declare function local:office_title ($offices as node()*) as node()* {


for $ppl in $POSTED_TO_OFFICE_DATA//c_personid[. = $offices]/../c_office_id
let $cat := $OFFICE_CATEGORIES//c_office_category_id[. = $ppl/../c_office_category_id]

let $type := $OFFICE_TYPE_TREE//c_office_type_node_id[. = $OFFICE_CODE_TYPE_REL//c_office_id[. =$ppl]/../c_office_tree_id]
let $code := $OFFICE_CODES//c_office_id[. = $ppl]

return <roleName type ="office"> 
        <roleName xml:lang="en" key="{$type/text()}">
        {$code/../c_office_trans/text()}
            <trait>
                <desc>{$cat/../c_category_desc/text()}</desc>
                <label>{$type/../c_office_type_desc/text()}</label>
            </trait>
        </roleName>
        <roleName xml:lang="zh-alac97" key="{$type/text()}">
        {$code/../c_office_pinyin/text()}
            {if($code/../c_office_pinyin_alt[. !='']) 
            then(<roleName type="alias">{$code/../c_office_pinyin_alt/text()}</roleName>)
            else()
            }
        </roleName>            
        <roleName xml:lang="zh-Hant" key="{$type/text()}">
        {$code/../c_office_chn/text()}
            <trait>
                <desc>{$cat/../c_category_desc_chn/text()}</desc>
                <label>{$type/../c_office_type_desc_chn/text()}</label>
            </trait>
                {if($code/../c_office_chn_alt[. != '']) 
                then(<roleName type="alias">{$code/../c_office_chn_alt/text()}</roleName>)
                else()
                }
        </roleName>
    {if ($cat/../c_notes[.!= '']) 
    then (<note>{$cat/../c_notes/text()}</note>)
    else()
    }
    </roleName>
};

declare function local:instadd ($person as node()*, $inst as node()*) as node()* {
(:- person is c_personid, $inst is data table that holds c_person_id AND c_inst_code  :)
(:- This function returns the institution (orgName) that is linked to a certain posting, including its address. This is NOT necessarily the address of the posting itself.
 : Data on this aspect is still very sparse in 2014 
 : 
 : Switch to ZZZ query table here?
 : so far no end years in code table once they are added query needs a rewrite:) 


    for $person in $inst//c_personid[. =$person]/../c_inst_code[. > 0]
    
    let $dates := $SOCIAL_INSTITUTION_CODES//c_inst_code[. =$person]
    let $names := $SOCIAL_INSTITUTION_CODES//c_inst_name_code[. = $person/../c_inst_name_code]
    let $place := $ADDR_CODES//c_addr_id[. =$SOCIAL_INSTITUTION_ADDR//c_inst_code[. =$person]]
    
    return
        <orgName>
            {if ($dates/../c_inst_begin_year[. =0]) then ()
                else (<date notBefore="{local:isodate($dates/../c_inst_begin_year)}"/>)
            }
                <orgName xml:lang="zh-alac97">{$names/../c_inst_name_py/text()}
                    <state>{$SOCIAL_INSTITUTION_TYPES//c_inst_type_code[. = $SOCIAL_INSTITUTION_CODES//c_inst_code[. =$person]/../c_inst_type_code]/../c_inst_type_py/text()}</state>
                </orgName>
                <orgName xml:lang="zh-Hant">{$names/../c_inst_name_hz/text()}
                    <state>{$SOCIAL_INSTITUTION_TYPES//c_inst_type_code[. = $SOCIAL_INSTITUTION_CODES//c_inst_code[. =$person]/../c_inst_type_code]/../c_inst_type_hz/text()}</state>
                </orgName>
            {if ($person/../c_posting_id[. > 0]) 
            then (<placeName ref="{concat("#PL", $place/../c_inst_addr_id/text())}">                   
                        <note>{$SOCIAL_INSTITUTION_ADDR_TYPES//c_inst_addr_type[. = $SOCIAL_INSTITUTION_ADDR//c_inst_code[. =$person]/../c_inst_addr_type]/../c_inst_addr_type_desc/text()}</note>
                        <note>{$SOCIAL_INSTITUTION_ADDR_TYPES//c_inst_addr_type[. = $SOCIAL_INSTITUTION_ADDR//c_inst_code[. =$person]/../c_inst_addr_type]/../c_inst_addr_type_desc_chn/text()}</note>
                    {if ($SOCIAL_INSTITUTION_ADDR//c_inst_code[. =$person]/../c_notes[. != '']) 
                    then (<note>{$SOCIAL_INSTITUTION_ADDR//c_inst_code[. =$person]/../c_notes/text()}</note>)
                    else()
                    }
                </placeName>)
            else()
            }
            {if ($SOCIAL_INSTITUTION_CODES//c_inst_code[. = $person]/../c_notes[. !='']) then (
            <note>{$SOCIAL_INSTITUTION_CODES//c_inst_code[. = $person]/../c_notes/text()}</note>)
            else()
            }
    </orgName>
};

declare function local:posting ($posting as node()*) as node()* {

for $post in $POSTED_TO_OFFICE_DATA//c_personid[. =$posting]/../c_posting_id

return
    <state notBefore = "{local:isodate($post/../c_firstyear/text())}" 
            notAfter = "{local:isodate($post/../c_lastyear/text())}"
            type = "posting" 
            sortKey = "{$post/../c_sequence/text()}"
            key ="{$post/../c_office_category_id/text()}">
        <label>posting</label>
        {
        if ($post/../c_notes[. != '']) 
        then (<note>{$post/../c_notes/text()}</note>)
        else()
        }
        {
        if ($post/../c_appt_type_code[. > -1] or $post/../c_assume_office_code[. > -1]) 
        then (<desc>
                <desc xml:lang ="en">{$APPOINTMENT_TYPE_CODES//c_appt_type_code[. = $post/../c_appt_type_code]/../c_appt_type_desc/text()}
                <label>{$ASSUME_OFFICE_CODES//c_assume_office_code[. = $post/../c_assume_office_code]/../c_assume_office_desc/text()}</label>
            </desc>
            <desc xml:lang="zh-Hant">{$APPOINTMENT_TYPE_CODES//c_appt_type_code[. = $post/../c_appt_type_code]/../c_appt_type_desc_chn/text()}
                <label>{$ASSUME_OFFICE_CODES//c_assume_office_code[. = $post/../c_assume_office_code]/../c_assume_office_desc_chn/text()}</label>
            </desc>
            </desc>)
        else()
        }
        {if ($POSTED_TO_ADDR_DATA//c_posting_id[. = $post]/../c_addr_id[. < 1]) 
        then ()
        else (<placeName ref="{concat('#PL', $POSTED_TO_ADDR_DATA//c_posting_id[. = $post]/../c_addr_id/text())}"/>)
        }    
        {if ($POSTED_TO_OFFICE_DATA//c_personid[. = $nodes]/../c_inst_code[. <1]) then()
        else(<state>{local:instadd($ppl, $POSTED_TO_OFFICE_DATA)}</state>)
        }
    </state>
};

declare function local:event ($participants as node()*) as node()* {
(: no py or en name for events:)

for $event in $EVENTS_DATA//c_personid[. = $participants]
let $code := $EVENT_CODES//c_event_code[. = $event/../c_event_code]
let $event-add := $EVENTS_ADDR//c_event_record_id[. = $event/../c_event_record_id]
        return
            element listEvent {  
                element event { 
                    if ($event/../c_year != 0)
                    then (attribute when {local:isodate($event/../c_year/text())})
                    else (''), 
                    if ($code[. > 0])
                    then (element head {$code/../c_event_name_chn/text()})
                    else (), 
                    if (empty($event/../c_event)) 
                    then ()
                    else (element label {$event/../c_event/text()}), 
                    if (empty($event/../c_role))
                    then()
                    else (element desc {$event/../c_role/text()}),
                    if (empty($event/../c_notes))
                    then()
                    else(element note {$event/../c_notes/text()}), 
                    if (empty($event-add))
                    then()
                    else( element placeName {attribute ref {concat('#PL', $event-add/../c_addr_id/text())}})    
                } 
             }
};

declare function local:posses ($possesions as node()*) as node()* {


for $stuff in $POSSESSION_DATA//c_personid[. = $possesions]
let $act := $POSSESSION_ACT_CODES//c_possession_act_code[ . = $stuff/../c_possession_act_code]

return 
 if(empty($stuff))
 then()
else( 
<state type="possession" subtype="{concat('POS', $act/text())}">
    <label xml:lang="zh-Hant">{$stuff/../c_possession_desc_chn/text()}</label>                    
    <label xml:lang="en">{$stuff/../c_possession_desc/text()}</label>
</state>)
};

declare function local:entry ($nodes as node()*) as node()* {
let $entd := doc("/db/apps/cbdb/source/CBDB/data/ENTRY_DATA.xml")
let $entc := doc("/db/apps/cbdb/source/CBDB/code/ENTRY_CODES.xml")
let $entt := doc("/db/apps/cbdb/source/CBDB/code/ENTRY_TYPES.xml")
let $entctr := doc("/db/apps/cbdb/source/CBDB/code/ENTRY_CODE_TYPE_REL.xml")


for $ppl in $entd//c_personid[. = $nodes]/../c_entry_code

let $type := $entt//c_entry_type[. =$entctr//c_entry_code[. = $ppl]/../c_entry_type]
return
                <event when = "{if ($ppl/../c_year[. > 0]) then (local:isodate($ppl/../c_year/text())) else ()}" 
                        key ="{$ppl/../c_exam_rank/text()}">
                <label>entry</label>
                {if ($ppl/../c_notes[. != '']) then (<note>{$ppl/../c_notes/text()}</note>) 
                else ()
                }
                {if ($ppl/../c_age[. > 0]) then (<note>age: {$ppl/../c_age/text()}</note>)
                else ()
                }
                {if ($ppl/../c_attempt_count[. > 0]) then (<note>attempt: {$ppl/../c_attempt_count/text()}</note>)
                else()
                }
                    <event xml:lang="en"
                            type = "{$type/../c_entry_type_desc/text()}" 
                            sortKey = "{$type/../c_entry_type_sortorder/text()}">
                        <label>{$entc//c_entry_code[. = $ppl]/../c_entry_desc/text()}</label>
                    </event>
                    <event xml:lang="zh-Hant"
                            type = "{$type/../c_entry_type_desc_chn/text()}"
                            sortKey = "{$type/../c_entry_type_sortorder/text()}">
                         <label>{$entc//c_entry_code[. = $ppl]/../c_entry_desc_chn/text()}</label>
                    </event>
                    {if ($entd//c_personid[. = $nodes]/../c_inst_code[. < 1]) then ()
                        else(local:instadd($ppl, $entd))
                        }
                    {if($entd/../c_addr_id[. < 1]) then ()
                    else(<placeName ref="{concat('#PL', $entd/../c_addr_id/text())}"/>)                   
                    }
                </event>
};

declare function local:bio-add ($resident as node()*) as node()* {

for $address in $BIOG_ADDR_DATA//c_personid[. = $resident]
let $code := $BIOG_ADDR_CODES//c_addr_type[. = $address/../c_addr_type]
(:dummy :)
return 
 ()
};

(: and here again:)
declare function local:biog ($persons as node()*) as node()* {

(: 
[tts_sysno] INTEGER,                            x
 [c_personid] INTEGER PRIMARY KEY,            x
 [c_name] CHAR(255),                            x
 [c_name_chn] CHAR(255),                        x
 [c_index_year] INTEGER,                        x
 [c_female] BOOLEAN NOT NULL,                   x
 [c_ethnicity_code] INTEGER,                    x
 [c_household_status_code] INTEGER,             x
 [c_tribe] CHAR(255),                           x
 [c_birthyear] INTEGER,                         x
 [c_by_nh_code] INTEGER,                        x
 [c_by_nh_year] INTEGER,                        x
 [c_by_range] INTEGER,                          d  
 [c_deathyear] INTEGER,                         x
 [c_dy_nh_code] INTEGER,                        x
 [c_dy_nh_year] INTEGER,                        x
 [c_dy_range] INTEGER,                          d
 [c_death_age] INTEGER,                         x
 [c_death_age_approx] INTEGER,                  x
 [c_fl_earliest_year] INTEGER,                  x
 [c_fl_ey_nh_code] INTEGER,                     x
 [c_fl_ey_nh_year] INTEGER,                     x
 [c_fl_ey_notes] CHAR,                          x
 [c_fl_latest_year] INTEGER,                    x
 [c_fl_ly_nh_code] INTEGER,                     x
 [c_fl_ly_nh_year] INTEGER,                     x
 [c_fl_ly_notes] CHAR,                          x
 [c_surname] CHAR(255),                         x
 [c_surname_chn] CHAR(255),                     x
 [c_mingzi] CHAR(255),                          x
 [c_mingzi_chn] CHAR(255),                      x
 [c_dy] INTEGER,                                 x
 [c_choronym_code] INTEGER,                     x
 [c_notes] CHAR,                                    x
 [c_by_intercalary] BOOLEAN NOT NULL,           x
 [c_dy_intercalary] BOOLEAN NOT NULL,           x
 [c_by_month] INTEGER,                            x
 [c_dy_month] INTEGER,                            x
 [c_by_day] INTEGER,                               x
 [c_dy_day] INTEGER,                                x
 [c_by_day_gz] INTEGER,                           x
 [c_dy_day_gz] INTEGER,                            x
 [TTSMQ_db_ID] CHAR(255),                           x
 [MQWWLink] CHAR(255),                              x
 [KyotoLink] CHAR(255),                         x
 [c_surname_proper] CHAR(255),                  x
 [c_mingzi_proper] CHAR(255),                   x
 [c_name_proper] CHAR(255),                     x
 [c_surname_rm] CHAR(255),                      x
 [c_mingzi_rm] CHAR(255),                       x
 [c_name_rm] CHAR(255),                         x
 [c_created_by] CHAR(255),                      x
 [c_created_date] CHAR(255),                    x
 [c_modified_by] CHAR(255),                     x
 [c_modified_date] CHAR(255),                   x
 [c_self_bio] BOOLEAN NOT NULL)                 x
 :)


for $person in $persons

let $choro := $CHORONYM_CODES//c_choronym_code[. = $person/../c_choronym_code]
let $household := $HOUSEHOLD_STATUS_CODES//c_household_status_code[. = $person/../c_household_status_code]
let $ethnicity := $ETHNICITY_TRIBE_CODES//c_ethnicity_code[. = $person/../c_ethnicity_code]

let $association := $ASSOC_DATA//c_personid[. = $person]
let $kin := $KIN_DATA//c_personid[. = $person]
let $status := $STATUS_DATA//c_personid[. = $person]
let $post := $POSTED_TO_OFFICE_DATA//c_personid[. = $person]
let $posssesion := $POSSESSION_DATA//c_personid[. = $person]


let $bio-add := $BIOG_ADDR_DATA//c_personid[. = $person]
let $bio-inst := $BIOG_INST_DATA//c_personid[. = $person]


return 
    <person ana="historical" xml:id="{concat('BIO', $person/text())}">
        <idno type="TTS">{$person/../tts_sysno/text()}</idno>
        <persName type="main">
            {if (empty($person/../c_name_chn))
            then()
            else (local:name($person, 'hz'))
            }
            {if (empty($person/../c_name))
            then()
            else (local:name($person, 'py'))
            }
        </persName>
        {if (empty($person/../c_name_proper))
         then()
         else (local:name($person, 'proper'))
         }
         {if (empty($person/../c_name_rm))
         then()
         else (local:name($person, 'rm'))
         }        
        {local:alias($person)}
        {if ($person/../c_female = 1) then (<sex value="2">f</sex>) 
         else (<sex value ="1">m</sex>)
       }
        {if (empty($person/../c_birthyear) or $person/../c_birthyear[. = 0])
        then()
        else (<birth when="{local:isodate($person/../c_birthyear)}">
            <date>{$person/../c_birthyear/text()} {$person/../c_by_month/text()} {$person/../c_by_day/text()}</date>
            {if (empty($person/../c_dy) or $person/../c_dy[. < 1])
            then ()
            else(<date calendar="chinTrad">
                    <date period="dynasty" sameAs="{concat('#D',$person/../c_dy/text())}"/>
                    {if  ($person/../c_by_nh_code[.  > 0])
                     then (<date period="reign" sameAs="{concat('#R',$person/../c_by_nh_code/text())}">
                            {$person/../c_by_nh_year/text()}</date>)
                     else()
                    }
                    {if ($person/../c_by_intercalary[ . = 1])
                    then (<note>intercalary</note>)
                    else ()
                    }
            </date>)
            }
        </birth>)
        }
        {if (empty($person/../c_deathyear) or $person/../c_deathyear[. = 0])
        then()
        else (<death when="{local:isodate($person/../c_deathyear)}">
            <date>{$person/../c_deathyear/text()} {$person/../c_dy_month/text()} {$person/../c_dy_day/text()}</date>
            {if (empty($person/../c_dy) or $person/../c_dy[. < 1])
            then ()
            else(<date calendar="chinTrad">
                    <date period="dynasty" sameAs="{concat('#D',$person/../c_dy/text())}"/>
                    {if  ($person/../c_dy_nh_code[.  > 0])
                     then (<date period="reign" sameAs="{concat('#R',$person/../c_dy_nh_code/text())}">
                            {$person/../c_dy_nh_year/text()}</date>)
                     else()
                    }
                    {if ($person/../c_dy_intercalary[ . = 1])
                    then (<note>intercalary</note>)
                    else ()
                    }
            </date>)
            }
        </death>)
        }
        {let $earliest := $person/../c_fl_earliest_year
        let $latest := $person/../c_fl_latest_year
        let $index := $person/../c_index_year
        return
            if ($earliest or $latest or $index > 0) 
            then (element floruit { if ($earliest/text() and $latest/text() != 0) 
                                    then ( attribute notBefore {local:isodate($earliest/text())}, 
                                            attribute notAfter {local:isodate($latest/text())})
                                    else if ($earliest/text() != 0)
                                          then (attribute notBefore {local:isodate($earliest/text())})
                                          else if ($latest/text() != 0)
                                               then ( attribute notAfter {local:isodate($latest/text())})
                                               else (' '),                              
                                  if ($index != 0)
                                  then (element date { attribute type {'index'},
                                        local:isodate($index)}) 
                                  else (''), 
                                  if (empty($person/../c_fl_ey_notes) and empty($person/../c_fl_ly_notes))
                                  then ()
                                  else(element note {$person/../c_fl_ey_notes/text() , $person/../c_fl_ly_notes/text()})
                                  }                      
                   )
           else()
        }
        {if ($person/../c_death_age_approx and $person/../c_death_age > 0)
        then (<age precision="{$person/../c_death_age_approx/text()}">
                {$person/../c_death_age/text()}</age>)
        else (<age>{$person/../c_death_age/text()}</age>)        
        }
        {if ($person/../c_household_status_code > 0) 
        then (<trait type="household">
                <label xml:lang="en">{$household/../c_household_status_desc/text()}</label>
                <label xml:lang="zh-Hant">{$household/../c_household_status_desc_chn/text()}</label>
            </trait>)
            else()
       }
       
        {if ($person/../c_ethnicity_code > 0) 
        then (<trait type="ethnicity" key="{$ethnicity/../c_group_code/text()}">
                <label>{$ethnicity/../c_ethno_legal_cat/text()}</label>
                        <desc xml:lang="en">{$ethnicity/../c_romanized/text()}</desc>
                        <desc xml:lang="zh-alac97">{$ethnicity/../c_name/text()}</desc>
                        <desc xml:lang="zh-Hant">{$ethnicity/../c_name_chn/text()}</desc>
                        {if ($ethnicity/../c_notes) 
                        then (<note>{$ethnicity/../c_notes/text()}</note>)
                        else()
                        }
               </trait>)
               else()
        }
        {if ($person/../c_tribe) then (
        <trait type="tribe">
            <desc>{$person/../c_tribe/text()}</desc>
        </trait>)
        else()
        }
        {if ($person/../c_notes) then (
        <note>{$person/../c_notes/text()}</note>)
        else ()
        }
        
        {if ($person/../c_source) 
        then (<bibl>
            <ref target="{concat('#BIB', $person/../c_source/text())}"/>
                {
                if (empty($person/../c_pages)) then ()
                else(<biblScope unit="page">{$person/../c_pages/text()}</biblScope>)
                }
        </bibl>)
        else ()
        }
        {
        if (empty($kin) and empty($association))
        then ()
        else (<affiliation>    
            {if (empty($kin)) 
            then()
                else(local:kin($person))
            }
            {if (empty($association)) 
            then()
            else(local:asso($person))
            }
        </affiliation>)
        }
        {
        if (empty($status) and empty($post)) 
        then ()
        else(<socecStatus>
            {if ($status) 
            then(local:status($person))
            else()
            }
            {if ($post) 
            then (local:office_title($person))
            else()
            }
        </socecStatus>)
        }
        {local:event($person)}
        {if (empty($posssesion)) 
        then ()
        else(local:posses($person))
        }
        {local:instadd($person, $bio-inst)}
        {local:bio-add($person)}
        {if (empty($person/../TTSMQ_db_ID) and empty($person/../MQWWLink) and empty($person/../KyotoLink))
        then()
        else (<linkGrp>
            {let $links := ($person/../TTSMQ_db_ID, $person/../MQWWLink, $person/../KyotoLink)
            for $link in $links[. != '']
            return
            <ptr target="{$link/text()}"/>}        
        </linkGrp>)
        }
        
        {if (empty($person/../c_created_by)) 
        then ()
        else (<note type="created" target="{concat('#',$person/../c_created_by/text())}">
                <date when="{local:sqldate($person/../c_created_date)}"/>
              </note>)
        }
        {if (empty($person/../c_modified_by)) 
        then ()
        else (<note type="modified" target="{concat('#',$person/../c_modified_by/text())}">
                <date when="{local:sqldate($person/../c_modified_date)}"/>
              </note>)
        }
       </person> 
};
let $test := $BIOG_MAIN//c_personid[. < 500]
let $full := $BIOG_MAIN//c_personid[. > 0]

return
xmldb:store($target, 'listPerson.xml',
    <listPerson>
        {local:biog($test)}
    </listPerson>    
) 

