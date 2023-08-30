## Short Demo to Show Example of APEX Automation for PL/SQL Script
In this example we will showcase how to setup a procedure to perform repetitive tasks inside an APEX Application.

- Create a log table and sequence

```
CREATE table "LOGGER" (
    "LOG_ID"     NUMBER,
    "LOG"        VARCHAR2(1500),
    "LOG_TIME"   TIMESTAMP,
    constraint  "LOGGER_PK" primary key ("LOG_ID")
)
/

CREATE sequence "LOGGER_SEQ" 
/

CREATE trigger "BI_LOGGER"  
  before insert on "LOGGER"              
  for each row 
begin  
  if :NEW."LOG_ID" is null then
    select "LOGGER_SEQ".nextval into :NEW."LOG_ID" from sys.dual;
  end if;
end;
/  
```

-- Create procedure

```
     create or replace procedure testProc is

     
     begin
     -- Begin procedure
     insert into logger (LOG, LOG_TIME) values('Procedure testProc Initiating',CURRENT_TIMESTAMP);
     -- add logic

     -- end logic
     insert into logger (LOG, LOG_TIME) values('Procedure testProc Completed',CURRENT_TIMESTAMP);
     commit;
     end;
```