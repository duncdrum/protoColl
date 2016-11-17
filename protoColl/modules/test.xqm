xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable  $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable  $text := doc(concat($corpus, 'KR2k0008.xml'));


declare function local:gaiji-ref($nodes as node()*) as item()* {
    for $g in $nodes, 
        $match in $gaiji//glyph
    where data($g/@xml:id) eq data($match/@n)
    return
        update replace $g with
        <g ref="#{data($match/@xml:id)}">
            {$match/mapping[@type ="Unicode"]/text()}
        </g>
};


local:gaiji-ref($text//g)