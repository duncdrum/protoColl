xquery version "3.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.tei-c.org/ns/1.0";


declare variable $src := '/db/apps/cbdb-data/src/xml/';
declare variable $target := '/db/apps/cbdb-data/target/';

declare variable $TEXT_BIBLCAT_CODES := doc(concat($src, 'TEXT_BIBLCAT_CODES.xml')); 
declare variable $TEXT_BIBLCAT_CODE_TYPE_REL := doc(concat($src, 'TEXT_BIBLCAT_CODE_TYPE_REL.xml')); 
declare variable $TEXT_BIBLCAT_TYPES := doc(concat($src, 'TEXT_BIBLCAT_TYPES.xml')); 
declare variable $TEXT_BIBLCAT_TYPES_1 := doc(concat($src, 'TEXT_BIBLCAT_TYPES_1.xml')); 
declare variable $TEXT_BIBLCAT_TYPES_2 := doc(concat($src, 'TEXT_BIBLCAT_TYPES_2.xml')); 

declare variable $EXTANT_CODES := doc(concat($src, 'EXTANT_CODES.xml')); 
declare variable $COUNTRY_CODES:= doc(concat($src, 'COUNTRY_CODES.xml')); 

declare variable $TEXT_CODES := doc(concat($src, 'TEXT_CODES.xml')); 
declare variable $TEXT_DATA := doc(concat($src, 'TEXT_DATA.xml')); 
declare variable $TEXT_ROLE_CODES := doc(concat($src, 'TEXT_ROLE_CODES.xml')); 
declare variable $TEXT_TYPE := doc(concat($src, 'TEXT_TYPE.xml')); 

declare variable $YEAR_RANGE_CODES:= doc(concat($src, 'YEAR_RANGE_CODES.xml'));

(:bibliography.xql reads the various basic entities for bibliographic information
    and creates a listBibl element for inclusion in the body element via xi:xinclude.  
:)

(: TODO: 
    - convert types to taxonomy?
    - $TEXT_ROLE_CODES//c_role_desc_chn is currently dropped from db might go into odd later
    - get all the created by and modified ppl into header as refs
    - finish local:categories
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

declare function local:bibl-dates($dates as node()*, $type as xs:string?) as node()* {
(: There are two principle date references in TEXT_CODE. original (ori) and published (pub).
This function resolves the relations of these dates expecting a valid c_textid.
It returns both english and chinese dates, refering to  chal_ZH.xml .
:)

(:
(distinct-values($TEXT_CODES//c_pub_range_code), distinct-values($TEXT_CODES//c_range_code))
shows range 300, and 301 not to be in use, 
we also collapse the distinction between 'during' and "around" to "when"

:)

let $original :=
    for $date in $dates
    let $orig-year := $date/../c_text_year
    let $orig-nian := $date/../c_text_nh_code/text()
    let $orig-hao := $date/../c_text_nh_year/text()
    let $orig-era := $date/../c_period/text()    
    
    let $orig-range := $YEAR_RANGE_CODES//c_range_code[. = $date/../c_text_range_code/text()]
    
    where $orig-year[. != 0]
   
    return
        switch ($orig-range)
            case '-1' 
                return <date type="original" notAfter="{local:isodate ($orig-year)}">
                        {$orig-era}
                            {if ($orig-nian = 0 or empty($orig-nian))
                             then ()
                             else(<ref target="{concat("#R", $orig-nian)}">
                                {$orig-hao}
                             </ref>)
                             }
                         </date>                    
            case '1' 
                return <date type="original" notBefore="{local:isodate ($orig-year)}">
                        {$orig-era}
                            {if ($orig-nian = 0 or empty($orig-nian))
                             then ()
                             else(<ref target="{concat("#R", $orig-nian)}">
                                {$orig-hao}
                             </ref>)
                             }
                        </date>
             default return 
                        <date type="original" when="{local:isodate ($orig-year)}">
                            {$orig-era}
                            {if ($orig-nian = 0 or empty($orig-nian))
                            then ()
                            else(<ref target="{concat("#R", $orig-nian)}">
                                {$orig-hao}
                            </ref>)
                            }
                        </date>

let $published := 
    for $date in $dates 
    let $pub-year := $date/../c_pub_year    
    
    let $pub-nian := $date/../c_pub_nh_code/text()
    let $pub-hao := $date/../c_pub_nh_year/text()
    
    let $pub-era := $date/../c_pub_dy
    
    let $pub-range := $YEAR_RANGE_CODES//c_range_code[. = $date/../c_pub_range_code/text()]
    where $pub-year[. != 0]
   
    return
        switch ($pub-range)
            case '-1' 
                return <date type="published" notAfter="{local:isodate ($pub-year)}">
                        {if ($pub-era[. = 0]) then ()
                        else(<ref target="{concat("#D", $pub-era)}"/>)
                        }
                            {if ($pub-nian = 0 or empty($pub-nian))
                             then ()
                             else(<ref target="{concat("#R", $pub-nian)}">
                                {$pub-hao}
                             </ref>)
                             }
                         </date>                    
            case '1' 
                return <date type="published" notBefore="{local:isodate ($pub-year)}">
                        {if ($pub-era[. = 0]) then ()
                        else(<ref target="{concat("#D", $pub-era)}"/>)
                        }
                            {if ($pub-nian = 0 or empty($pub-nian))
                             then ()
                             else(<ref target="{concat("#R", $pub-nian)}">
                                {$pub-hao}
                             </ref>)
                             }
                        </date>
             default return 
                        <date type="published" when="{local:isodate ($pub-year)}">
                            {if ($pub-era[. = 0]) then ()
                            else(<ref target="{concat("#D", $pub-era)}"/>)
                            }
                            {if ($pub-nian = 0 or empty($pub-nian))
                            then ()
                            else(<ref target="{concat("#R", $pub-nian)}">
                                    {$pub-hao}
                                  </ref>)
                            }
                        </date>
return
    switch($type)
        case 'ori' return $original
        case 'pub' return $published
    default return ()

};

declare function local:roles ($roles as node()*)  as node()* {

(:this function takes in c_role_id from TEXT_DATA and returns suitable TEI elements for each.
It simplifies c_role_id[. = 11] 'work included in' to 'contributor' and drops the chinese role terms.
These could be added back in later via a translation of the tei schema file.
:)

for $role in $roles
let $code :=  $TEXT_ROLE_CODES//c_role_id[. = $role]
let $bio-id := $role/../c_personid
where $bio-id != 0

return
    switch($role)
        case '0' case '2' return <editor><ptr target="{concat('#BIO', $bio-id)}"/></editor>
        case '1' return <author><ptr target="{concat('#BIO', $bio-id)}"/></author>
        case '4' return <publisher><ptr target="{concat('#BIO', $bio-id)}"/></publisher>   
        case '11' return <editor role="contributor"><ptr target="{concat('#BIO', $bio-id)}"/></editor>
    default return <editor role="{$code/../c_role_desc}"><ptr target="{concat('#BIO', $bio-id)}"/></editor>

};

declare function local:categories ($categories as node()*)  as node()* {

(:This function transforms $TEXT_BIBLCAT_CODES into a  TEI <taxonomy>.

:)

for $cat in $categories
let $genre :=  $TEXT_BIBLCAT_CODE_TYPE_REL//c_text_cat_code[. = $cat]
let $type := $TEXT_BIBLCAT_TYPES//c_text_cat_type_id[. = $genre/../c_text_cat_type_id]
let $parent-id := $type/../c_text_cat_type_parent_id
let $type-lvl := $type/../c_text_cat_type_level
(:  $TEXT_BIBLCAT_TYPES_1   $TEXT_BIBLCAT_TYPES_2  :)

return
    switch($cat/text())
        case '0' case '2' return <editor><ptr target="{concat('#BIO', $bio-id)}"/></editor>
        case '1' return <author><ptr target="{concat('#BIO', $bio-id)}"/></author>
        case '4' return <publisher><ptr target="{concat('#BIO', $bio-id)}"/></publisher>   
        case '11' return <editor role="contributor"><ptr target="{concat('#BIO', $bio-id)}"/></editor>
    default return <editor role="{$code/../c_role_desc}"><ptr target="{concat('#BIO', $bio-id)}"/></editor>
};

declare function local:bibliography ($texts as node()*) {

(:This function reads the entities in TEXT_CODES [sic] and generates corresponding tei:bibl elements:)

for $text in $texts

let $role := $TEXT_DATA//c_textid[ . = $text]/../c_role_id

let $cat  := $TEXT_BIBLCAT_CODES//c_text_cat_code[. =  $text/../c_bibl_cat_code/text()]
let $type := $TEXT_TYPE//c_text_type_code[. =$text/../c_text_type_id/text()]

let $extant := $EXTANT_CODES//c_extant_code[. = $text/../c_extant/text()]
let $country := $COUNTRY_CODES//c_country_code[. = $text/../c_pub_country/text()]


(: d= drop
[tts_sysno] INTEGER,                     x
 [c_textid] INTEGER PRIMARY KEY,       x
 [c_title_chn] CHAR(255),               x
 [c_suffix_version] CHAR(255),         x
 [c_title] CHAR(255),                    x
 [c_title_trans] CHAR(255),             x
 [c_text_type_id] INTEGER,              x        
 [c_text_year] INTEGER,                 x
 [c_text_nh_code] INTEGER,              x
 [c_text_nh_year] INTEGER,              x
 [c_text_range_code] INTEGER,          x
 [c_period] CHAR(255),                  x
 [c_bibl_cat_code] INTEGER,            x     
 [c_extant] INTEGER,                    x
 [c_text_country] INTEGER,             x 
 [c_text_dy] INTEGER,                   x
 [c_pub_country] INTEGER,              x
 [c_pub_dy] INTEGER,                    x
 [c_pub_year] CHAR(50),                 x
 [c_pub_nh_code] INTEGER,               x   
 [c_pub_nh_year] INTEGER,               x
 [c_pub_range_code] INTEGER,            x
 [c_pub_loc] CHAR(255),                  x
 [c_publisher] CHAR(255),               x
 [c_pub_notes] CHAR(255),               x
 [c_source] INTEGER,                     x
 [c_pages] CHAR(255),                    x
 [c_url_api] CHAR(255),                  x
 [c_url_homepage] CHAR(255),            x
 [c_notes] CHAR,                          x
 [c_number] CHAR(255),                   x
 [c_counter] CHAR(255),                  x
 [c_title_alt_chn] CHAR(255),           x
 [c_created_by] CHAR(255),              x
 [c_created_date] CHAR(255),            x
 [c_modified_by] CHAR(255),             x
 [c_modified_date] CHAR(255))           x
 :)


return
    <bibl xml:id="{concat("BIB", $text/text())}">
        {if (empty($text/../tts_sysno))
        then ()
        else(<idno type="TTS">{$text/../tts_sysno/text()}</idno>)
        }
        {if (empty($type))
        then(<title type="main">
                <title xml:lang="zh-Hant">{$text/../c_title_chn/text()}</title>
                <title xml:lang="zh-alac97">{$text/../c_title/text()}</title>
            </title>)
        else (<title type="main" key="{$type}">
                <title xml:lang="zh-Hant">{$text/../c_title_chn/text()}</title>
                <title xml:lang="zh-alac97">{$text/../c_title/text()}</title>
            </title>)
        }
        {if (empty($text/../c_title_alt_chn))
        then ()
        else (<title type="variant">{$text/../c_title_alt_chn/text()}</title>)        
        }
        {if (empty($text/../c_title_trans))
        then ()
        else (<title xml:lang="en" type="translation">{$text/../c_title_trans/text()}</title>)        
        }
        {if (empty($text/../c_text_year))
        then ()
        else (local:bibl-dates($text, 'ori'))        
        }
        {if (empty($text/../c_text_country) or $text/../c_text_country[. = 0]) 
        then ()
        else ( <country xml:lang="zh-Hant">{$country/../c_country_desc_chn/text()}</country>,
                <country xml:lang="en">{$country/../c_country_desc/text()}</country>) 
        }
        {if (empty($text/../c_suffix_version))
        then ()
        else (<edition>{$text/../c_suffix_version/text()}</edition>)
        }
        {if (empty($text/../c_publisher))
        then ()
        else (<publisher>{$text/../c_publisher/text()}</publisher>) 
        }
        {if (empty($text/../c_pub_loc))
        then ()
        else (<pubPlace>{$text/../c_pub_loc/text()}</pubPlace>) 
        }
        {if (empty($country) or $country[. = 0])
        then ()
        else (<pubPlace><country>{$country/../c_country_desc/text()}</country></pubPlace>)
        }
        {if (empty($text/../c_pub_year))
        then ()
        else (local:bibl-dates($text, 'pub'))        
        }
        {if (empty($text/../c_extant))
        then ()
        else (<state><ab>{$extant/../c_extant_desc/text()}</ab></state>)        
        }
        {if (empty($text/../c_text_type_id) or $text/../c_text_type_id[. = 0])
        then ()
        else (<ref type="genre" subtype="texttype" target="{concat("#TT", $text/../c_text_type_id/text())}"/>)        
        }
        {if (empty($text/../c_bibl_cat_code) or $text/../c_bibl_cat_code[. = 0])
        then ()
        else (<ref type="genre" subtype="biblcat" target="{concat("#TT", $text/../c_bibl_cat_code/text())}"/>)        
        }
        {if (empty($text/../c_pub_notes) or $text/../c_pub_notes[. = '-1'])
        then ()
        else (<note>{$text/../c_pub_notes/text()}</note>) 
        }
        {if (empty($text/../c_source) or $text/../c_source[. < 1])
        then ()
        else (<bibl>
                <ref target="{concat('#BIB', $text/../c_source/text())}"/>
                {
                if (empty($text/../c_pages)) then ()
                else(<biblScope unit="page">{$text/../c_pages/text()}</biblScope>)
                }
                {
                if (empty($text/../c_number)) then () 
                else (<biblScope>{$text/../c_number/text()} {$text/../c_counter/text()}</biblScope>)
                }                
              </bibl>) 
        }
        {if (empty($role))
        then()
        else (local:roles($role))
        }
        {if (empty($text/../c_url_api))
        then ()
        else (<ref target="{$text/../c_url_api/text()}">
            {$text/../c_url_homepage/text()}
            </ref>)       
        }
        {if (empty($text/../c_notes))
        then ()
        else(<note>{$text/../c_notes/text()}</note>)
        }
        {if (empty($text/../c_created_by)) 
        then ()
        else (<note type="created" target="{concat('#',$text/../c_created_by/text())}">
                <date when="{local:sqldate($text/../c_created_date)}"/>
              </note>)
        }
        {if (empty($text/../c_modified_by)) 
        then ()
        else (<note type="modified" target="{concat('#',$text/../c_modified_by/text())}">
                <date when="{local:sqldate($text/../c_modified_date)}"/>
              </note>)
        }
</bibl>

};

xmldb:store($target, 'listBibl.xml',
    <listBibl>
        {local:bibliography($TEXT_CODES//c_textid[. > 0])}
</listBibl>) 




