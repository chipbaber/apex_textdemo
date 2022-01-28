# How to print a Clob in Oracle APEX 21.1.7
- Please watch this video for more context on how to showcase a CLOB inside a APEX page. [https://youtu.be/pSw_jFyt5zw](https://youtu.be/pSw_jFyt5zw)

- Use the following Code in a dynamic pl/sql region after watching the video.

```
declare
resumeMarkup clob;
amt INTEGER := 8000; -- max bytes to pull per CLOB in APEX
pos INTEGER := 1;
buf VARCHAR2(32767); -- max buffer size per CLOB pull in APEX
len INTEGER;


begin
--Get the resume from Oracle Text filtered_docs table.
select document into resumeMarkup from filtered_docs where QUERY_ID = :P4_QUERY_ID;

--Check for zero length Clob
IF (DBMS_LOB.GETLENGTH(resumeMarkup) = 0) THEN
    HTP.P('Indexing for filtered Markup for document not yet completed, please try again later.');
  ELSE
    len := DBMS_LOB.GETLENGTH(resumeMarkup);

        /* iterate through the length of the clob*/
        WHILE pos < len
        loop
        begin
        dbms_lob.read(resumeMarkup, amt, pos, buf);
        pos := pos + amt;      

        -- print to APEX
        htp.p(buf);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
             resumeMarkup := EMPTY_CLOB();      
         END;
        end loop;  
end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      resumeMarkup := EMPTY_CLOB();      
  END;
```
