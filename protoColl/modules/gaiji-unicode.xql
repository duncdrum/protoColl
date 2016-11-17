xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable $text := doc(concat($corpus, 'KR2k0008.xml'));

declare function local:decimal-to-hex ($x as xs:integer) {
    (:  aux function that converts default decimal codepoints to unicode hexadecimal  :)
    if ($x = 0)
    then ('0')
    else concat(
        if ($x gt 16)
        then (local:decimal-to-hex($x idiv 16))
        else (''),
            substring('0123456789ABCDEF',
                ($x mod 16) + 1, 1))
};  

declare function local:add-gaiji-tags($glyph as node()*) as item()* {
    (:  create glyph entries for charDecl.xml based on original references  :)
    (:  generate @xml:id based on unicode hex value :)
<charDecl xml:lang="en">
    {
    for $glyph in $gaiji//glyph
    return 
    (:If first character is IDC glyph use old id:)
        if (string-to-codepoints(
                substring($glyph/mapping[1]/string(), 1, 1)
                ) = 12272 to 12283 
            )
        then (<glyph
                xml:id="{data($glyph/@n)}" 
                n="{data($glyph/@n)}">
                {$glyph/*}
            </glyph>)
        else (<glyph
                xml:id="u{
                    local:decimal-to-hex(string-to-codepoints(substring($glyph/mapping[1]/string(), 1, 1)))
                    }" 
                n="{data($glyph/@n)}">
                {$glyph/*}
            </glyph>)
    }
</charDecl>
};

declare function local:update-gaiji-ref($nodes as node()*) as item()* {
    (: run  on $text//g after initial conversion :)
    (:  !!! The return type needs to be text(), string() will create TOFU  !!! :)
    for $g in $nodes, 
        $match in $gaiji//glyph
    where data($g/@xml:id) eq data($match/@n)
    return
        update replace $g with
        <g ref="#{data($match/@xml:id)}">
            {$match/mapping[@type ="Unicode"]/text()}
        </g>
};