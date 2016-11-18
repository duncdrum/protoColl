xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable $text := doc(concat($corpus, 'KR2k0008.xml'));

declare function local:insert-div-tags($nodes as node()*) as item()* {
    (:  Add sheet ab elements for structural markup based on previously converted pb elements  :)
    (: run on $text//body after initial conversion :)
    (: replaces the old ab element with a nested sequence of  ab elements up unto the @page  ab element :)
    (:  page ab closes in bad location  @fasc in output is not equal to "juan" as captured in source:)
    
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node
            case comment () return $node
            case element (ab) return  <div type="fasc" n="{substring(string($node/pb[1]/@n), 2, 2)}">
                                            <div type="sheet">
                                                <div type="block">
                                                    {local:insert-div-tags($node/node())}
                                                </div>
                                            </div>
                                        </div>
            case element (pb) return <ab type="page" 
                                        subtype="{substring($node/@n, string-length($node/@n))}"
                                        n="{substring(substring-after($node/@n, "-"), 
                                            1, string-length(substring-after($node/@n, "-")) -1)}">
                                            <pb facs="{$node/@facs}"/>
                                                {local:insert-div-tags($node/node())}
                                    </ab>
            case element (hi) return $node
            case element (lb) return $node
            case element (g) return $node
        default return local:insert-div-tags($node/node())
};

(: for $body in $text//body
return update replace $body with
<body>{local:insert-ab-tags($body)}</body>  :)
  

for $ab in $text//ab[@type != 'page']
return update rename $ab as 'div'
  