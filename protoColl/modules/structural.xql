xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xi="http://www.w3.org/2001/XInclude";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable $text := doc(concat($corpus, 'KR2k0008.xml'));

(:declare function local:oldinsert-sheet-tags($nodes as node()*) as item()* {
    (\:  Add sheet ab elements for structural markup :\)
    (\: run on $text//body after initial conversion :\)
    (\: replaces the old ab element with a nested sequence of  ab elements up unto the @page  ab element :\)
    (\:  page ab closes in bad location  @fasc in output is not equal to "juan" as captured in source:\)
    
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node
            case comment () return $node
            case element (ab) return  <div type="fasc" n="{substring(string($node/pb[1]/@n), 2, 2)}">
                                            {local:insert-sheet-tags($node/node())}
                                        </div>
            case element (pb) return <div type="sheet">
                                                <div type="block">
                                                    <ab type="page" 
                                                        subtype="{substring($node/@n, string-length($node/@n))}"
                                                        n="{substring(substring-after($node/@n, "-"), 
                                                            1, string-length(substring-after($node/@n, "-")) -1)}">
                                                            <pb facs="{$node/@facs}"/>
                                                                {local:insert-sheet-tags($node/node())}
                                                    </ab>
                                                </div>
                                        </div>    
            case element (hi) return $node
            case element (lb) return $node
            case element (g) return $node
        default return local:insert-sheet-tags($node/node())
};:)


(: declare function local:insert-sheet-tags($nodes as node()*) as item()* {
    (:  Add sheet ab elements for structural markup :)
    (:  this is a positional grouping problem so very much 'xquery-ouch'  :)
    (:  !!! make sure that gaiji aren't inadvertently converted to tofu !!!  :)
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node
            case comment () return $node
              case element (pb) return if (matches(data($node/@n), 'a$'))
                                           then (<div type="sheet">
                                                    <div type="block">
                                                        <ab type="page" 
                                                            subtype="{substring($node//@n, string-length($node/pb[1]/@n))}"
                                                            n="{substring(substring-after($node/@n, "-"), 1, 
                                                            string-length(substring-after($node/@n, "-")) -1)}">
                                                     <pb facs="{$node/@facs}"/>)
                                           else (</ab> 
                                                    <ab type="page" 
                                                            subtype="{substring($node//@n, string-length($node/pb[1]/@n))}"
                                                            n="{substring(substring-after($node/@n, "-"), 1, 
                                                            string-length(substring-after($node/@n, "-")) -1)}">
                                                     <pb facs="{$node/@facs}"/>
                                                     {local:insert-sheet-tags($node/node())}
                                                     </ab>
                                                </div>
                                             </div>)
            case element (hi) return $node
            case element (lb) return $node
            case element (g) return $node
        default return local:insert-sheet-tags($node/node())                                
};:)

(: ../child::x[. >> $current]:)

(:local:insert-sheet-tags($text//ab):)

(:let $pi :=<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>:)
(:let $include := <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="teiHeader.xml" parse="xml"/>:)


<TEI>
    <text>
        <front>
            <div type="fasc" n="00">
        {for $front in $text//ab
        where substring(data($front/pb[1]/@n), 1, 3) eq '000'
        return
             $text//ab} (:local:insert-sheet-tags($front):)
            </div>
        </front>
        <body>
            {for $fasc in $text//ab
            where substring(data($fasc/pb[1]/@n), 1, 3) != '000'
            return
                <div type="fasc" n="{substring(string($fasc/pb[1]/@n), 2, 2)}">
                    {$text//ab} (:local:insert-sheet-tags($fasc):)
                </div>
            }
        </body>
    </text>
</TEI>