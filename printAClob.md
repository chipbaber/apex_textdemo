# How to print a Clob in APEX 20.2

## Create a Blank Page


- Use the following Code in a dynamic pl/sql region.

```
declare
resumeMarkup clob;
--For some reason  character pull of larger than 3913 will fail with error
amt INTEGER := 3913;
pos INTEGER := 1;
buf VARCHAR2(4000);
len INTEGER;
remainder INTEGER;

begin
--Get the resume from Oracle Text filtered_docs table.
select document into resumeMarkup from filtered_docs where QUERY_ID = :P4_QUERY_ID;

--Check for zero length Clob
IF (DBMS_LOB.GETLENGTH(resumeMarkup) = 0) THEN
    HTP.P('Indexing for filtered Markup for document not yet completed, please try again later.');
  ELSE
    --htp.p('Document Length is' || DBMS_LOB.GETLENGTH(resumeMarkup));
    len := DBMS_LOB.GETLENGTH(resumeMarkup);

    --If Clob length less than 4k max simply pull and print in 1 action.
    IF (DBMS_LOB.GETLENGTH(resumeMarkup) <= amt) THEN
       dbms_lob.read(resumeMarkup, len, pos, buf);
       htp.p(buf);
    --Else loop through till end.
    else
      -- htp.p('Clob length > 4k');
        --Set the remainder of characters to the length of the clob.
        remainder :=len;

        /* iterate through the length of the clob*/
        WHILE pos < len
        loop
        htp.br;
        htp.p('Position: '||pos||'   ');   htp.p(' Remainder: '||remainder);
        htp.br;  
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
