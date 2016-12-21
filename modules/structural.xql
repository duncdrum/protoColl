xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xi="http://www.w3.org/2001/XInclude";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $data := '/db/apps/protoColl/data/';
declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable $text := doc(concat($corpus, 'KR2k0008.xml'));

(: !!! CAVEAT !!!
exist-db is great except whern it isn't. The below is pseudo code because: 

1) a bug in handling of group by clauses https://github.com/eXist-db/exist/issues/967 
prevents fully automated import of kanripo documents

2) for exist we need to replace standard xquery function:
    fn:unparsed-text(concat($data, 'test.txt')) 
with
    util:binary-to-string(util:binary-doc(concat($data, 'test.txt')))
    
    A future working version should conform to http://www.mandoku.org/mandoku-format-en.html   
:)

declare function local:insert-sheet-tags($nodes as node()*) as item()* {
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
};


(:let $pi :=<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>:)
(:let $include := <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="teiHeader.xml" parse="xml"/>:)


<TEI>
    <text>
        <front>
            <div type="fasc" n="00">
                {for $front in $text//ab[@type="fasc"]
                where substring(data($front/div/div/ab/pb[1]/@facs), 5, 3) eq '000'
                return
                     $front/node()} 
            </div>
        </front>
        <body>
            {for $fasc in $text//ab[@type="fasc"]
            where substring(data($fasc/div/div/ab/pb[1]/@n), 5, 3) != '000'
            return
                <div type="fasc" n="{substring(string($fasc/div/div/ab/pb[1]/@facs), 6, 2)}">
                    {$fasc/node()} 
                </div>}
        </body>
    </text>
</TEI>