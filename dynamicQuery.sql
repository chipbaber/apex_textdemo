declare
v_sql varchar2(32000);
begin

   if :P1_DOC_QUERY is null then
     --Return all resumes
     v_sql := q'~
       select ROWID as "ROWID",
       DOC_ID  as "ID",
       TITLE  as "Title",
       SUBMITTED_BY  as "Submitted By:",
       sys.dbms_lob.getlength(RESUME)  as "Resume",
       MIMETYPE  as "file Type",
       CREATED_DATE  as "Created On",
       FILENAME  as "File Name"
       from RESUME
       ~';
   else
     v_sql := q'~
       select ROWID as "ROWID",
       DOC_ID  as "ID", TITLE  as "Title", SUBMITTED_BY  as "Submitted By:",
       sys.dbms_lob.getlength(RESUME)  as "Resume",  MIMETYPE  as "file Type",  CREATED_DATE  as "Created On",
       FILENAME  as "File Name"
       from RESUME WHERE CONTAINS(resume, '~'
       ||:P1_DOC_QUERY||
       q'~', 1) > 0
       ~';
   end if;

   return v_sql;
end;
