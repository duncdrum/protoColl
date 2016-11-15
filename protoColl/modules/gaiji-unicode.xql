declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare function local:decimal-to-hex ($x as xs:integer) {
(:convert  decimal codepoints to unicode hexadecimal  :)
    if ($x = 0)
    then ('0')
    else concat(
        if ($x gt 16)
        then (local:decimal-to-hex($x idiv 16))
        else (''),
            substring('0123456789ABCDEF',
                ($x mod 16) + 1, 1))
};                                   

(:generate xml:id based on unicode hex value:)

<charDecl xml:lang="en">
    {
    for $glyph in /tei:charDecl/tei:glyph
    return 
    (:If first character is IDC glyph use old id:)
        if (string-to-codepoints(
                substring($glyph/tei:mapping[1]/string(), 1, 1)
                ) = 12272 to 12283 
            )
        then (<glyph
                xml:id="{data($glyph/@n)}" 
                n="{data($glyph/@n)}">
                {$glyph/*}
            </glyph>)
        else (<glyph
                xml:id="u{
                    local:decimal-to-hex(string-to-codepoints(substring($glyph/tei:mapping[1]/string(), 1, 1)))
                    }" 
                n="{
                    data($glyph/@n)
                    }">
                {$glyph/*}
            </glyph>)
    }
</charDecl>