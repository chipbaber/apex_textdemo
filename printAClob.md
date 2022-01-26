# How to print a Clob in APEX 20.2

## Create a Blank Page


- Use the following Code in a dynamic pl/sql region.

```
declare
resumeMarkup clob;
amt INTEGER := 4000;
pos INTEGER := 1;
buf VARCHAR2(4000);
begin
--Get the resume from Oracle Text filtered_docs table.
select document into resumeMarkup from filtered_docs where query_id = :P4_QUERY_ID;

loop
 -- print 4k characters
 dbms_lob.read(resumeMarkup, amt, pos, buf);

 --increment character range
 pos := pos + amt;

-- print to APEX
 htp.p(buf);

end loop;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('End of data');

END;
```
