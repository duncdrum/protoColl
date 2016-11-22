xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable  $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable  $text := doc(concat($corpus, 'KR2k0008.xml'));


declare function local:insert-ab-tags($nodes as node()*) as item()* {
    (:  Add sheet ab elements for structural markup based on previously converted pb elements  :)
    (: run  on $text after initial conversion :)
    (: replaces the old ab element with a nested sequence of  ab elements up unto the @page  ab element :)
    (:  page ab closes in bad location  @fasc in output is not equal to "juan" as captured in source:)
    
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node
            case comment () return $node
            case element (ab) return  <ab type="fasc" n="{substring(string($node/pb[1]/@n), 2, 2)}">
                                            <ab type="sheet">
                                                <ab type="block">
                                                    {local:insert-ab-tags($node/node())}
                                                </ab>
                                            </ab>
                                        </ab>
            case element (pb) return <ab type="page" 
                                        subtype="{substring($node/@n, string-length($node/@n))}"
                                        n="{substring(substring-after($node/@n, "-"), 
                                            1, string-length(substring-after($node/@n, "-")) -1)}">
                                            <pb facs="{$node/@facs}"/>
                                                {local:insert-ab-tags($node/node())}
                                    </ab>
            case element (hi) return $node
            case element (lb) return $node
            case element (g) return $node
        default return local:insert-ab-tags($node/node())
};

(:count($text//pb):)
(:for $body in $text//body:)
(:return update replace $body with:)
(:<body>{local:insert-ab-tags($body)}</body>:)

(:declare function local:section($e as element(pb)) { <page>{local:nextPara(
$e/following-sibling::*[1][self::pb])} </page>};

declare function local:nextPara($p as element(ab)?) { if ($p) then ($p,
local:nextPara($p/following-sibling::*[1][self::ab])) else ()};

return
<out>{for $h in $in return local:section($h)}</out>:)

let $in := 
    <ab>
        <pb n="1a"/>
        aaaa<lb/>
        <pb n="1b"/>
        <hi>bb<lb/>bb</hi>
        <pb n="2a"/>
        cccc<lb/>
        <pb n="2b"/>
        dddd<lb/>
        <pb n="3a"/>
        eeee<lb/>
    </ab>
    
let $out := 
    <div>
        <sheet>
            <page>
            <pb n="1a"/>
            aaaa<lb/>
            </page>
            <fw/>
            <page>
            <pb n="1b"/>
            <hi>bb<lb/>bb</hi>
            </page>
        </sheet>
        <sheet>
        <page>
             <pb n="2a"/>
             cccc<lb/>
             </page>
             <fw/>
             <page>
             <pb n="2b"/>
             dddd<lb/>
        </page>
        </sheet>
        <sheet>
        <page>
            <pb n="3a"/>
            eeee<lb/>
        </page>
        </sheet>
    </div>

return



(:return
    <sheet>
        {let $g := substring(data($page/pb/@n), 1, 1)
        for $page in $in/* 
        
        group by $g 

        return
            <page>{$page/../node()}</page>}
    </sheet>
:)


