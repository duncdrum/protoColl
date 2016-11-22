# Regex for positional sibling conversion

1. replace: 
```<pb n="(\d*)-(\d*)a" facs="page(.*)"/>```

with:
```<div type="sheet">
  <div type="block">
    <ab type="page" subtype="verso" n="$2">
     <pb facs="page$3"/>```     
2. replace:     
 ``` <pb n="(\d*)-(\d*)b" facs="page(.*)"/>```
 
with:
```</ab>
<fw type="heart"/>
    <ab type="page" subtype="recto" n="$2">
     <pb facs="page$3"/>```     
3. replace:

```  </ab>
      <ab type="fasc" (.)*>
      </ab>
    </div>
</div>```

with:
```    </ab>
    </div>
  </div>
</ab>
<ab type="fasc" $1>```
