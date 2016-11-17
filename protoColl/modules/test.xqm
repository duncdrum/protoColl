xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable  $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable  $text := doc(concat($corpus, 'KR2k0008.xml'));


declare function local:add-sheet($nodes as node()*) as item()* {
    (:  Add sheet ab elements for structural markup based on previously converted pb elements  :)
    (: run  on $text//ab after initial conversion :)
    (: replaces the old ab element with a nested sequence of  ab elements  :)

    for $sheets in $nodes
    return update replace $sheets with 
        <ab type="fasc" n="{substring(string($sheets/pb[1]/@n), 2, 2)}">
            <ab type="sheet">
                <ab type="block">
                    <ab type="page" subtype="">
                        {$sheets}
                    </ab>
                </ab>
            </ab>
        </ab>
};

declare function local:add-sheet($nodes as node()*) as item()* {
    (:  Refactor pages, update pb attribute values, add fw element  :)
}:

local:add-sheet($text//ab)


