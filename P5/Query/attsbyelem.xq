declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace rng="http://relaxng.org/ns/structure/1.0";
declare namespace request="http://exist-db.org/xquery/request";

declare function tei:atts($a as element(),$lang as xs:string) as element() {
 <att>
    <name>
    {$a/@usage}
    {data($a/@ident)}</name>
    <defaultVal>{data($a/tei:defaultVal)}</default>
     { for $d in  $a/tei:datatype return
	 <datatype>
	    { $d/@minOccurs }
	    { $d/@maxOccurs }
	    { $d/* }
         </datatype>
     }
     {  
      for $d in $a/tei:valList[@type='closed']  return
       <valList>
         {for $dv in $d/tei:valItem return
             <valItem>
	        { $dv/@ident }
             </valItem>
             }
       </valList>
      }
    <desc>{
    if ($a/tei:desc[@xml:lang=$lang]) then
        data($a/tei:desc[@xml:lang=$lang])
    else
        data($a/tei:desc[not(@xml:lang)])
	}</desc>
  </att>
};

let $e := request:get-parameter("name", "")
let $lang := request:get-parameter("lang", "")
for $c in collection("/db/TEI")//tei:elementSpec[@ident=$e]
return
<Element>
{
for $a in $c//tei:attDef
return tei:atts($a,$lang) 
}
{
for $class in $c/tei:classes/tei:memberOf
return
for $ac in collection("/db/TEI")//tei:classSpec[@ident=$class/@key]//tei:attDef
return tei:atts($ac,$lang)
}
{
for $ac in collection("/db/TEI")//tei:classSpec[@ident='att.global']//tei:attDef
return tei:atts($ac,$lang)
}
</Element>
