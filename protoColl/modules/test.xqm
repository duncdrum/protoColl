xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $corpus := '/db/apps/protoColl/data/corpus/';

declare variable $header := doc(concat($corpus, 'teiHeader.xml'));
declare variable  $gaiji := doc(concat($corpus, 'charDecl.xml'));
declare variable  $text := doc(concat($corpus, 'KR2k0008.xml'));



for $div in $text//div
return $div/@*/string()


