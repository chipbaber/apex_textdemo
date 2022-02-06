/* This is an example dynamic sql query that is used in a APEX report.
PLease reference this video for more details.
*/
declare
v_sql varchar2(32000);
begin

--If all the terms are null, display all resumes in the report.
   if (:P1_DOC_QUERY is null) AND (:P1_FIRSTWORD is null) AND (:P1_SECONDWORD is null) then
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
--Do a Full text query.
   elsif (:P1_FIRSTWORD is null) AND (:P1_SECONDWORD is null) then
     v_sql := q'~
       select ROWID as "ROWID",
       DOC_ID  as "ID", TITLE  as "Title", SUBMITTED_BY  as "Submitted By:",
       sys.dbms_lob.getlength(RESUME)  as "Resume",  MIMETYPE  as "file Type",  CREATED_DATE  as "Created On",
       FILENAME  as "File Name"
       from RESUME WHERE CONTAINS(resume, '~'
       ||:P1_DOC_QUERY||
       q'~', 1) > 0
       ~';
   else
   v_sql := q'~
     select ROWID as "ROWID",
     DOC_ID  as "ID", TITLE  as "Title", SUBMITTED_BY  as "Submitted By:",
     sys.dbms_lob.getlength(RESUME)  as "Resume",  MIMETYPE  as "file Type",  CREATED_DATE  as "Created On",
     FILENAME  as "File Name"
     from RESUME WHERE  CONTAINS(resume,'near((~'||:P1_FIRSTWORD||q'~,~'||:P1_SECONDWORD||q'~),~'||:P1_PROXIMITY||q'~)',1) > 0
     ~';
   end if;
  -- APEX_DEBUG.ENABLE(apex_debug.c_log_level_info);
--   apex_debug.message(p_message => 'Chip enabled Debug. SQL below:');
  -- apex_debug.message(p_message => v_sql);
   return v_sql;
end;
