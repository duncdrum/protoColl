xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable  $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable  $text := doc(concat($corpus, 'KR2k0008.xml'));


declare function local:insert-page-tags($nodes as node()*) as item()* {
    (:  Add page ab elements  :)
    (: run  on $text//ab after running insert-sheet-tags  :)
    (: insert ab element for pages including logical and recto verso numbering  :)

    for $node in $nodes
    return 
        typeswitch($nodes)
            case text() return $node
            case comment() return $node
            case element(pb) return <ab type="page" subtype="">
                                        {$node/node()}
                                    </ab>
        default return local:insert-page-tags($node/node())
};

declare function local:insert-sheet-tags($nodes as node()*) as item()* {
    (:  Add sheet ab elements for structural markup based on previously converted pb elements  :)
    (: run  on $text//ab after initial conversion :)
    (: replaces the old ab element with a nested sequence of  ab elements up unto the @page  ab element :)
    
    for $node in $nodes
    return 
        typeswitch($nodes)
            case text() return $node
            case comment() return $node
            case element (ab) return  <ab type="fasc" n="{substring(string($node/pb[1]/@n), 2, 2)}">
                                            <ab type="sheet">
                                                <ab type="block">
                                                    {$node/node()}
                                                </ab>
                                            </ab>
                                        </ab>
        default return local:insert-sheet-tags($node/node())

};



local:insert-sheet-tags($text//ab[77])


