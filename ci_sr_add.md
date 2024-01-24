```
declare
v_eventdate ci_sessions.EVENT_DATE%type;
v_oppt ci_sessions.OPPT_%type;
v_id ci_sessions.ID%type;
v_count number(4) :=0;
v_countErr number(4) :=0;
--dynamic sql variables
sql_stmt VARCHAR2(700);
sql_update VARCHAR2(700);
v_sr  ci_sr_hours.sr_number%TYPE;
v_expFilter varchar2(32000);


--Script to add in or update SR number to weekly stats
--cursor to get all current values is step 1
CURSOR sessions IS 
select  event_date, oppt_, id from ci_sessions where service_request is null;

begin
dbms_output.put_line('Starting procedure');
v_expFilter := '"DV - SE Team"."Opportunity"."Opportunity ID" in (';
--begin loop
   OPEN sessions; 
   LOOP 
   FETCH sessions INTO v_eventdate, v_oppt, v_id;
   EXIT WHEN sessions%notfound; 
   --Look for SR with dynamic sql
   sql_stmt := 'select sr_number from ci_sr_hours where :v_oppt = opportunity_id and :v_eventdate between first_effort and last_effort'; 
     
   --Putting Dynamic SQL in error block to check if oddity with SR number so program can proceed. 
       begin
       EXECUTE IMMEDIATE sql_stmt INTO v_sr USING v_oppt, v_eventdate;
       dbms_output.put_line('Query Executed results for ID: '||v_id|| chr(10)||' Event Date: '||v_eventdate||' - Oppt ID: '||v_oppt||' - SR: '||v_sr);
       
           begin
           -- update row into DB. 
            sql_update := 'update ci_sessions set service_request = :v_sr where id = :v_id ';

            EXECUTE IMMEDIATE sql_update USING v_sr, v_id;
           EXCEPTION
           WHEN OTHERS THEN 
            dbms_output.put_line('Error on insert for id: '||v_id);
           end;

       v_count := v_count+1;  
       EXCEPTION
       WHEN OTHERS THEN 
       v_countErr := v_countErr+1;  
       --dbms_output.put_line('Error processing row ID: '||v_id||' in ci_sessions table. Query below.');
       --v_expFilter := v_expFilter||' ''' ||v_oppt||''',';
       --dbms_output.put_line('select * from ci_sessions where id = '||v_id);
       --dbms_output.put_line('select sr_number from ci_sr_hours where '''||v_oppt||''' = opportunity_id and '''||v_eventdate||''' between first_effort and last_effort');
       end;

    
   END LOOP; 
   CLOSE sessions; 
 --  v_expFilter := substr(v_expFilter, 1, length(v_expFilter)-1) || ')';

commit;
dbms_output.put_line('Rows Updated:' || v_count);
dbms_output.put_line('Rows not Processed:' || v_countErr);
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('Other Error occurred: ');
end;

```