# How to Set Session State in APEX via Javascript API

- This Code references this video []() please watch for more details.

- Sample Javscript for the Full Text Search with submit
```
let queryTerm =$v("P1_DOC_QUERY");
let queryType;

if (queryTerm.charAt(0) == '$') {
    queryType="Stem Search on ";
}
else if (queryTerm.charAt(0) == '!') {
    queryType="Soundex Search on ";
}
else if (queryTerm.charAt(0) == '?') {
    queryType="Fuzzy Search on ";
}
else {
    queryType="Full Text Search on ";
}

apex.submit(
{
set:{"P1_FIRSTWORD":null,
"P1_SECONDWORD":null,
"P1_PROXIMITY": null,
"P1_DOC_QUERY":queryTerm,
"P1_SEARCH_TYPE":queryType},
showWait: true,
validate: true,
}

);
```

- Sample Javscript for the Full Text Search with submit
```
```
