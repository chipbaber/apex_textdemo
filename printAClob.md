# How to print a Clob in APEX 20.2

## Create a Blank Page

- Use the following Code in a dynamic pl/sql region.

```
declare
resumeMarkup clob;
amt INTEGER := 8000;
pos INTEGER := 1;
buf VARCHAR2(32767);
len INTEGER;
remainder INTEGER;

begin
--Get the resume from Oracle Text filtered_docs table.
select document into resumeMarkup from filtered_docs where QUERY_ID = :P4_QUERY_ID;

--Check for zero length Clob
IF (DBMS_LOB.GETLENGTH(resumeMarkup) = 0) THEN
    HTP.P('Indexing for filtered Markup for document not yet completed, please try again later.');
  ELSE
    len := DBMS_LOB.GETLENGTH(resumeMarkup);

    --If Clob length less than 8k max simply pull and print in 1 action.
    IF (DBMS_LOB.GETLENGTH(resumeMarkup) <= amt) THEN
       dbms_lob.read(resumeMarkup, len, pos, buf);
       htp.p(buf);
    --Else loop through till end.
    else
        --Set the remainder of characters to the length of the clob.
        remainder :=len;

        /* iterate through the length of the clob*/
        WHILE pos < len
        loop

        IF (remainder > amt) THEN
        -- print 4k characters
        dbms_lob.read(resumeMarkup, amt, pos, buf);

        else
        -- print remainder of characters
        dbms_lob.read(resumeMarkup, remainder, pos, buf);
        end if;
        --increment character start range per iteration, then decrease the amount of characters remaining.
        pos := pos + amt;
        remainder := remainder - amt;


        -- print to APEX
        htp.p(buf);

        end loop;
    end if;

end if;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
      resumeMarkup := EMPTY_CLOB();      
  END;
```
